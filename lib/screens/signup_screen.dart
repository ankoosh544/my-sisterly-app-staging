import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/main.dart';
import 'package:sisterly/screens/signup_success_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sisterly/utils/session_data.dart';

import '../utils/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SignupScreen extends StatefulWidget {
  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDayText = TextEditingController();
  final TextEditingController _birthMonthText = TextEditingController();
  final TextEditingController _birthYearText = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'IT');
  DateTime? birthday;

  //final FocusNode _passwordFocus = new FocusNode();
  final _formKey = GlobalKey<FormState>(debugLabel: '_signupFormKey');

  bool _showPassword = false;
  bool _terms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  signup() async {
    if (ApiManager.isEmpty(_firstNameController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_first_name_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_lastNameController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_last_name_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_phoneController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_phome_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_usernameController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_username_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_emailController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_email_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_passwordController.text.trim())) {
      ApiManager.showErrorToast(context, "signup_password_mandatory");
      return;
    }

    if (birthday == null) {
      ApiManager.showErrorToast(context, "signup_birthday_mandatory");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _usernameController.text = _usernameController.text.toLowerCase().trim();
    _emailController.text = _emailController.text.toLowerCase().trim();

    ApiManager(context).signup(
        _emailController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
        _phoneController.text.trim(),
        DateFormat("yyyy-MM-dd").format(birthday!), (response) async {
      setState(() {
        _isLoading = false;
      });

      if (response["data"] != null) {
        debugPrint("signup success");

        var data = response["data"];
        debugPrint(data.toString());
        var preferences = await SharedPreferences.getInstance();
        SessionData().token = data["access"];

        signupSuccess();
      } else {
        ApiManager.showFreeErrorToast(context, response["errors"].toString());
      }
    }, (statusCode) {
      setState(() {
        _isLoading = false;
      });
      ApiManager.showErrorMessage(context, "generic_error");
      debugPrint("login failure");
    });
  }

  signupSuccess() async {
    await FirebaseAnalytics.instance.logSignUp(signUpMethod: "email");
    MyApp.facebookAppEvents
        .logCompletedRegistration(registrationMethod: "email");

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => SignupSuccessScreen()),
        (_) => false);
  }

  setBirthDate(DateTime date) {
    _birthDayText.text = date.day.toString();
    _birthMonthText.text = date.month.toString();
    _birthYearText.text = date.year.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
                          "Registrati",
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
            child: SingleChildScrollView(
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
                        const SizedBox(height: 25),
                        const Text("Nome",
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
                            keyboardType: TextInputType.name,
                            cursorColor: Constants.PRIMARY_COLOR,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Constants.FORM_TEXT,
                            ),
                            decoration: InputDecoration(
                              hintText: "Nome",
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
                            controller: _firstNameController,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text("Cognome",
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
                            keyboardType: TextInputType.name,
                            cursorColor: Constants.PRIMARY_COLOR,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Constants.FORM_TEXT,
                            ),
                            decoration: InputDecoration(
                              hintText: "Cognome",
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
                            controller: _lastNameController,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text("Cellulare",
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
                          child: InternationalPhoneNumberInput(
                            ignoreBlank: true,
                            formatInput: false,
                            selectorConfig: SelectorConfig(
                                setSelectorButtonAsPrefixIcon: true,
                                showFlags: true,
                                selectorType: PhoneInputSelectorType.DROPDOWN),
                            onInputChanged: (PhoneNumber number) {
                              this.number = number;
                              //debugPrint("dialCode "+number.dialCode);
                            },
                            onInputValidated: (bool value) {},
                            spaceBetweenSelectorAndTextField: 0,
                            initialValue: number,
                            keyboardType: TextInputType.number,
                            textFieldController: _phoneController,
                            textStyle: TextStyle(
                                fontSize: 16, color: Constants.PRIMARY_COLOR),
                            selectorTextStyle: TextStyle(
                                fontSize: 16, color: Constants.PRIMARY_COLOR),
                            inputDecoration: InputDecoration(
                              hintText: "Cellulare",
                              hintStyle: const TextStyle(
                                  color: Constants.PLACEHOLDER_COLOR),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              filled: true,
                              fillColor: Constants.WHITE,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text("Username",
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
                              _usernameController.value = TextEditingValue(
                                  text: value.toLowerCase(),
                                  selection: _usernameController.selection);
                            },
                            decoration: InputDecoration(
                              hintText: "Username",
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
                            controller: _usernameController,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Data di nascita",
                          style: TextStyle(
                              color: Constants.TEXT_COLOR,
                              fontSize: 16,
                              fontFamily: Constants.FONT),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        InkWell(
                          onTap: () async {
                            debugPrint("show date picker");
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  birthday != null ? birthday! : DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(Duration(days: 150 * 365)),
                              lastDate: DateTime.now(),
                            );

                            setState(() {
                              if (picked != null) {
                                birthday = picked;

                                setBirthDate(picked);
                              }
                            });
                          },
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x4ca3c4d4),
                                          spreadRadius: 2,
                                          blurRadius: 15,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      cursorColor: Constants.PRIMARY_COLOR,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Constants.FORM_TEXT,
                                      ),
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: "gg",
                                        hintStyle: const TextStyle(
                                            color: Constants.PLACEHOLDER_COLOR),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        suffixIcon: SvgPicture.asset(
                                            "assets/images/arrow_down.svg",
                                            width: 10,
                                            height: 6,
                                            fit: BoxFit.scaleDown),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        filled: true,
                                        fillColor: Constants.WHITE,
                                      ),
                                      controller: _birthDayText,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x4ca3c4d4),
                                          spreadRadius: 2,
                                          blurRadius: 15,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      cursorColor: Constants.PRIMARY_COLOR,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Constants.FORM_TEXT,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "mm",
                                        hintStyle: const TextStyle(
                                            color: Constants.PLACEHOLDER_COLOR),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        suffixIcon: SvgPicture.asset(
                                            "assets/images/arrow_down.svg",
                                            width: 10,
                                            height: 6,
                                            fit: BoxFit.scaleDown),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        filled: true,
                                        fillColor: Constants.WHITE,
                                      ),
                                      controller: _birthMonthText,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x4ca3c4d4),
                                          spreadRadius: 2,
                                          blurRadius: 15,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      cursorColor: Constants.PRIMARY_COLOR,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Constants.FORM_TEXT,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "aaaa",
                                        hintStyle: const TextStyle(
                                            color: Constants.PLACEHOLDER_COLOR),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        suffixIcon: SvgPicture.asset(
                                            "assets/images/arrow_down.svg",
                                            width: 10,
                                            height: 6,
                                            fit: BoxFit.scaleDown),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        filled: true,
                                        fillColor: Constants.WHITE,
                                      ),
                                      controller: _birthYearText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
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
                            onChanged: (value) {
                              _emailController.value = TextEditingValue(
                                  text: value.toLowerCase(),
                                  selection: _emailController.selection);
                            },
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
                            controller: _emailController,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text("Crea Password",
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
                            controller: _passwordController,
                            onSubmitted: (s) {},
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Color(0xff92a0a7),
                                ),
                                child: Checkbox(
                                    value: _terms,
                                    activeColor: Constants.PRIMARY_COLOR,
                                    onChanged: (value) {
                                      setState(() {
                                        _terms = value!;
                                      });
                                    }),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                  text: TextSpan(
                                //style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        "Registrandoti dichiari di aver letto e accettato i ",
                                    style: TextStyle(
                                        color: Color(0xff92a0a7),
                                        fontSize: 16,
                                        fontFamily: Constants.FONT),
                                  ),
                                  TextSpan(
                                    text: "termini e condizioni.",
                                    style: TextStyle(
                                        color: Constants.PRIMARY_COLOR,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.FONT),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        String url =
                                            "https://sisterly-assets.s3.eu-central-1.amazonaws.com/T%26C+Sisterly+rev1.pdf";
                                        launch(url);
                                      },
                                  ),
                                ],
                              )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 24,
                        ),
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
                                    child: Text('Conferma'),
                                    onPressed: () {
                                      signup();
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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
