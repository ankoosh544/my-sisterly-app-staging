import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/constants.dart';

class ClaimSuccessScreen extends StatefulWidget {

  @override
  ClaimSuccessScreenState createState() => ClaimSuccessScreenState();
}

class ClaimSuccessScreenState extends State<ClaimSuccessScreen> {

  @override
  void initState() {
    super.initState();

  }

  next() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => TabScreen()), (_) => false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                child: SizedBox(),
              ),
              Text(
                "Hey Sister",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              const Text("Grazie per aver inviato un reclamo",
                  style: TextStyle(
                    color: Constants.TEXT_COLOR,
                    fontSize: 16,
                    fontFamily: Constants.FONT,
                  ),
                textAlign: TextAlign.center,
              ),
              const Expanded(
                child: SizedBox(),
              ),
              SvgPicture.asset("assets/images/success.svg"),
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
                    child: Text('Vai alla home'),
                    onPressed: () {
                      next();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
