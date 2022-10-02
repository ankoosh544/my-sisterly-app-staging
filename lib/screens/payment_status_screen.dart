import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/screens/home_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart';
import '../utils/constants.dart';

class PaymentStatusScreen extends StatefulWidget {

  final double total;

  const PaymentStatusScreen({Key? key, required this.total}) : super(key: key);

  @override
  PaymentStatusScreenState createState() => PaymentStatusScreenState();
}

class PaymentStatusScreenState extends State<PaymentStatusScreen> {

  String msgTitle = "Richiesta inviata correttamente";
  String msgBody = "Il noleggio sarà confermato solo una volta che la Lender avrà accettato la tua richiesta";
  String icon = "assets/images/success.svg";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await FirebaseAnalytics.instance.logPurchase(value: widget.total, currency: "EUR");
      MyApp.facebookAppEvents.logPurchase(amount: widget.total, currency: "EUR");
    });
  }

  next() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => TabScreen()), (_) => false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                child: SizedBox(),
              ),
              Text(
                msgTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              /*const SizedBox(height: 40),
              const Text("Se verrà accettata potrai procedere al pagamento per la conferma",
                  style: TextStyle(
                    color: Constants.TEXT_COLOR,
                    fontSize: 16,
                    fontFamily: Constants.FONT,
                  ),
                textAlign: TextAlign.center,
              ),*/
              const Expanded(
                child: SizedBox(),
              ),
              SvgPicture.asset(icon),
              const Expanded(
                child: SizedBox(),
              ),
              Text(
                msgBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff0e5679),
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SafeArea(
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Constants.SECONDARY_COLOR,
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text('Vai alla home'),
                    onPressed: () {
                      next();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
