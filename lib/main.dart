import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/localization/fallback_cupertino_localizations_delegate.dart';


Future<void> main() async {
  Stripe.publishableKey = Constants.STRIPE_PUBLISHABLE_KEY;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.blue,
    buttonColor: Colors.white,
    unselectedWidgetColor: Colors.white60,
    selectedRowColor: Colors.white,
    buttonTheme: ButtonThemeData(
        buttonColor: Color(0xffF36B24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textTheme: ButtonTextTheme.primary,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5)
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      contentPadding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      hintStyle: TextStyle(
          color: Colors.white
      ),
      labelStyle: TextStyle(
        color: Colors.grey,
      ),
    ),
    cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        elevation: 5
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(color: Color(0xffF36B24), fontSize: 23, fontWeight: FontWeight.w500, fontFamily: Constants.FONT),
      headline2: TextStyle(color: Color(0xffF36B24), fontSize: 21, fontWeight: FontWeight.w500, fontFamily: Constants.FONT),
      headline3: TextStyle(color: Color(0xffF36B24), fontSize: 19, fontWeight: FontWeight.w500, fontFamily: Constants.FONT),
      headline4: TextStyle(color: Color(0xffF36B24), fontSize: 16, fontWeight: FontWeight.w500, fontFamily: Constants.FONT),
      bodyText1: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: Constants.FONT),
      caption: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400, fontFamily: Constants.FONT),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final facebookAppEvents = FacebookAppEvents();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return GestureDetector(
      onTap: () {
        /*FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          debugPrint("onTap main unfocus");
          currentFocus.unfocus();
        }*/
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Sisterly',
        theme: appTheme,
        color: Colors.red,
        navigatorObservers: [
          observer,
        ],
        supportedLocales: [
          Locale('it')
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackCupertinoLocalizationsDelegate(),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if(locale == null) {
            debugPrint("Locale null. Return first locale");
            //SessionData().language = supportedLocales.first.languageCode;
            return supportedLocales.first;
          }

          debugPrint("requestedLocale: "+locale.languageCode+"  supportedLocales: "+supportedLocales.toString());

          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              debugPrint("Return requested locale "+supportedLocale.toString());
              //SessionData().language = supportedLocale.languageCode;
              return supportedLocale;
            }
          }

          debugPrint("Return first locale");
          //SessionData().language = supportedLocales.first.languageCode;
          return supportedLocales.first;
        },
        home: SplashScreen(),
      ),
    );
  }
}