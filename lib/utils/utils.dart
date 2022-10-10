import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:safe_device/safe_device.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/empty_layout.dart';
import 'package:sisterly/widgets/error_layout.dart';
import 'package:sisterly/widgets/progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_manager.dart';

class Utils {
  Utils();

  static trackEvent(BuildContext context, String eventType) {
    var params = {
      "event_type": eventType,
      "timestamp": DateTime.now().millisecondsSinceEpoch
    };
    ApiManager(context).salesManagoEvent(params, (response) {
      debugPrint("salesManagoEvent OK");
    }, (error) {
      debugPrint("salesManagoEvent KO");
    });
  }

  static updateCrmUser(BuildContext context) {
    ApiManager(context).salesManagoContact((response) {
      debugPrint("Salesmanago Response");
      debugPrint(response.toString());
      debugPrint("salesManagoContact OK");
    }, (error) {
      debugPrint("salesManagoContact KO");
    });
  }

  static deleteCrmUser(BuildContext context) {
    ApiManager(context).salesManagoContactDelete((response) {
      debugPrint(response.toString());
      debugPrint("SalesmanagoDelete Delete OK");
    }, (error) {
      debugPrint(error.toString());
      debugPrint("SalesmanagoDelete Delete KO");
    });
  }

  static productCatalog(BuildContext context) {
    ApiManager(context).salesManagoProduct((response) {
      debugPrint("SalesmanagoProductCatalog Response");
      debugPrint(response.toString());
      debugPrint("SalesmanagoProductCatalog OK");
    }, (error) {
      debugPrint(error.toString());
      debugPrint("SalesmanagoProductCatalog NOT OK");
    });
  }

  static isSimulator() async {
    return !(await SafeDevice.isRealDevice);
  }

  static enablePush(BuildContext context, bool showDisabledAlert) async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId("525f16c7-1961-47ca-841d-bf2f96c2b002");

    OneSignal.shared.setExternalUserId(SessionData().userId.toString());

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");

      if (!accepted && showDisabledAlert) {
        ApiManager.showFreeErrorMessage(context,
            "Hai disabilitato le notifiche push. Accedi alle impostazioni del tuo smartphone e attivale per procedere.");
      }
    });

    OneSignal.shared.disablePush(false);

    final status = await OneSignal.shared.getDeviceState();
    debugPrint("====osUserId==========");
    debugPrint(status.toString());
    final String? osUserID = status?.userId;

    debugPrint("onesignal id " + osUserID.toString());

    var params = {"player_id": osUserID.toString()};
    ApiManager(context)
        .makePostRequest('/client/player_id', params, (res) {}, (res) {});
  }

  static formatCurrency(value) {
    var val = SessionData().currencyFormat.format(value);
    val = val.replaceAll(",00", "");
    return val;
  }

  static capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  static getImagePlaceholder() {
    return const Image(
        fit: BoxFit.cover, image: AssetImage("assets/images/placeholder.jpg"));
  }

  static getSizedImagePlaceholder(double width, double height) {
    return Image(
      fit: BoxFit.cover,
      image: const AssetImage("assets/images/placeholder.jpg"),
      width: width,
      height: height,
    );
  }

  static generateFutureBuilder(response,
      {emptyPlaceholderColor,
      emptyImageName,
      emptyText: "",
      bottomEmptyWidget}) {
    debugPrint("Items connection: " + response.connectionState.toString());
    if (response.connectionState == ConnectionState.waiting) {
      debugPrint("Items waiting");
      return CustomProgressIndicator();
    }

    if (response.connectionState == ConnectionState.done && !response.hasData) {
      debugPrint("Items error " + response.toString());
      return ErrorLayout(text: "Si è verificato un errore");
    }

    if (response.connectionState == ConnectionState.done &&
        response.hasData &&
        response.data.length == 0) {
      debugPrint("Items length 0");
      return Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            EmptyLayout(
              text: emptyText,
              color: emptyPlaceholderColor,
              imageName: emptyImageName,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: bottomEmptyWidget != null ? bottomEmptyWidget : SizedBox(),
            )
          ],
        ),
      );
    }

    debugPrint("Items render");

    return null;
  }

  static bool isValidEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }

  static bool isValidName(String value) {
    String pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';

    RegExp regExp = new RegExp(pattern);

    return regExp.hasMatch(value);
  }

  static bool isValidFiscalCode(String fiscalCode) {
    String p =
        r'^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(fiscalCode);
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static launchBrowserURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String prepareTextForCopy(String htmlText) {
    htmlText = htmlText.replaceAll("<br />", "\n");
    htmlText = htmlText.replaceAll("<br>", "\n");
    htmlText = htmlText.replaceAll("<br >", "\n");
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static bool isIOS() {
    return !kIsWeb && Platform.isIOS;
  }

  static bool isAndroid() {
    return !kIsWeb && Platform.isAndroid;
  }

  static bool isWeb() {
    return kIsWeb;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
