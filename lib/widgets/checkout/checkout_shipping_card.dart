import 'package:flutter/material.dart';
import 'package:sisterly/utils/constants.dart';

class CheckoutShippingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 10,
              blurRadius: 30,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping address",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: Constants.SECONDARY_COLOR,
                        fontFamily: Constants.FONT,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  )
                ]
            ),
            SizedBox(height: 20),
            Text(
              "Nome Cognome",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Constants.TEXT_COLOR,
                fontFamily: Constants.FONT,
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
            Text(
              "422 qwmdwqo dwqd",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Constants.TEXT_COLOR,
                fontFamily: Constants.FONT,
                fontSize: 16,
              )
            ),
            Text(
                "dqwkmdwkq, dwqdwq",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontFamily: Constants.FONT,
                  fontSize: 16,
                )
            ),
            Text(
                "Venice, Italy",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontFamily: Constants.FONT,
                  fontSize: 16,
                )
            ),
            SizedBox(height: 10),
            Text(
                "xxx@xx.xxx",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontFamily: Constants.FONT,
                  fontSize: 16,
                )
            ),
            Text(
                "+39 39201920391",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontFamily: Constants.FONT,
                  fontSize: 16,
                )
            ),
          ]
        )
    );
  }
}
