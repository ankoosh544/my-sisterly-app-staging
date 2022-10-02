import 'package:flutter/material.dart';
import 'package:sisterly/utils/constants.dart';

class CustomProgressIndicator extends StatelessWidget {

  final Color progressColor;
  final double size;
  final double padding;

  const CustomProgressIndicator({
    Key? key,
    this.progressColor = Constants.PRIMARY_COLOR,
    this.size = 40.0,
    this.padding = 16.0}
    ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
          child: SizedBox(
              height: size,
              width: size,
              child:
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(progressColor != null ? progressColor : Theme.of(context).primaryColor),
                  strokeWidth: 3.0)
          ),
        ),
    );
    }
}
