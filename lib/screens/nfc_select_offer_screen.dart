import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/manage_nfc_screen.dart';
import 'package:sisterly/screens/nfc_choose_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

class NfcSelectOfferScreen extends StatefulWidget {

  final int productId;

  const NfcSelectOfferScreen({Key? key, required this.productId}) : super(key: key);

  @override
  NfcSelectOfferScreenState createState() => NfcSelectOfferScreenState();
}

class NfcSelectOfferScreenState extends State<NfcSelectOfferScreen>  {

  bool _isLoading = false;
  List<Offer> _offers = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getOffers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getOffers() {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeGetRequest("/product/" + widget.productId.toString() + "/offer/nfc", {}, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _offers = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          var offer = Offer.fromJson(prod);
          _offers.add(offer);
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget offerCell(Offer offer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Richiesta #" + offer.id.toString(),
              style: TextStyle(
                color: Constants.PRIMARY_COLOR,
                fontSize: 18,
                fontFamily: Constants.FONT,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 4,),
            Text(
              "dal " + DateFormat("dd MMM yyyy").format(offer.dateStart) + " al " + DateFormat("dd MMM yyyy").format(offer.dateEnd),
              style: TextStyle(
                  color: Constants.LIGHT_GREY_COLOR,
                  fontSize: 14,
                  fontFamily: Constants.FONT
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(id: offer.user.id)));
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(68.0),
                    child: CachedNetworkImage(
                      width: 48, height: 48, fit: BoxFit.cover,
                      imageUrl: (offer.user.image ?? ""),
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder.svg"),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Creata da " + offer.user.firstName!.capitalize() + " " + offer.user.lastName!.substring(0, 1).toUpperCase() + ".",
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 4,),
                      /*Text(
                                    "Milano",
                                    style: TextStyle(
                                        color: Constants.LIGHT_TEXT_COLOR,
                                        fontSize: 14,
                                        fontFamily: Constants.FONT
                                    ),
                                  ),*/
                      SizedBox(height: 4,),
                      Wrap(
                        spacing: 3,
                        children: [
                          StarsWidget(stars: offer.user.reviewsMedia!.toInt()),
                          Text(
                            offer.product.owner.reviewsMedia.toString(),
                            style: TextStyle(
                                color: Constants.DARK_TEXT_COLOR,
                                fontSize: 14,
                                fontFamily: Constants.FONT
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    width: 127,
                    height: 96,
                    fit: BoxFit.contain,
                    imageUrl: offer.product.images.first.image,
                    placeholder: (context, url) => SvgPicture.asset("assets/images/placeholder_product.svg",),
                    errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg",),
                  ),
                ),
                SizedBox(width: 8,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.product.model,
                      style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                          fontFamily: Constants.FONT
                      ),
                    ),
                    SizedBox(height: 4,),
                    Text(
                      offer.product.brandName,
                      style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                          fontFamily: Constants.FONT
                      ),
                    ),
                    SizedBox(height: 12,),
                    Text(
                      "${Utils.formatCurrency(offer.product.priceOffer)} al giorno",
                      style: TextStyle(
                          color: Constants.PRIMARY_COLOR,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.FONT
                      ),
                    ),
                  ],
                )
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Constants.SECONDARY_COLOR,
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text('Seleziona'),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) => ManageNfcScreen(offer: offer, product: offer.product,)));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Seleziona il noleggio"),
          SizedBox(height: 16,),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _isLoading ? Center(child: CircularProgressIndicator()) : _offers.isNotEmpty ? MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _offers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return offerCell(_offers[index]);
                              }
                            ),
                          ) : Center(child: Text("Non ci sono richieste qui")),
                        ),
                      ),
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
}
