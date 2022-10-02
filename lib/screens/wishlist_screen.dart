import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/product_screen.dart';
import 'package:sisterly/screens/reset_screen.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/screens/signup_success_screen.dart';
import 'package:sisterly/screens/verify_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/widgets/custom_app_bar.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../main.dart';
import '../utils/constants.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class WishlistScreen extends StatefulWidget {

  const WishlistScreen({Key? key}) : super(key: key);

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen>  {

  List<Product> _productsFavorite = [];
  bool _isLoading = false;
  bool _viewAll = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getProductsFavorite();
    });
  }

  getProductsFavorite() {
    setState(() {
      _isLoading = true;
    });
    ApiManager(context).makeGetRequest('/product/favorite/', {}, (res) {
      setState(() {
        _isLoading = false;
      });
      _productsFavorite = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          _productsFavorite.add(Product.fromJson(prod));
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  setProductFavorite(Product product, add) {
    var params = {
      "product_id": product.id,
      "remove": !add
    };
    ApiManager(context).makePostRequest('/product/favorite/change/', params, (res) async {
      getProductsFavorite();

      if(add) {
        await FirebaseAnalytics.instance.logAddToWishlist(
            items: [AnalyticsEventItem(itemId: product.id.toString(), itemName: product.model.toString() + " - " + product.brandName.toString())]
        );
        MyApp.facebookAppEvents.logAddToWishlist(id: product.id.toString(), type: "product", currency: "EUR", price: product.priceOffer);
      }
    }, (res) {

    });
  }

  Widget productCell(Product product) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
             MaterialPageRoute(builder: (BuildContext context) => ProductScreen(product)));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: CachedNetworkImage(
                    height: 76,
                    imageUrl: (product.images.isNotEmpty ? product.images.first.image : ""),
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg"),
                  )
                ),
                Positioned(
                  top: 10,
                  right: 10,
                    child: InkWell(
                      onTap: () {
                        setProductFavorite(product, false);
                      },
                      child: SizedBox(width: 24, height: 24, child: SvgPicture.asset("assets/images/cancel.svg")),
                    )
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.model,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    product.brandName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12,),
                  Text(
                    "${Utils.formatCurrency(product.priceOffer)} al giorno",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Constants.PRIMARY_COLOR,
                        fontSize: 18,
                        fontFamily: Constants.FONT,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 8,),
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
                          child: Text('Prenota'),
                          onPressed: () {
                            if(product.owner.holidayMode!) {
                              ApiManager.showFreeErrorMessage(context, "L'utente in questione ha attivato la modalità vacanza, non sarà possibile prenotare la borsa fino al suo rientro. Riprova tra qualche giorno");
                              return;
                            }

                            /*Navigator.of(context).push(
                                MaterialPageRoute(builder: (BuildContext context) => CheckoutScreen(product: product,)));*/
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (BuildContext context) => ProductScreen(product)));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          HeaderWidget(
            title: "Wishlist"
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          "Wishlist",
                                          style: TextStyle(
                                              color: Constants.DARK_TEXT_COLOR,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Constants.FONT
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "(" + _productsFavorite.length.toString() + " prodotti)",
                                          style: TextStyle(
                                              color: Constants.TEXT_COLOR,
                                              fontSize: 14,
                                              fontFamily: Constants.FONT
                                          ),
                                        ),
                                      ],
                                    ),
                                    if(_productsFavorite.isNotEmpty) InkWell(
                                      child: Text(
                                        _viewAll ? "Vedi meno" : "Vedi tutti",
                                        style: TextStyle(
                                            color: Constants.SECONDARY_COLOR,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: Constants.FONT,
                                            decoration: TextDecoration.underline
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _viewAll = !_viewAll;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ])
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                          child: _isLoading ? Center(child: CircularProgressIndicator()) : _productsFavorite.isNotEmpty ? MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 0.61 / 1,
                                  crossAxisCount: 2,
                                ),
                                itemCount: _viewAll ? _productsFavorite.length : (_productsFavorite.length > 4 ? 4 : _productsFavorite.length),
                                itemBuilder: (BuildContext context, int index) {
                                  return productCell(_productsFavorite[index]);
                                }
                            ),
                          ) : Text("Non ci sono prodotti nella tua lista preferiti")
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
