import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sisterly/utils/constants.dart';

class ChekoutOrderConfirmed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.WHITE,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: SvgPicture.asset("assets/images/close.svg", width: 18, height: 18)
                    ),
                    Center(
                      child: SvgPicture.asset("assets/images/bag_illustration.svg",
                        width: MediaQuery.of(context).size.width * 0.7
                      ),
                    ),
                    SizedBox(height: 28,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Hey Borrower Sister,",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Constants.TEXT_COLOR,
                              fontFamily: Constants.FONT,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )
                        ),
                        SizedBox(height: 15),
                        Text(
                            "Thank you for your order and for trusting the sisters!",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Constants.TEXT_COLOR,
                              fontFamily: Constants.FONT,
                              fontSize: 16,
                            )
                        ),
                        SizedBox(height: 15),
                        Wrap(
                          children: [
                            Text(
                                "Enjoy your bag, treat it with care and show us by tagging ",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Constants.TEXT_COLOR,
                                  fontFamily: Constants.FONT,
                                  fontSize: 16,
                                )
                            ),
                            GestureDetector(
                              onTap: () {

                              },
                              child: Text(
                                  "@sisterly.it",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Constants.PRIMARY_COLOR,
                                    fontFamily: Constants.FONT,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )
                              ),
                            ),
                            Text(
                                " on Instagram.",
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
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                primary: Constants.PRIMARY_COLOR,
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                                side: const BorderSide(color: Constants.PRIMARY_COLOR, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )
                            ),
                            child: Text('Return info'),
                            onPressed: () {

                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                          ),
                          child: Text('Order summary'),
                          onPressed: () {

                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
