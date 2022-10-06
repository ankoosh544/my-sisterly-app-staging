import 'dart:async';
import 'dart:convert';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/screens/home_screen.dart';
import 'package:sisterly/screens/login_screen.dart';
import 'package:sisterly/screens/social_profile_screen.dart';
import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/screens/welcome_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      debugPrint("splash screen initState");

      loadConfig();

      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
    });
  }

  loadConfig() async {
    var preferences = await SharedPreferences.getInstance();

    if (preferences.getString(Constants.PREFS_SERVER_URL) != null) {
      Constants.SERVER_URL = preferences.getString(Constants.PREFS_SERVER_URL)!;
    }

    // preferences.setString(Constants.PREFS_TOKEN, "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU5NTQ2MTg4LCJpYXQiOjE2NTk1NDQzODgsImp0aSI6IjBiOWE5MDllYmU3ZjRjZTlhY2I2ODU5ZGJiZjQ5NDdhIiwidXNlcl9pZCI6MTB9.X492G-ey3aA7ygPSXwoA0PB2o6Z34b7F2-qugHDz6YM");

    // preferences.setString(Constants.PREFS_REFRESH_TOKEN, "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTY2MDQwODM4OCwiaWF0IjoxNjU5NTQ0Mzg4LCJqdGkiOiJhYjk0ZDZiNmNmYmE0YjQxOGI1MmU0ODZhYTVmYjExOCIsInVzZXJfaWQiOjEwfQ.IEcm6mwwHUqw9L8CC_FGpQL1rQNrnkj7JCZvawrftSo");

    var refreshToken = preferences.getString(Constants.PREFS_REFRESH_TOKEN);

    Future.delayed(const Duration(milliseconds: 400), () async {
      debugPrint(
          "SplashScreen loadConfig. refreshToken: " + refreshToken.toString());
      autologin();
    });
  }

  goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
        (_) => false);
  }

  autologin() async {
    var preferences = await SharedPreferences.getInstance();
    var refreshToken = preferences.getString(Constants.PREFS_REFRESH_TOKEN);

    if (refreshToken != null) {
      debugPrint("authentication refreshToken: " + refreshToken);

      ApiManager(context).refreshToken(refreshToken, (response) async {
        debugPrint("authentication refreshToken success");

        if (response["access"] != null) {
          preferences.setString(Constants.PREFS_TOKEN, response["access"]);
          preferences.setString(
              Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
          SessionData().token = response["access"];
          access();
        } else {
          debugPrint("authentication refreshToken not valid");
          SessionData().token = null;
          await SessionData().clearStorageData();
          goToLogin();
        }
      }, (error) async {
        debugPrint("authentication refreshToken failure");
        SessionData().token = null;
        await SessionData().clearStorageData();
        goToLogin();
      });
    } else {
      goToTutorial();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  goToTutorial() {
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
          (_) => false); //welcomescreen
      //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()), (_) => false);
    });
  }

  goToLogin() {
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          (_) => false);
    });
  }

  access() {
    ApiManager(context).makeGetRequest('/client/properties', {}, (res) async {
      Account account = Account.fromJson(res["data"]);

      var preferences = await SharedPreferences.getInstance();
      preferences.setInt(Constants.PREFS_USERID, account.id!);
      SessionData().userId = account.id;

      if (account.username!.isEmpty ||
          account.firstName!.isEmpty ||
          account.lastName!.isEmpty ||
          account.phone!.isEmpty ||
          account.residencyCity!.isEmpty ||
          account.birthday == null) {
        setState(() async {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => SocialProfileScreen()),
              (_) => false);
        });
      } else {
        setState(() {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => TabScreen()),
              (_) => false);
        });
      }
    }, (res) {
      debugPrint("access account failed");
      SessionData().logout(context);
    });
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
            child: Center(
              child: Wrap(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SvgPicture.asset(
                        "assets/images/sisterly_logo.svg",
                        width: 221,
                        height: 223,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate("generic_loading"),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: Constants.FONT,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
