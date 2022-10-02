import 'package:sisterly/screens/home_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/widgets/custom_app_bar.dart';

import '../utils/constants.dart';
import 'forgot_screen.dart';
import 'login_screen.dart';

class ProductEditSuccessScreen extends StatefulWidget {

  @override
  ProductEditSuccessScreenState createState() => ProductEditSuccessScreenState();
}

class ProductEditSuccessScreenState extends State<ProductEditSuccessScreen> {

  @override
  void initState() {
    super.initState();

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
                "Hey Sister",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              const Text("Le tue modifiche sono state salvate correttamente. Il tuo prodotto sarà visibile appena gli amministratori lo approveranno.",
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
