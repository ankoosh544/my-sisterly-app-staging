import 'package:sisterly/screens/reset_success_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/widgets/custom_app_bar.dart';

import '../utils/constants.dart';
import 'forgot_screen.dart';

class ResetScreen extends StatefulWidget {

  @override
  ResetScreenState createState() => ResetScreenState();
}

class ResetScreenState extends State<ResetScreen> {
  final TextEditingController _passwordFilter = TextEditingController();
  final TextEditingController _confirmFilter = TextEditingController();

  final _formKey = GlobalKey<FormState>(debugLabel: '_resetFormKey');

  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();

  }

  reset() async {
    //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new TabScreen()), (_) => false);
    if (ApiManager.isEmpty(_passwordFilter.text.trim())) {
      ApiManager.showErrorToast(context, "login_email_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_confirmFilter.text.trim())) {
      ApiManager.showErrorToast(context, "login_password_mandatory");
      return;
    }
/*
    _emailFilter.text = _emailFilter.text.toLowerCase().trim();

    ApiManager(context).login(_emailFilter.text.trim(), _passwordFilter.text,
        (response) async {
      if (response["success"] == true) {
        debugPrint("login success");

        var preferences = await SharedPreferences.getInstance();
        preferences.setString(Constants.PREFS_EMAIL, _emailFilter.text);

        loginSuccess(response["data"]);
      } else {
        ApiManager.showErrorMessage(context, response["code"]);
      }
    }, (statusCode) {
      ApiManager.showErrorMessage(context, "generic_error");
      debugPrint("login failure");

    });*/

    resetSuccess();
  }

  resetSuccess() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => ResetSuccessScreen()),
            (_) => false);
  }

  @override
  void dispose() {
    _confirmFilter.dispose();
    _passwordFilter.dispose();
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
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "New password",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),
                      Text(
                        "Set your new password.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("New password",
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
                          obscureText: _showPassword,
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
                                  child: SvgPicture.asset(
                                      _showPassword ? "assets/images/hide.svg" : "assets/images/show.svg"),
                                ),
                              ),
                              suffixIconConstraints:
                              BoxConstraints(minHeight: 24, minWidth: 24),
                              hintText: "New password",
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
                            //con();
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text("Confirm new password",
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
                          obscureText: _showConfirm,
                          cursorColor: Constants.PRIMARY_COLOR,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.FORM_TEXT,
                          ),
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showConfirm = !_showConfirm;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: SvgPicture.asset(
                                      _showConfirm ? "assets/images/hide.svg" : "assets/images/show.svg"),
                                ),
                              ),
                              suffixIconConstraints:
                                  BoxConstraints(minHeight: 24, minWidth: 24),
                              hintText: "Confirm new password",
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
                          controller: _confirmFilter,
                          onSubmitted: (s) {
                            reset();
                          },
                        ),
                      ),
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
                            child: Text('Confirm'),
                            onPressed: () {
                              reset();
                            },
                          ),
                        ),
                      ),
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
}
