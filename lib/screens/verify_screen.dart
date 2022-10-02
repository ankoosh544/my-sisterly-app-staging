import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sisterly/screens/reset_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/widgets/custom_app_bar.dart';

import '../utils/constants.dart';
import 'login_screen.dart';

class VerifyScreen extends StatefulWidget {

  final String email;
  final Function next;

  const VerifyScreen({Key? key, required this.email, required this.next}) : super(key: key);

  @override
  VerifyScreenState createState() => VerifyScreenState();
}

class VerifyScreenState extends State<VerifyScreen>  {
  final TextEditingController _codeController = TextEditingController();

  final _formKey = GlobalKey<FormState>(debugLabel: '_verifyFormKey');


  @override
  void initState() {
    super.initState();

  }

  verify() async {
    debugPrint("verify "+_codeController.text.toString());

    //Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => new TabScreen()), (_) => false);
    if (ApiManager.isEmpty(_codeController.text.trim())) {
      ApiManager.showErrorToast(context, "login_email_mandatory");
      return;
    }

    /*ApiManager(context).login(_emailFilter.text.trim(), _passwordFilter.text,
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

    verifySuccess();
  }

  verifySuccess() async {
    widget.next();
  }

  @override
  void dispose() {
    _codeController.dispose();
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
                          "Verify email",
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
                        "Enter the 6-digit code sent to",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.email,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                obscureText: false,
                                animationType: AnimationType.scale,
                                boxShadows: [BoxShadow(color: Color(0x4ca3c4d4), offset: Offset(0,1), blurRadius: 5)],
                                pinTheme: PinTheme(
                                  activeColor: Color(0xffeff2f5),
                                  selectedColor: Color(0xffeff2f5),
                                  inactiveColor: Color(0xffeff2f5),
                                  inactiveFillColor: Color(0xffeff2f5),
                                  activeFillColor: Color(0xffeff2f5),
                                  selectedFillColor: Color(0xffeff2f5),
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  fieldHeight: 45,
                                  fieldWidth: 45,
                                ),
                                cursorColor: Constants.PRIMARY_COLOR,
                                animationDuration: Duration(milliseconds: 300),
                                backgroundColor: Colors.transparent,
                                enableActiveFill: true,
                                textStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Constants.PRIMARY_COLOR,
                                ),
                                controller: _codeController,
                                onCompleted: (v) {
                                  verify();
                                },
                                onChanged: (value) {
                                  //print(_codeController.text);
                                  /*setState(() {
                                    currentText = value;
                                  });*/
                                },
                                beforeTextPaste: (text) {
                                  //print("Allowing to paste $text");
                                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                  return true;
                                },
                              )
                          )
                      ),
                      Wrap(
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Constants.TEXT_COLOR,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Resend",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Constants.PRIMARY_COLOR,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
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
                            child: Text('Verify'),
                            onPressed: () {
                              verify();
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
