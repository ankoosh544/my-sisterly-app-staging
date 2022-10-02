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

class AddReviewScreen extends StatefulWidget {
  final Product? product;
  final Offer? offer;

  const AddReviewScreen({Key? key, this.product, this.offer}) : super(key: key);

  @override
  AddReviewScreenState createState() => AddReviewScreenState();
}

class AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _descriptionText = TextEditingController();
  int _stars = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {});
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
          HeaderWidget(title: "Recensione"),
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        "Lascia una recensione",
                        // per il prodotto " + widget.product!.model.toString(),
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Commento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4ca3c4d4),
                              spreadRadius: 8,
                              blurRadius: 12,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          cursorColor: Constants.PRIMARY_COLOR,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.FORM_TEXT,
                          ),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                "Lender puntuale e disponibile / Borsa perfetta e conforme alla descrizione / Consigliata per outfit da giorno / Peccato debba restituirla, è stato un sogno!",
                            hintStyle: const TextStyle(
                                color: Constants.PLACEHOLDER_COLOR),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor: Constants.WHITE,
                          ),
                          controller: _descriptionText,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Dai una valutazione da 0 a 5",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        glow: false,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) =>
                            SvgPicture.asset("assets/images/star.svg"),
                        onRatingUpdate: (rating) {
                          print(rating);
                          _stars = rating.toInt();
                        },
                      ),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Invia'),
                          onPressed: () async {
                            next();
                          },
                        ),
                      ),
                      SizedBox(height: 60),
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

  next() {
    debugPrint("next");
    if (_descriptionText.text.isEmpty) {
      ApiManager.showFreeErrorToast(context, "Inserisci un commento");
      return;
    }

    var params = {"stars": _stars, "description": _descriptionText.text.toString()};

    ApiManager(context).makePutRequest('/product/' + widget.product!.id.toString() + '/order/'+ widget.offer!.id.toString() + '/reviews', params, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => ReviewSuccessScreen()),
            (_) => false);
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      }
    });
  }
}
