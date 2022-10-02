import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/constants.dart';

class DocumentsSuccessScreen extends StatefulWidget {

  @override
  DocumentsSuccessScreenState createState() => DocumentsSuccessScreenState();
}

class DocumentsSuccessScreenState extends State<DocumentsSuccessScreen> {

  @override
  void initState() {
    super.initState();

  }

  next() async {
    /*Navigator.of(context, rootNavigator: false).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => UploadScreen()), (_) => false);*/
    //Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => TabScreen(startingTab: 4,)),
            (_) => false);
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
              const Text("Grazie per aver caricato i documenti",
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
                    child: Text('Avanti', textAlign: TextAlign.center,),
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
