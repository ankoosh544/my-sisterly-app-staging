import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/offers_contract_buyer_screen.dart';
import 'package:sisterly/screens/offers_contract_seller_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/screens/stripe_webview_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

import 'order_details_screen.dart';

enum OffersScreenMode {
  received, sent
}

class OffersHistoryScreen extends StatefulWidget {

  const OffersHistoryScreen({Key? key}) : super(key: key);

  @override
  OffersHistoryScreenState createState() => OffersHistoryScreenState();
}

class OffersHistoryScreenState extends State<OffersHistoryScreen>  {

  bool _isLoading = false;
  List<Offer> _offers = [];
  OffersScreenMode _mode = OffersScreenMode.sent;

  bool _isLoadingNext = false;
  bool _canAskNext = true;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getOffers(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getOffers(nextPage) {
    setState(() {
      if(!nextPage) _isLoading = true;
      if(nextPage) _isLoadingNext = true;
    });

    ApiManager(context).makeGetRequest(_mode == OffersScreenMode.received ? "/product/order/received" : "/product/order/made", { "count": _pageSize, "mode": "history", "start": nextPage ? _offers.length : 0 }, (res) {
      if(!nextPage) {
        _offers = [];
      }

      var data = res["data"];
      if (data != null) {
        if(data.length == 0) {
          _canAskNext = false;
        } else {
          _canAskNext = true;

          for (var off in data) {
            _offers.add(Offer.fromJson(off));
          }
        }
      }

      debugPrint("_orders "+_offers.length.toString());

      setState(() {
        _isLoading = false;
        _isLoadingNext = false;
      });
    }, (res) {
      _offers = [];
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Richiesta #" + offer.id.toString(),
                    style: TextStyle(
                      color: Constants.PRIMARY_COLOR,
                      fontSize: 18,
                      fontFamily: Constants.FONT,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                if(isDeleteable(offer)) InkWell(
                  onTap: () {
                    delete(offer);
                  },
                    child: SvgPicture.asset("assets/images/cancel.svg", width: 40, height: 40,)
                ),
              ],
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
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg",),
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: Column(
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
                  ),
                )
              ],
            ),
            if(_mode == OffersScreenMode.received && canProcess(offer)) Divider(),
            if(_mode == OffersScreenMode.received && canProcess(offer)) Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
                    child: Text('Rifiuta'),
                    onPressed: () {
                      reject(offer);
                    },
                  ),
                ),
                SizedBox(width: 16,),
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
                    child: Text('Accetta'),
                    onPressed: () {
                      askAccept(offer);
                    },
                  ),
                ),
              ],
            ),
            if(_mode == OffersScreenMode.received && canProcess(offer)) Divider(),
            if(_mode == OffersScreenMode.sent && canPay(offer)) Divider(),
            if(_mode == OffersScreenMode.sent && canPay(offer)) Row(
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
                    child: Text('Paga ora'),
                    onPressed: () {
                      askPay(offer);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                getOfferStatusName(offer),
                style: TextStyle(
                    color: Constants.TEXT_COLOR,
                    fontSize: 16,
                    fontFamily: Constants.FONT,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getOfferStatusName(Offer offer) {
    switch(offer.state.id) {
      case 1: return "In attesa di accettazione";
      case 2: return "In attesa di pagamento";
      case 3: return "Pagamento in corso";
      case 4: return "Pagato";
      case 5: return "Preso in prestito";
      case 6: return "Chiuso";
      case 7: return "Rifiutato";
      case 31: return "In attesa di accettazione";
      default: return "";
    }
  }

  isDeleteable(Offer offer) {
    if(_mode != OffersScreenMode.sent) return false;
    switch(offer.state.id) {
      case 1: return true;
      default: return false;
    }
  }

  canProcess(Offer offer) {
    switch(offer.state.id) {
      case 1: return true;
      case 31: return true;
      default: return false;
    }
  }

  canPay(Offer offer) {
    switch(offer.state.id) {
      case 2: return true;
      default: return false;
    }
  }

  delete(Offer offer) {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeDeleteRequest("/product/order/" + offer.id.toString(), (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      ApiManager.showFreeSuccessMessage(context, "Richiesta di noleggio eliminata!");

      getOffers(false);
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  reject(Offer offer) {
    setState(() {
      _isLoading = true;
    });

    var params = {
      "order_id": offer.id,
      "result": false
    };

    ApiManager(context).makePostRequest("/product/" + offer.product.id.toString() + "/offer/", params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      ApiManager.showFreeSuccessMessage(context, "Richiesta di noleggio rifiutata!");

      getOffers(false);
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  askAccept(Offer offer) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => OffersContractSellerScreen(offer: offer)));

    getOffers(false);
  }

  askPay(Offer offer) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => OffersContractBuyerScreen(offer: offer)));

    getOffers(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Storico richieste"),
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
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 10,
                              blurRadius: 30,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: _mode == OffersScreenMode.sent ? Constants.PRIMARY_COLOR : Colors.white,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                              ),
                              child: Text('Inviate', style: TextStyle(color: _mode == OffersScreenMode.sent ? Colors.white : Constants.TEXT_COLOR),),
                              onPressed: () {
                                setState(() {
                                  _mode = OffersScreenMode.sent;

                                  getOffers(false);
                                });
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: _mode == OffersScreenMode.received ? Constants.PRIMARY_COLOR : Colors.white,
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                              ),
                              child: Text('Ricevute', style: TextStyle(color: _mode == OffersScreenMode.received ? Colors.white : Constants.TEXT_COLOR),),
                              onPressed: () {
                                setState(() {
                                  _mode = OffersScreenMode.received;

                                  getOffers(false);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _isLoading ? Center(child: CircularProgressIndicator()) : _offers.isNotEmpty ? MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _offers.length  + (_canAskNext ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) {
                                if(index < _offers.length) return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (BuildContext context) => OrderDetailsScreen(offer: _offers[index])));
                                    },
                                    child: offerCell(_offers[index])
                                );

                                return Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Constants.SECONDARY_COLOR,
                                          textStyle: const TextStyle(fontSize: 16),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 46, vertical: 14),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50))),
                                      child: Text('Carica altri...'),
                                      onPressed: () async {
                                        getOffers(true);
                                      },
                                    ),
                                  ),
                                );
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
