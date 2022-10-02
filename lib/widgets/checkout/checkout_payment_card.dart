import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/constants.dart';

class CheckoutPaymentCard extends StatelessWidget {
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
                      "Payment method",
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/visa.svg", width: 40),
                  SizedBox(width: 20),
                  Text(
                      "**** **** **** 1234",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Constants.TEXT_COLOR,
                        fontFamily: Constants.FONT,
                        fontSize: 16,
                      )
                  ),
                ]
              )
            ]
        )
    );
  }
}
