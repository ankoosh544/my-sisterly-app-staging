import 'dart:async';
import 'dart:convert';

import 'package:sisterly/screens/login_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/utils.dart';

class Welcome2Screen extends StatefulWidget {
  final bool showLogin;

  const Welcome2Screen({Key? key, this.showLogin = true}) : super(key: key);

  @override
  Welcome2ScreenState createState() => Welcome2ScreenState();
}

class Welcome2ScreenState extends State<Welcome2Screen> {
  @override
  void initState() {
    super.initState();
    Timer.run(() {
      debugPrint("welcome 2 screen initState");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  login() {
    setState(() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
    });
  }

  signup() {
    setState(() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => SignupScreen()));
    });
  }

  Widget getIconTextWidget(String iconName, String text) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 0),
          child: SvgPicture.asset(
            'assets/images/${iconName}.svg',
            height: 80,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          text,
          style: const TextStyle(
              color: Constants.TEXT_COLOR,
              fontSize: 16,
              fontFamily: Constants.FONT),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.WHITE,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/bg_splash.svg",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (Navigator.of(context).canPop())
                          InkWell(
                            child: Container(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                    "assets/images/back_black.svg")),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          )
                        else
                          const SizedBox(
                            width: 24,
                          ),
                        const SizedBox(
                          width: 24,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Center(
                      child: SvgPicture.asset(
                        "assets/images/sisterly_logo.svg",
                        width: 160,
                        height: 90,
                      ),
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    getIconTextWidget("community",
                        "Un nuovo modo di vivere la moda in una community di lender e borrower sisters!"),
                    SizedBox(
                      height: 40,
                    ),
                    getIconTextWidget("bag",
                        "La borsa dei tuoi sogni, quando e dove vuoi. Esplora il catalogo e scegli quella che fa per te."),
                    SizedBox(
                      height: 40,
                    ),
                    getIconTextWidget("rent",
                        "Metti in affitto le borse che non usi e inizia a guadagnare, in modo comodo e sicuro."),
                    SizedBox(
                      height: 40,
                    ),
                    if (!widget.showLogin)
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('FAQ'),
                          onPressed: () {
                            launch("https://www.sisterly.it/faq.html");
                          },
                        ),
                      ),
                    if (widget.showLogin)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  primary: Constants.PRIMARY_COLOR,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  side: const BorderSide(
                                      color: Constants.PRIMARY_COLOR, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                              child: Text('Registrati'),
                              onPressed: () {
                                signup();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Constants.SECONDARY_COLOR,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 46, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            child: Text('Login'),
                            onPressed: () {
                              login();
                            },
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
