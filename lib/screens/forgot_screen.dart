import 'package:sisterly/screens/reset_screen.dart';
import 'package:sisterly/screens/reset_success_screen.dart';
import 'package:sisterly/screens/verify_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/constants.dart';

class ForgotScreen extends StatefulWidget {

  final String email;

  const ForgotScreen({Key? key, required this.email}) : super(key: key);

  @override
  ForgotScreenState createState() => ForgotScreenState();
}

class ForgotScreenState extends State<ForgotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailFilter = TextEditingController();

  final _formKey = GlobalKey<FormState>(debugLabel: '_forgotFormKey');


  @override
  void initState() {
    super.initState();

    precompileEmail();
  }

  precompileEmail() async {
    final email = widget.email;

    setState(() {
      _emailFilter.text = email;
    });
  }

  forgot() async {
    if (ApiManager.isEmpty(_emailFilter.text.trim())) {
      ApiManager.showErrorToast(context, "login_email_mandatory");
      return;
    }
    
    ApiManager(context).makePostRequest('/client/reset_password', {
      "email": _emailFilter.text.toLowerCase().trim()
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        forgotSuccess();
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      }
    });
  }

  forgotSuccess() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResetSuccessScreen()));
  }

  @override
  void dispose() {
    _emailFilter.dispose();
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
                          "Password dimenticata",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
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
                        "Inserisci il tuo indirizzo e-mail qui sotto per reimpostare la tua password.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text("Email",
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
                          decoration: InputDecoration(
                            hintText: "Email",
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
                            child: Text('Conferma'),
                            onPressed: () {
                              forgot();
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
