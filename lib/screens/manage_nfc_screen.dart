import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/brand.dart';
import 'package:sisterly/models/delivery_mode.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/generic.dart';
import 'package:sisterly/models/material.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/product_color.dart';
import 'package:sisterly/models/var.dart';
import 'package:sisterly/screens/add_claim_screen.dart';
import 'package:sisterly/screens/add_review_screen.dart';
import 'package:sisterly/screens/claim_success_screen.dart';
import 'package:sisterly/screens/product_edit_success_screen.dart';
import 'package:sisterly/screens/product_success_screen.dart';
import 'package:sisterly/screens/review_success_screen.dart';
import 'package:sisterly/screens/sister_advice_screen.dart';
import 'package:sisterly/screens/upload_2_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../utils/constants.dart';
import 'documents_screen.dart';
import 'order_confirm_success_screen.dart';
import 'order_return_success_screen.dart';

class ManageNfcScreen extends StatefulWidget {
  final Product? product;
  final Offer offer;

  const ManageNfcScreen({Key? key, this.product, required this.offer}) : super(key: key);

  @override
  ManageNfcScreenState createState() => ManageNfcScreenState();
}

class ManageNfcScreenState extends State<ManageNfcScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Cosa vuoi fare?"),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SvgPicture.asset("assets/images/bg-pink-ellipse.svg", width: MediaQuery.of(context).size.width,),
                        Positioned(
                          top: 60,
                          left: MediaQuery.of(context).size.width * 0.15,
                          child: Center(
                            child: SvgPicture.asset("assets/images/bag_illustration.svg",
                                width: MediaQuery.of(context).size.width * 0.7
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28,),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Constants.SECONDARY_COLOR,
                                      textStyle: const TextStyle(fontSize: 16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50))),
                                  child: Text(widget.offer.product.owner.id != SessionData().userId ? 'Conferma ricezione ordine' : 'Conferma restituzione articolo', textAlign: TextAlign.center,),
                                  onPressed: () async {
                                    confirmOrder();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Constants.SECONDARY_COLOR,
                                      textStyle: const TextStyle(fontSize: 16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 80, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50))),
                                  child: Text('Invia un reclamo',  textAlign: TextAlign.center),
                                  onPressed: () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (BuildContext context) => AddClaimScreen(product: widget.product, offer: widget.offer, isSeller: widget.offer.product.owner.id == SessionData().userId)));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    /*SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Constants.SECONDARY_COLOR,
                                textStyle: const TextStyle(fontSize: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            child: Text('Lascia una recensione',  textAlign: TextAlign.center),
                            onPressed: () async {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (BuildContext context) => AddReviewScreen(product: widget.product, offer: widget.offer,)));
                            },
                          ),
                        ),
                      ],
                    ),*/
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  confirmOrder() {
    ApiManager(context).makeGetRequest('/product/order/' + widget.offer.id.toString() + "/confirm/", {}, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => widget.offer.product.owner.id != SessionData().userId ? OrderConfirmSuccessScreen() : OrderReturnSuccessScreen()),
            (_) => false);
      }
    }, (res) {});
  }
}
