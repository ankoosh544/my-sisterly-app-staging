import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/screens/stripe_webview_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

import 'order_details_screen.dart';

class OffersContractSellerScreen extends StatefulWidget {

  final Offer offer;

  const OffersContractSellerScreen({Key? key, required this.offer}) : super(key: key);

  @override
  OffersContractSellerScreenState createState() => OffersContractSellerScreenState();
}

class OffersContractSellerScreenState extends State<OffersContractSellerScreen>  {

  bool _isLoading = false;
  bool _linkTerms = false;
  bool _linkOrder = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  signContract() {
    setState(() {
      _isLoading = true;
    });

    var params = {

    };

    ApiManager(context).makePostRequest("/product/order/" + widget.offer.id.toString() + "/contract", params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        accept();
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        ApiManager.showFreeErrorMessage(context, "Errore durante la generazione del contratto, riprova più tardi e se il problema persiste contatta l'assistenza");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  accept() {
    setState(() {
      _isLoading = true;
    });

    var params = {
      "order_id": widget.offer.id,
      "result": true
    };

    ApiManager(context).makePostRequest("/product/" + widget.offer.product.id.toString() + "/offer/", params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      ApiManager.showFreeSuccessMessageWithCallback(context, "Richiesta di noleggio accettata!", () {
        Navigator.pop(context);
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(
            title: "Contratto",
            leftWidget: InkWell(
              child: Container(padding: const EdgeInsets.all(12), child: SvgPicture.asset("assets/images/close_white.svg")),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ),
          SizedBox(height: 16,),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Conferma di aver preso visione della documentazione obbligatoria qui sotto per proseguire con il noleggio.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 18,
                            fontFamily: Constants.FONT,
                          ),
                        ),
                      ),
                      SizedBox(height: 32,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Color(0xff92a0a7),
                                  ),
                                  child: Checkbox(
                                      value: _linkTerms,
                                      activeColor: Constants.PRIMARY_COLOR,
                                      onChanged: (value) {
                                        setState(() {
                                          _linkTerms = value!;
                                        });
                                      }
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: RichText(
                                    text: TextSpan(
                                      //style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(text: "Link condizioni",
                                          style: TextStyle(color: Constants.PRIMARY_COLOR, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: Constants.FONT),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              String url = "https://sisterly-assets.s3.eu-central-1.amazonaws.com/Condizioni+di+noleggio.pdf";
                                              launch(url);
                                            },
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Color(0xff92a0a7),
                                  ),
                                  child: Checkbox(
                                      value: _linkOrder,
                                      activeColor: Constants.PRIMARY_COLOR,
                                      onChanged: (value) {
                                        setState(() {
                                          _linkOrder = value!;
                                        });
                                      }
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: RichText(
                                    text: TextSpan(
                                      //style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(text: "Link ordine",
                                          style: TextStyle(color: Constants.PRIMARY_COLOR, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: Constants.FONT),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              String url = "https://sisterly-api-bucket.s3.eu-central-1.amazonaws.com/media/orders/unsigned_contract.pdf";
                                              launch(url);
                                            },
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24,),
                      SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                    primary: Constants.PRIMARY_COLOR,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                    side: const BorderSide(color: Constants.PRIMARY_COLOR, width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )
                                ),
                                child: Text('Esci'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            SizedBox(width: 12,),
                            Expanded(
                                child: _isLoading ? Center(child: CircularProgressIndicator()) : Opacity(
                                  opacity: !_linkTerms || !_linkOrder ? 0.4 : 1,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Constants.SECONDARY_COLOR,
                                        textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50))),
                                    child: Text('Conferma'),
                                    onPressed: () {
                                      if(!_linkTerms || !_linkOrder) return;

                                      signContract();
                                    },
                                  ),
                                ),
                            )
                          ],
                        ),
                      ),
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
}
