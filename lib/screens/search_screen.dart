import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/filters.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/nfc_screen.dart';
import 'package:sisterly/screens/product_screen.dart';
import 'package:sisterly/screens/wishlist_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../main.dart';
import '../utils/constants.dart';
import 'filters_screen.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>  {

  List<Product> _products = [];
  List<Product> _productsFavorite = [];
  bool _isLoading = false;
  Filters _filters = Filters();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getProducts();
      getProductsFavorite();

      showFilters();
    });
  }

  showFilters() async {
    var results = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: FiltersScreen(filters: _filters,)
        )
    );

    if(results == null) {
      _filters = Filters();
    } else {
      _filters = results;
    }

    getProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget productCell(Product product) {
    return Column(
      children: [
        SizedBox(height: 20),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) => ProductScreen(product)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Color(0xfff5f5f5),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    // child: Image.asset("assets/images/product.png", height: 169,),
                    child: CachedNetworkImage(
                      height: 169,
                      imageUrl: (product.images.isNotEmpty ? product.images.first.image : ""),
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg"),
                    ),
                  ),
                  Positioned(
                      top: 12,
                      right: 12,
                      child: isFavorite(product) ? InkWell(
                        child: SizedBox(width: 18, height: 18, child: SvgPicture.asset("assets/images/saved.svg")),
                        onTap: () {
                          setProductFavorite(product, false);
                        },
                      ) : InkWell(
                        child: SizedBox(width: 18, height: 18, child: SvgPicture.asset("assets/images/save.svg")),
                        onTap: () {
                          setProductFavorite(product, true);
                        },
                      )
                  ),
                  if(product.useDiscount) Positioned(
                    top: 12,
                    left: 12,
                    child: InkWell(
                        onTap: () {
                          ApiManager.showFreeSuccessMessage(context, "Questa borsa partecipa alle promozioni Sisterly");
                        },
                        child: SizedBox(width: 18, height: 18, child: Icon(Icons.percent_sharp, color: Constants.SECONDARY_COLOR,))
                    ),
                  )
                ],
              ),
              SizedBox(height: 16,),
              Text(
                product.model.toString() + " - " + product.brandName.toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontFamily: Constants.FONT,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  SizedBox(width: 8,),
                  Text(
                    "${Utils.formatCurrency(product.sellingPrice)}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.PRIMARY_COLOR,
                      fontSize: 18,
                      fontFamily: Constants.FONT,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  isFavorite(product) {
    return _productsFavorite.where((element) => element.id == product.id).isNotEmpty;
  }

  getProducts() {
    var params = {};

    if(_filters.model != null && _filters.model!.isNotEmpty) {
      params["model"] = _filters.model;
    }

    if(_filters.brand != null) {
      params["id_brands"] = [_filters.brand];
    }

    if(_filters.category != null) {
      params["id_categories"] = [_filters.category];
    }

    if(_filters.conditions.isNotEmpty) {
      params["conditions"] = _filters.conditions;
    }

    if(_filters.deliveryModes.isNotEmpty) {
      params["delivery_mode"] = _filters.deliveryModes;
    }

    if(_filters.colors.isNotEmpty) {
      params["id_colors"] = _filters.colors;
    }

    if(_filters.onlySameCity) {
      params["same_city"] = true;
    }

    params["max_price"] = _filters.maxPrice;

    params["start"] = 0;
    params["count"] = 2000;

    if(_filters.availableFrom != null && _filters.availableTo != null) {
      params["start_date"] = DateFormat("yyyy-MM-dd").format(_filters.availableFrom!);
      params["end_date"] = DateFormat("yyyy-MM-dd").format(_filters.availableTo!);
    }

    setState(() {
      _isLoading = true;
    });
    ApiManager(context).makePostRequest('/product/search/', params, (res) {
      // print(res);
      _products = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          _products.add(Product.fromJson(prod));
        }
      }

      setState(() {
        _isLoading = false;
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  getProductsFavorite() {
    ApiManager(context).makeGetRequest('/product/favorite/', {}, (res) {
      _productsFavorite = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          _productsFavorite.add(Product.fromJson(prod));
        }
      }

      setState(() {

      });
    }, (res) {

    });
  }

  setProductFavorite(product, add) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(
            title: "Prodotti",
            leftWidget: InkWell(
              child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Color(0xff337a9d),
                      borderRadius: BorderRadius.circular(42)
                  ),
                  child: SizedBox(width: 70, height: 40, child: SvgPicture.asset("assets/images/saved_white.svg", width: 19, height: 19, fit: BoxFit.scaleDown))
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WishlistScreen()));
              },
            ),
            rightWidget: InkWell(
              child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Color(0xff337a9d),
                      borderRadius: BorderRadius.circular(42)
                  ),
                  child: SizedBox(width: 17, height: 19, child: SvgPicture.asset("assets/images/search_white.svg", width: 17, height: 19, fit: BoxFit.scaleDown,))
              ),
              onTap: () {
                showFilters();
              },
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(_filters.areSet()) InkWell(
                        onTap: () {
                          setState(() {
                            _filters = Filters();
                          });

                          getProducts();
                        },
                        child: Align(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SvgPicture.asset("assets/images/cancel.svg"),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Rimuovi filtri",
                                  style: TextStyle(
                                    color: Constants.SECONDARY_COLOR,
                                    fontFamily: Constants.FONT
                                  ),
                                ),
                              ),
                            ],
                          ),
                          alignment: Alignment.topRight,
                        ),
                      ),
                      for (var prod in _products) productCell(prod)
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
