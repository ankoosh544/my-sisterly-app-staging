import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/credit_card.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/screens/payment_status_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';

import 'documents_screen.dart';

class ChoosePaymentScreen extends StatefulWidget {

  final Offer offer;

  ChoosePaymentScreen({Key? key, required this.offer}) : super(key: key);

  @override
  _ChoosePaymentScreenState createState() => _ChoosePaymentScreenState();
}

class _ChoosePaymentScreenState extends State<ChoosePaymentScreen> {

  List<Document> _documents = [];
  bool _isLoadingDocuments = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getDocuments();
    });
  }

  getDocuments() {
    setState(() {
      _isLoadingDocuments = true;
    });
    ApiManager(context).makeGetRequest('/payment/kyc', {}, (res) {
      _documents = [];

      var data = res["data"];
      if (data != null) {
        for (var doc in data) {
          _documents.add(Document.fromJson(doc));
        }
      }

      setState(() {
        _isLoadingDocuments = false;
      });

      if(_documents.isNotEmpty) {
        next();
      }
    }, (res) {
      setState(() {
        _isLoadingDocuments = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          Stack(
            children: [
              Align(
                child: SvgPicture.asset("assets/images/wave_blue.svg"),
                alignment: Alignment.topRight,
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: InkWell(
                              child: SizedBox(child: SvgPicture.asset("assets/images/back.svg")),
                              onTap: () {
                                Navigator.of(context).pop();
                              }
                          )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.FONT),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 17)
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      if(_documents.isEmpty && !_isLoadingDocuments) InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                              MaterialPageRoute(builder: (BuildContext context) => DocumentsScreen()));

                          getDocuments();
                        },
                        child: Card(
                          color: Color(0x88FF8A80),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: const [
                                Text('Carica un documento d\'identità per poter procedere con il pagamento',
                                    style: TextStyle(
                                      color: Constants.TEXT_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT,
                                    )
                                ),
                                SizedBox(height: 8),
                                Text('Clicca qui',
                                    style: TextStyle(
                                      color: Constants.TEXT_COLOR,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT,
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Opacity(
                          opacity: _documents.isEmpty ? 0.3 : 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Constants.SECONDARY_COLOR,
                                textStyle: const TextStyle(
                                    fontSize: 16
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                            ),
                            child: Text('Avanti'),
                            onPressed: () async {
                              if(_documents.isEmpty) {
                                return;
                              }

                              next();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 35)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  next() {
    var params = {
      /*"id": _activeCard!.id.toString(),*/
      "is_card": true,
      "JavaEnabled": false,
      "Language": "it",
      "ColorDepth": 1,
      "JavascriptEnabled": true,
      "ScreenHeight": MediaQuery.of(context).size.height,
      "ScreenWidth": MediaQuery.of(context).size.width,
      "TimeZoneOffset": "UTC+2",
      "UserAgent": "Mobile",
      "ip_address": "192.168.1.1"
    };

    ApiManager(context).makePutRequest("/payment/make/" + widget.offer.id.toString(), params, (res) {
      if(res["data"] != null && res["data"]["result"] != null) {
        /*Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => PaymentStatusScreen(offer: widget.offer, code: "")));*/
      } else {
        ApiManager.showFreeErrorMessage(context, "Pagamento fallito");
      }
    }, (res) {
      if(res != null && res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        ApiManager.showFreeErrorMessage(context, "Errore durante il pagamento, riprova più tardi e se il problema persiste contatta l'assistenza");
      }
      /*setState(() {
        _isLoading = false;
      });*/
    });

    //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChoosePaymentScreen(address: _activeAddress!, shipping: _shipping, insurance: _insurance, product: widget.product)));
  }
}