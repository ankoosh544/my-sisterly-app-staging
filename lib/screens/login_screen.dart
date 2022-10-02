import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/screens/social_profile_screen.dart';
import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import 'forgot_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();

  //final FocusNode _passwordFocus = new FocusNode();
  final _formKey = GlobalKey<FormState>(debugLabel: '_loginFormKey');

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      precompileEmail();
    });
  }

  precompileEmail() async {
    var preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(Constants.PREFS_EMAIL);

    debugPrint("precompileEmail " + email.toString());

    if (email != null) {
      setState(() {
        _emailFilter.text = email;
      });
    }
  }

  login() async {
    //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new TabScreen()), (_) => false);
    if (ApiManager.isEmpty(_emailFilter.text.trim())) {
      ApiManager.showErrorToast(context, "login_email_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_passwordFilter.text.trim())) {
      ApiManager.showErrorToast(context, "login_password_mandatory");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _emailFilter.text = _emailFilter.text.toLowerCase().trim();

    ApiManager(context).login(_emailFilter.text.trim(), _passwordFilter.text,
        (response) async {
      manageLoginResponse(response);
    }, (statusCode) {
      setState(() {
        _isLoading = false;
      });
      ApiManager.showErrorMessage(context, "generic_error");
      debugPrint("login failure");
    });
  }

  manageLoginResponse(response) async {
    if (response["access"] != null) {
      debugPrint("login success");

      var preferences = await SharedPreferences.getInstance();
      preferences.setString(Constants.PREFS_EMAIL, _emailFilter.text);
      preferences.setString(Constants.PREFS_TOKEN, response["access"]);
      preferences.setString(Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
      SessionData().token = response["access"];

      loginSuccess();
    } else {
      setState(() {
        _isLoading = false;
      });
      ApiManager.showFreeErrorToast(context, response["errors"]);
    }
  }

  loginSuccess() async {
    setState(() {
      _isLoading = true;
    });
    await ApiManager(context).loadLanguage();

    ApiManager(context).makeGetRequest('/client/properties', {}, (res) {
      setState(() async {
        _isLoading = false;
        Account account = Account.fromJson(res["data"]);

        var preferences = await SharedPreferences.getInstance();
        preferences.setInt(Constants.PREFS_USERID, account.id!);
        SessionData().userId = account.id;

        await FirebaseAnalytics.instance.logLogin();
        MyApp.facebookAppEvents.logEvent(name: "login");

        Utils.trackEvent(context, "LOGIN");

        if (account.username!.isEmpty ||
            account.firstName!.isEmpty ||
            account.lastName!.isEmpty ||
            account.phone!.isEmpty ||
            account.residencyCity!.isEmpty ||
            account.birthday == null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => SocialProfileScreen(),
          ));
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => TabScreen()),
              (_) => false);
        }
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  forgot() {
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => ForgotScreen(
                email: _emailFilter.text,
              )));
    });
  }

  @override
  void dispose() {
    _emailFilter.dispose();
    _passwordFilter.dispose();
    super.dispose();
  }

  loginWithGoogle() async {
    GoogleSignIn _googleSignIn;

    _googleSignIn = GoogleSignIn(scopes: ['email']);

    try {
      var signin = await _googleSignIn.signIn();
      var auth = await signin!.authentication;

      debugPrint("signin ok " + auth.accessToken.toString());

      var params = {"access_token": auth.accessToken};

      ApiManager(context).makePostRequest("/client/oauth/google", params,
          (response) {
        manageLoginResponse(response["data"]);
      }, (res) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      });
    } catch (error) {
      print(error);
    }
  }

  loginWithFacebook() async {
    //await FacebookAuth.instance.logOut();

    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;

      print(accessToken);

      var params = {"access_token": accessToken.token};

      ApiManager(context).makePostRequest("/client/oauth/facebook", params,
          (response) {
        manageLoginResponse(response["data"]);
      }, (res) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      });
    } else {
      print(result.status);
      print(result.message);
    }
  }

  loginWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.sisterly.sisterly.login',
        redirectUri: Uri.parse(
          Constants.APPLE_REDIRECT_URL,
        ),
      ),
    );

    // ignore: avoid_print
    debugPrint("data apple " + credential.authorizationCode);
    print(credential);

    var params = {"access_token": credential.authorizationCode};

    ApiManager(context).makePostRequest("/client/oauth/apple", params,
        (response) {
      manageLoginResponse(response["data"]);
    }, (res) {
      ApiManager.showFreeErrorMessage(context, res["errors"].toString());
    });
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.of(context).canPop())
                        InkWell(
                          child: SvgPicture.asset("assets/images/back.svg"),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      else
                        const SizedBox(
                          width: 24,
                        ),
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Welcome back",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.FONT),
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
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: 0),
                      const Text("Email / Username",
                          style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT,
                          )),
                      const SizedBox(height: 7),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4ca3c4d4),
                              spreadRadius: 8,
                              blurRadius: 12,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Constants.PRIMARY_COLOR,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.FORM_TEXT,
                          ),
                          onChanged: (value) {
                            _emailFilter.value = TextEditingValue(
                                text: value.toLowerCase(),
                                selection: _emailFilter.selection);
                          },
                          decoration: InputDecoration(
                            hintText: "Email / Username",
                            hintStyle: const TextStyle(
                                color: Constants.PLACEHOLDER_COLOR),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor: Constants.WHITE,
                          ),
                          controller: _emailFilter,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text("Password",
                          style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT,
                          )),
                      const SizedBox(height: 7),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4ca3c4d4),
                              spreadRadius: 8,
                              blurRadius: 12,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !_showPassword,
                          cursorColor: Constants.PRIMARY_COLOR,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.FORM_TEXT,
                          ),
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: SvgPicture.asset(_showPassword
                                      ? "assets/images/hide.svg"
                                      : "assets/images/show.svg"),
                                ),
                              ),
                              suffixIconConstraints:
                                  BoxConstraints(minHeight: 24, minWidth: 24),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                  color: Constants.PLACEHOLDER_COLOR),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(16),
                              filled: true,
                              fillColor: Constants.WHITE),
                          controller: _passwordFilter,
                          onSubmitted: (s) {
                            login();
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            child: const Text(
                              "Hai dimenticato la password?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Constants.PRIMARY_COLOR,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => ForgotScreen(
                                  email: _emailFilter.text,
                                ),
                              ));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SafeArea(
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Constants.SECONDARY_COLOR,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 80, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                  child: Text('Login'),
                                  onPressed: () {
                                    login();
                                  },
                                ),
                        ),
                      ),
                      if (!Constants.IS_PRODUCTION) const SizedBox(height: 20),
                      if (!Constants.IS_PRODUCTION)
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
                              child: Text('Set Server Address'),
                              onPressed: () {
                                showAddIPDialog();
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 60),
                      Text(
                        "Oppure accedi con",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Constants.PRIMARY_COLOR,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Wrap(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60))),
                                child: SvgPicture.asset(
                                  "assets/images/apple.svg",
                                  height: 25,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  loginWithApple();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xff4867AA),
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60))),
                                child: SvgPicture.asset(
                                  "assets/images/facebook.svg",
                                  height: 25,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  loginWithFacebook();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xffC4402E),
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60))),
                                child: SvgPicture.asset(
                                  "assets/images/google.svg",
                                  height: 25,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  loginWithGoogle();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future showAddIPDialog() async {
    final ipController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to input server ip?'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              height: 150,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      key: const Key('IP Address'),
                      keyboardType: TextInputType.text,
                      onChanged: (result) {
                        //
                      },
                      controller: ipController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 46, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Ok'),
                          onPressed: () async {
                            var preferences =
                                await SharedPreferences.getInstance();

                            if (ipController.value.text.isNotEmpty) {
                              Constants.SERVER_URL = ipController.value.text;
                              preferences.setString(Constants.PREFS_SERVER_URL,
                                  ipController.value.text);
                            }

                            Navigator.of(context).pop();
                          }),
                      SizedBox(width: 20),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 46, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Cancel'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
