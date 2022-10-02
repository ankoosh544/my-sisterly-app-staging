library constants;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Constants {
  static const Color PRIMARY_COLOR = Color(0xff0e5679);
  static const Color SECONDARY_COLOR = Color(0xffffa8a8);
  static const Color SECONDARY_COLOR_LIGHT = Color(0xfffedcdc);

  static const Color DARK_TEXT_COLOR = Color(0xff1f1f1f);
  static const Color TEXT_COLOR = Color(0xff545454);
  static const Color LIGHT_TEXT_COLOR = Color(0xff707070);
  static const Color PLACEHOLDER_COLOR = Color(0xffd1d1d1);
  static const Color LIGHT_GREY_COLOR = Color(0xffaeb4c0);
  static const Color LIGHT_GREY_COLOR2 = Color(0xffeff2f5);
  static const Color GREEN_SAVE = Color(0xff91ffb2);

  static const Color GREY = Color(0xff8F8F8F);
  static const Color FORM_TEXT = Color(0xff1f1f1f);
  static const Color WHITE = Color(0xffffffff);

  static const IS_PRODUCTION =
      bool.fromEnvironment('dart.vm.product', defaultValue: false);

  // test
  static const String STRIPE_PUBLISHABLE_KEY =
      "pk_test_51KGMl1Btvb0IDiEHfApQ4hFiuGVJSV7VKgiYBiBDjglYzYBqxqgwRtDP3JgfpH41913kAThQGk7aC5dZaf2fmHU200uWSCnAoO";
  // static String SERVER_URL =
  //     "http://sisterly-dev-env.eu-central-1.elasticbeanstalk.com";
  static String SERVER_URL = "http://10.0.2.2:8000";
  static String LAMBDA_URL =
      "https://9dhuj0le2c.execute-api.eu-central-1.amazonaws.com/prod";
  static String get APPLE_REDIRECT_URL =>
      SERVER_URL + "/client/oauth/apple/callback";

  //prod check
  // static const String STRIPE_PUBLISHABLE_KEY =
  //     "pk_live_51KGMl1Btvb0IDiEHCQuNQDgFdybFKxcygBTDrXpdkZmFeDWGLnzfclcAlNi16PtFCo84kEdozaXAkPnng3rQrLxv00fzQj4CRf";
  // static String SERVER_URL = "https://api.sisterly.it";

  // static String LAMBDA_URL =
  //     "https://c6ydu4g5v6.execute-api.eu-central-1.amazonaws.com/prod";
  // static String APPLE_REDIRECT_URL =
  //     "https://api.sisterly.it/client/oauth/apple/callback";

  static const String FONT = "Manjari";

  static const String PREFS_USERID = "userid";
  static const String PREFS_USER = "user";
  static const String PREFS_LANGUAGE = "language";
  static const String PREFS_TOKEN = "token";
  static const String PREFS_REFRESH_TOKEN = "refreshtoken";
  static const String PREFS_TUTORIAL_COMPLETED = "tutorialCompleted";
  static const String PREFS_EMAIL = "email";
  static const String PREFS_SERVER_URL = "serverUrl";
}
