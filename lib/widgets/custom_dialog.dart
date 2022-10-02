import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/localization/app_localizations.dart';

class CustomDialog extends StatelessWidget {

  final double? width;
  final double? padding;
  final String? title;
  final Widget? content;

  const CustomDialog({Key? key, this.title, this.content, this.width = 300, this.padding = 16}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Container(
          height: 40,
          width: width,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color: Colors.transparent
              ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: SizedBox()
              ),
              IconButton(
                  icon: const Icon(Icons.close, color: Constants.WHITE, size: 40,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              )
            ],
          ),
        ),
        contentPadding: EdgeInsets.all(padding!),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Constants.PRIMARY_COLOR,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)
                  )
              ),
                width: width,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.of(context).translate(title!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Constants.WHITE,
                        fontFamily: Constants.FONT,
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
            ),
            Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Constants.WHITE,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)
                    )
                ),
                width: width,
                child: content
            ),
          ],
        )
    );
  }
}
