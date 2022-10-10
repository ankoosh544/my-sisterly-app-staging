import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info/package_info.dart';
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
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';

import '../main.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _productsFavorite = [];
  bool _isLoading = false;
  bool _isLoadingNext = false;
  bool _canAskNext = true;
  final int _pageSize = 100;
  StreamSubscription? _sub;
  final _checker = AppVersionChecker();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      initUniLinks();
      initPush();
      getProducts(false);
      getProductsFavorite();
      checkVersion();
    });
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      debugPrint("linkstream new link " + uri.toString());
      manageDeepLink(uri.toString());
    }, onError: (err) {
      debugPrint("linkstream error");
      // Handle exception by warning the user their action did not succeed
    });

    if (!SessionData().initialLinkManaged) {
      try {
        final initialLink = await getInitialLink();
        manageDeepLink(initialLink);
        SessionData().initialLinkManaged = true;
      } on PlatformException {
        // Handle exception by warning the user their action did not succeed
        // return?
      }
    }
  }

  manageDeepLink(link) {
    if (SessionData().deepLink != link) {
      debugPrint("manage link " + link.toString());

      List<String> paths = link.toString().split("/");

      ApiManager(context).makeGetRequest('/product/' + paths.last + '/', {},
          (res) {
        if (res["errors"] != null) {
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        } else {
          SessionData().deepLink = null;
          Product prod = Product.fromJson(res["data"]);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ProductScreen(prod)));
        }
      }, (res) {
        if (res["errors"] != null) {
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        }
      });
    }

    SessionData().deepLink = link;
  }

  checkVersion() {
    _checker.checkUpdate().then((value) async {
      debugPrint(
          value.canUpdate.toString()); //return true if update is available

      debugPrint(value.currentVersion.toString()); //return current app version
      debugPrint(value.newVersion.toString()); //return the new app version
      debugPrint(value.appURL.toString()); //return the app url
      debugPrint(value.errorMessage
          .toString()); //return error message if found else it will return null
      if (value.canUpdate) {
        debugPrint("please update");
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
              title: Text("Aggiornamento richiesto"),
              content: Text(
                  "Per continuare ad utilizzare Sisterly, aggiorna la app."),
              actions: [
                ElevatedButton(
                    child: Text("Aggiorna ora"),
                    onPressed: () {
                      if (Platform.isIOS) {
                        Utils.launchBrowserURL(
                            "https://apps.apple.com/it/app/sisterly/id1595106946?l=en");
                      } else {
                        Utils.launchBrowserURL(
                            "https://play.google.com/store/apps/details?id=com.sisterly.sisterly");
                      }
                    }),
              ]),
        );
      }
    });
  }

  initPush() async {
    Utils.enablePush(context, false);
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ProductScreen(product)));
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
                        borderRadius: BorderRadius.circular(15)),
                    // child: Image.asset("assets/images/product.png", height: 169,),
                    child: CachedNetworkImage(
                      height: 169,
                      imageUrl: (product.images.isNotEmpty
                          ? product.images.first.image
                          : ""),
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => SvgPicture.asset(
                          "assets/images/placeholder_product.svg"),
                    ),
                  ),
                  Positioned(
                      top: 12,
                      right: 12,
                      child: isFavorite(product)
                          ? InkWell(
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: SvgPicture.asset(
                                      "assets/images/saved.svg")),
                              onTap: () {
                                setProductFavorite(product, false);
                              },
                            )
                          : InkWell(
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: SvgPicture.asset(
                                      "assets/images/save.svg")),
                              onTap: () {
                                setProductFavorite(product, true);
                              },
                            )),
                  if (product.useDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: InkWell(
                          onTap: () {
                            ApiManager.showFreeSuccessMessage(context,
                                "Questa borsa partecipa alle promozioni Sisterly");
                          },
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: Icon(
                                Icons.percent_sharp,
                                color: Constants.SECONDARY_COLOR,
                              ))),
                    )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.model.toString() +
                        " - " +
                        product.brandName.toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontSize: 16,
                    ),
                  ),
                  if (product.location != null)
                    Text(
                      product.location!.city.capitalize(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Constants.TEXT_COLOR,
                        fontFamily: Constants.FONT,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
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
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 8,
                  ),
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

  getProducts(nextPage) {
    setState(() {
      if (!nextPage) _isLoading = true;
      if (nextPage) _isLoadingNext = true;
    });
    var params = {"start": nextPage ? _products.length : 0, "count": _pageSize};
    ApiManager(context).makeGetRequest('/product/', params, (res) {
      // print(res);

      if (!nextPage) {
        _products = [];
      }

      var data = res["data"];
      if (data != null) {
        if (data.length == 0) {
          _canAskNext = false;
        } else {
          _canAskNext = true;

          for (var prod in data) {
            _products.add(Product.fromJson(prod));
          }
        }
      }

      setState(() {
        _isLoading = false;
        _isLoadingNext = false;
      });
    }, (res) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingNext = false;
        });
      }
    });
  }

  isFavorite(product) {
    return _productsFavorite
        .where((element) => element.id == product.id)
        .isNotEmpty;
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

      setState(() {});
    }, (res) {});
  }

  setProductFavorite(product, add) {
    var params = {"product_id": product.id, "remove": !add};
    ApiManager(context).makePostRequest('/product/favorite/change/', params,
        (res) async {
      getProductsFavorite();

      if (add) {
        await FirebaseAnalytics.instance.logAddToWishlist(items: [
          AnalyticsEventItem(
              itemId: product.id.toString(),
              itemName: product.model.toString() +
                  " - " +
                  product.brandName.toString())
        ]);
        MyApp.facebookAppEvents.logAddToWishlist(
            id: product.id.toString(),
            type: "product",
            currency: "EUR",
            price: product.priceOffer);
      }
    }, (res) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(
            title: "Home",
            leftWidget: InkWell(
              child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Color(0xff337a9d),
                      borderRadius: BorderRadius.circular(42)),
                  child: SizedBox(
                      width: 70,
                      height: 40,
                      child: SvgPicture.asset("assets/images/saved_white.svg",
                          width: 19, height: 19, fit: BoxFit.scaleDown))),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => WishlistScreen()));
              },
            ),
            rightWidget: InkWell(
              child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Color(0xff337a9d),
                      borderRadius: BorderRadius.circular(42)),
                  child: SizedBox(
                      width: 17,
                      height: 19,
                      child: SvgPicture.asset(
                        "assets/images/nfc.svg",
                        width: 17,
                        height: 19,
                        fit: BoxFit.scaleDown,
                      ))),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => NfcScreen()));
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
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async {
                          getProducts(false);
                          getProductsFavorite();
                        },
                        child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: _products.length + (_canAskNext ? 1 : 0),
                            itemBuilder: (BuildContext context, int index) {
                              if (index < _products.length)
                                return productCell(_products[index]);

                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Constants.SECONDARY_COLOR,
                                        textStyle:
                                            const TextStyle(fontSize: 16),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 46, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50))),
                                    child: Text('Carica altri...'),
                                    onPressed: () async {
                                      getProducts(true);
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
