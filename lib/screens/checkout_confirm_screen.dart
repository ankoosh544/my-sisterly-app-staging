import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/widgets/checkout/checkout_payment_card.dart';
import 'package:sisterly/widgets/checkout/checkout_product_card.dart';
import 'package:sisterly/widgets/checkout/checkout_shipping_card.dart';

import 'chekout_order_confirmed.dart';

class CheckoutConfirmScreen extends StatefulWidget {

  final Product product;

  CheckoutConfirmScreen({Key? key, required this.product}) : super(key: key);

  @override
  _CheckoutConfirmScreenState createState() => _CheckoutConfirmScreenState();
}

class _CheckoutConfirmScreenState extends State<CheckoutConfirmScreen> {
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
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: InkWell(
                              child: SizedBox(child: SvgPicture.asset("assets/images/back.svg")),
                              onTap: () {
                                Navigator.of(context).pop();
                              }
                          )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.FONT),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 17)
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutProductCard(product: widget.product,),
                      SizedBox(height: 10),
                      CheckoutShippingCard(),
                      SizedBox(height: 10),
                      CheckoutPaymentCard(),

                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                              "Subtotal",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontSize: 16,
                              )
                          ),Text(
                              "€ 217.00",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontSize: 16,
                              )
                          ),
                        ]
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                              "Shipping",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontSize: 16,
                              )
                          ),Text(
                              "€ 7.99",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontSize: 16,
                              )
                          ),
                        ]
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                              "Total",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )
                          ),Text(
                              "€ 220.99",
                              style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontFamily: Constants.FONT,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              )
                          ),
                        ]
                      ),

                      SizedBox(height: 35),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                          ),
                          child: Text('Confirm Order'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChekoutOrderConfirmed()));
                          },
                        ),
                      ),
                      SizedBox(height: 35)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget checkoutPaymentCard() {
    return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 6,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Image.asset("assets/images/product.png", height: 76,),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Chain-Cassette Bottega",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontFamily: Constants.FONT,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "€30 per day",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Constants.PRIMARY_COLOR,
                              fontSize: 18,
                              fontFamily: Constants.FONT,
                              fontWeight: FontWeight.bold
                          ),
                        )
                      ]
                  ),
                ),
              )
            ]
        )
    );
  }
}