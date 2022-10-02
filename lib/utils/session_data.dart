
import 'package:sisterly/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/screens/welcome_2_screen.dart';
import 'package:sisterly/screens/welcome_screen.dart';

import 'constants.dart';

class SessionData {

  static final SessionData _instance = SessionData._internal();

  factory SessionData() => _instance;

  String? token;
  String? language;
  int? userId;
  String? email;
  String? deepLink;
  bool initialLinkManaged = false;

  var currencyFormat = NumberFormat.currency(symbol: "€", locale: "it_IT", customPattern: "€###.0#");

  SessionData._internal() {
    // init things inside this
  }

  logout(context) async {
    token = null;

    var preferences = await SharedPreferences.getInstance();
    preferences.remove(Constants.PREFS_REFRESH_TOKEN);
    preferences.remove(Constants.PREFS_USERID);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()), (_) => false);
  }

  clearStorageData() async {
    var preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }
}