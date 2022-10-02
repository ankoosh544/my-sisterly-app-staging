import 'package:flutter/material.dart';

class EmptyLayout extends StatelessWidget {

  final String? text;
  final String? imageName;
  final Color? color;
  final IconData? icon;

  const EmptyLayout({
    Key? key,
    this.text = "Non ci sono elementi",
    this.color,
    this.imageName,
    this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30,),
          icon != null ? Icon(
            icon,
            color: color != null ? color : Colors.white,
            size: 60,
          ) : Opacity(
            opacity: 0.7,
            child: Image(
              image: AssetImage(imageName!),
              width: 80,
              height: 50,
            ),
          ),
          const SizedBox(height: 20,),
          Text(
            text!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color != null ? color : Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16,)
        ],
      ),
    );
  }
}
