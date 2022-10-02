import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/payment_method_screen.dart';
import 'package:sisterly/screens/payment_status_screen.dart';
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

class OffersContractBuyerScreen extends StatefulWidget {
  final Offer offer;

  const OffersContractBuyerScreen({Key? key, required this.offer})
      : super(key: key);

  @override
  OffersContractBuyerScreenState createState() =>
      OffersContractBuyerScreenState();
}

class OffersContractBuyerScreenState extends State<OffersContractBuyerScreen> {
  bool _isLoading = false;
  bool _linkTerms = false;
  bool _linkOrder = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  signContract() {
    setState(() {
      _isLoading = true;
    });

    var params = {};

    ApiManager(context).makePostRequest(
        "/product/order/" + widget.offer.id.toString() + "/contract", params,
        (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      if (res["errors"] != null) {
        if (res["errors"].length > 0 &&
            res["errors"][0].toString().contains("already signed")) {
          payNow();
        } else {
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        }
      } else {
        payNow();
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        ApiManager.showFreeErrorMessage(context,
            "Errore durante la generazione del contratto, riprova più tardi e se il problema persiste contatta l'assistenza");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  payNow() {
    setState(() {
      _isLoading = true;
    });

    var params = {"insurance": false};

    ApiManager(context).makePostRequest(
        "/product/order/" + widget.offer.id.toString() + "/checkout", params,
        (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChoosePaymentScreen(offer: offer)));
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        makePayment();
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        ApiManager.showFreeErrorMessage(context,
            "Errore durante il pagamento, riprova più tardi e se il problema persiste contatta l'assistenza");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  makePayment() {
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

    ApiManager(context).makePutRequest(
        "/payment/make/" + widget.offer.id.toString() + "?version=v2", params,
        (res) {
      debugPrint(res.toString());
      if (res["data"] != null && res["data"]["client_secret"] != null) {
        /*Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => StripeWebviewScreen(title: "Pagamento", url: res["data"]["redirect_url"],)));*/
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => PaymentMethodScreen(
                successCallback: (data) {
                  debugPrint("SSSSSSSSSSSSSSSSSSSSSS");
                  debugPrint(data);
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              PaymentStatusScreen(total: widget.offer.total!)),
                      (_) => false);
                },
                failureCallback: () {
                  ApiManager.showFreeErrorMessage(context, "Pagamento fallito");
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                paymentIntentId: res["data"]["id"],
                paymentIntentSecret: res["data"]["client_secret"],
                offer: widget.offer)));
      } else {
        ApiManager.showFreeErrorMessage(context, "Pagamento fallito");
      }
    }, (res) {
      if (res != null && res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        if (res["errors"] != null) {
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        } else {
          ApiManager.showFreeErrorMessage(context,
              "Errore durante il pagamento, riprova più tardi e se il problema persiste contatta l'assistenza");
        }
      }
      /*setState(() {
        _isLoading = false;
      });*/
    });

    //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChoosePaymentScreen(address: _activeAddress!, shipping: _shipping, insurance: _insurance, product: widget.product)));
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
                child: Container(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset("assets/images/close_white.svg")),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )),
          SizedBox(
            height: 16,
          ),
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
                          "Conferma di aver preso visione della documentazione obbligatoria qui sotto per proseguire con il pagamento.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 18,
                            fontFamily: Constants.FONT,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
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
                                      }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: RichText(
                                    text: TextSpan(
                                  //style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Link condizioni",
                                      style: TextStyle(
                                          color: Constants.PRIMARY_COLOR,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Constants.FONT),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          String url =
                                              "https://sisterly-assets.s3.eu-central-1.amazonaws.com/Condizioni+di+noleggio.pdf";
                                          launch(url);
                                        },
                                    ),
                                  ],
                                )),
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
                                      }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: RichText(
                                    text: TextSpan(
                                  //style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Link ordine",
                                      style: TextStyle(
                                          color: Constants.PRIMARY_COLOR,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Constants.FONT),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          String url =
                                              "https://sisterly-api-bucket.s3.eu-central-1.amazonaws.com/media/orders/unsigned_contract.pdf";
                                          launch(url);
                                        },
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 14),
                                    primary: Constants.PRIMARY_COLOR,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    side: const BorderSide(
                                        color: Constants.PRIMARY_COLOR,
                                        width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: Text('Esci'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: _isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Opacity(
                                      opacity:
                                          !_linkTerms || !_linkOrder ? 0.4 : 1,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Constants.SECONDARY_COLOR,
                                            textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                        child: Text('Conferma'),
                                        onPressed: () {
                                          if (!_linkTerms || !_linkOrder)
                                            return;

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
