import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sisterly/screens/order_confirm_success_screen.dart';
import 'package:sisterly/screens/payment_status_screen.dart';
import 'package:sisterly/screens/product_success_screen.dart';
import 'package:sisterly/screens/reset_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/custom_app_bar.dart';

import '../main.dart';
import '../utils/constants.dart';
import 'documents_success_screen.dart';
import 'login_screen.dart';

class StripeWebviewScreen extends StatefulWidget {

  final String title;
  final String url;

  const StripeWebviewScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  StripeWebviewScreenState createState() => StripeWebviewScreenState();
}

class StripeWebviewScreenState extends State<StripeWebviewScreen>  {

  final GlobalKey webViewKey = GlobalKey();

  bool isLoading = false;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        //useShouldOverrideUrlLoading: true,
        //mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      /*testNavigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => DocumentsSuccessScreen()),
              (_) => false);*/
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          Stack(
            children: [
              Align(
                child: SvgPicture.asset("assets/images/wave_blue.svg"),
                alignment: Alignment.topRight,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: SvgPicture.asset("assets/images/back.svg"),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          widget.title.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.FONT
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                    initialOptions: options,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) async {
                      debugPrint("onLoadStart "+url.toString());

                      setState(() {
                        isLoading = true;
                      });

                      var strippedServer = Constants.SERVER_URL.replaceAll("https://", "").replaceAll("http://", "");

                      if(url != null && (url.toString().contains(strippedServer) || url.toString().contains("/payment/result"))) {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) => PaymentStatusScreen(total: 0,)),
                                (_) => false);
                      }

                      if(url != null && url.toString().contains("/payment/cancelled")) {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      }

                      if(url != null && url.toString().contains("/onboarding/success")) {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) => DocumentsSuccessScreen()),
                                (_) => false);
                      }

                      if(url != null && url.toString().contains("/onboarding/failure")) {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      }

                      if(url != null && url.toString().contains("/payment/lender-kit/success")) {
                        await FirebaseAnalytics.instance.logEvent(name: "payment_lender_kit");
                        MyApp.facebookAppEvents.logEvent(name: "payment_lender_kit");
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (BuildContext context) =>
                                ProductSuccessScreen()), (_) => false);
                      }

                      if(url != null && url.toString().contains("/payment/lender-kit/failure")) {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      }
                    },
                    androidOnPermissionRequest: (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    /*shouldOverrideUrlLoading: (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      /*if (![ "http", "https", "file", "chrome",
                        "data", "javascript", "about"].contains(uri.scheme)) {
                        if (await canLaunch(url)) {
                          // Launch the App
                          await launch(
                            url,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }*/

                      return NavigationActionPolicy.ALLOW;
                    },*/
                    onLoadStop: (controller, url) async {
                      debugPrint("onLoadStop "+url.toString());

                      setState(() {
                        isLoading = false;
                      });

                      if(url != null && url.toString().contains("https://sisterly.it/")) {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) => DocumentsSuccessScreen()),
                                (_) => false);
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      debugPrint("onLoadError "+url.toString());
                    },
                    onProgressChanged: (controller, progress) {

                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      debugPrint("onUpdateVisitedHistory "+url.toString());
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                  if(isLoading) Center(child: CircularProgressIndicator())
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}
