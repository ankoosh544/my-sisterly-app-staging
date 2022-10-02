import 'package:flutter/material.dart';

class ErrorLayout extends StatelessWidget {

  final String text;
  final Color color;

  const ErrorLayout({Key? key, this.text = "Non ci sono elementi", this.color = Colors.red}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: [
              SizedBox(height: 15,),
            ],
          ),
          Icon(
            Icons.error,
            size: 80,
            color: color,
          ),
          const SizedBox(height: 15,),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}
