import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/api_manager.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import 'login_screen.dart';

class SignupSuccessScreen extends StatefulWidget {
  @override
  SignupSuccessScreenState createState() => SignupSuccessScreenState();
}

class SignupSuccessScreenState extends State<SignupSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Utils.updateCrmUser(context);
  }

  login() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
        (_) => false);
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
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                child: SizedBox(),
              ),
              Text(
                "Complimenti!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Il tuo account è stato creato. Riceverai una mail di conferma per attivarlo.",
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontSize: 16,
                  fontFamily: Constants.FONT,
                ),
                textAlign: TextAlign.center,
              ),
              const Expanded(
                child: SizedBox(),
              ),
              SvgPicture.asset("assets/images/success.svg"),
              const Expanded(
                child: SizedBox(),
              ),
              SafeArea(
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Constants.SECONDARY_COLOR,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text('Login'),
                    onPressed: () {
                      login();
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
