import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/info_screen.dart';

import 'package:sisterly/screens/order_details_screen.dart';
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

enum OrdersScreenMode { received, sent }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;
  List<Offer> _orders = [];
  OrdersScreenMode _mode = OrdersScreenMode.received;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getOrders();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getOrders() {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeGetRequest(
        _mode == OrdersScreenMode.received
            ? "/product/offers"
            : "/product/cart",
        {}, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _orders = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          var order = Offer.fromJson(prod);
          if (isOrder(order)) {
            _orders.add(order);
          }
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  isOrder(Offer offer) {
    switch (offer.state.id) {
      case 4:
        return true;
      case 5:
        return true;
      case 6:
        return true;
      default:
        return false;
    }
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
                    "Ordine #" + offer.id.toString(),
                    style: TextStyle(
                        color: Constants.PRIMARY_COLOR,
                        fontSize: 18,
                        fontFamily: Constants.FONT,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                    onTap: () async {
                      final Event event = Event(
                          title: 'Sisterly: prenotazione #' +
                              offer.id.toString() +
                              " per " +
                              offer.product.model.toString(),
                          description: 'Ordine #' +
                              offer.id.toString() +
                              " per il prodotto " +
                              offer.product.model.toString(),
                          startDate: offer.dateStart,
                          endDate: offer.dateEnd);
                      await Add2Calendar.addEvent2Cal(event);
                      ApiManager.showFreeSuccessMessage(
                          context, "Noleggio aggiunto al tuo calendario");
                    },
                    child: Icon(
                      Icons.calendar_today,
                      color: Constants.SECONDARY_COLOR,
                    ))
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              "dal " +
                  DateFormat("dd MMM yyyy").format(offer.dateStart) +
                  " al " +
                  DateFormat("dd MMM yyyy").format(offer.dateEnd),
              style: TextStyle(
                  color: Constants.LIGHT_GREY_COLOR,
                  fontSize: 14,
                  fontFamily: Constants.FONT),
            ),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProfileScreen(id: offer.user.id)));
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(68.0),
                    child: CachedNetworkImage(
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      imageUrl: (offer.user.image ?? ""),
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          SvgPicture.asset("assets/images/placeholder.svg"),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Creata da " +
                            offer.user.firstName!.capitalize() +
                            " " +
                            offer.user.lastName!.substring(0, 1).toUpperCase() +
                            ".",
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      /*Text(
                                    "Milano",
                                    style: TextStyle(
                                        color: Constants.LIGHT_TEXT_COLOR,
                                        fontSize: 14,
                                        fontFamily: Constants.FONT
                                    ),
                                  ),*/
                      SizedBox(
                        height: 4,
                      ),
                      Wrap(
                        spacing: 3,
                        children: [
                          StarsWidget(stars: offer.user.reviewsMedia!.toInt()),
                          Text(
                            offer.product.owner.reviewsMedia.toString(),
                            style: TextStyle(
                                color: Constants.DARK_TEXT_COLOR,
                                fontSize: 14,
                                fontFamily: Constants.FONT),
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
                  borderRadius: BorderRadius.circular(50.0),
                  child: CachedNetworkImage(
                    width: 127,
                    height: 96,
                    fit: BoxFit.contain,
                    imageUrl: offer.product.images.isNotEmpty
                        ? offer.product.images.first.image
                        : "",
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.product.model,
                      style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                          fontFamily: Constants.FONT),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      offer.product.brandName,
                      style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                          fontFamily: Constants.FONT),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${Utils.formatCurrency(offer.product.priceOffer)} al giorno",
                      style: TextStyle(
                          color: Constants.PRIMARY_COLOR,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: Constants.FONT),
                    ),
                  ],
                )
              ],
            ),
            /*if(_mode == OrdersScreenMode.sent && canPay(offer)) Divider(),
            if(_mode == OrdersScreenMode.sent && canPay(offer)) Row(
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

                    },
                  ),
                ),
              ],
            ),*/
            SizedBox(height: 16),
            Center(
              child: Text(
                getOfferStatusName(offer),
                style: TextStyle(
                    color: Constants.TEXT_COLOR,
                    fontSize: 16,
                    fontFamily: Constants.FONT,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  canPay(Offer offer) {
    switch (offer.state.id) {
      case 2:
        return true;
      default:
        return false;
    }
  }

  String getOfferStatusName(Offer offer) {
    switch (offer.state.id) {
      case 1:
        return "In attesa di accettazione";
      case 2:
        return "In attesa di pagamento";
      case 3:
        return "Pagamento in corso";
      case 4:
        return "Pagato";
      case 5:
        return "Preso in prestito";
      case 6:
        return "Chiuso";
      case 7:
        return "Rifiutato";
      case 31:
        return "In attesa di accettazione";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          Row(children: [
            InkWell(
              child: Container(
                  padding: const EdgeInsets.all(50),
                  child: SvgPicture.asset(
                    "assets/images/back.svg",
                  )),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            // RichText(
            //     text: TextSpan(children: [
            //   TextSpan(
            //     text: "laBlaBla",
            //     style: TextStyle(fontSize: 25),
            //   ),
            //   WidgetSpan(
            //       child: SvgPicture.asset("assets/images/back.svg"),
            //       baseline: TextBaseline.alphabetic,
            //       alignment: PlaceholderAlignment.baseline),
            // ])),

            DropdownButton<String>(
              hint: Text(
                'Noleggi',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              iconEnabledColor: Colors.white,
              iconSize: 30,
              items: <String>['Pending', 'Completed', 'Confirmed']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == 'Pending') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => InfoScreen()));
                } else if (value == 'Completed') {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => InfoScreen()));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => InfoScreen()));
                }
              },
            ),
            InkWell(
              child: Container(
                  padding: const EdgeInsets.only(left: 60),
                  child: SvgPicture.asset(
                    "assets/images/cancel.svg",
                    width: 40,
                  )),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => InfoScreen()));
              },
            ),
          ]),
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
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: _mode == OrdersScreenMode.sent
                                      ? Constants.PRIMARY_COLOR
                                      : Colors.white,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: Text(
                                'Inviati',
                                style: TextStyle(
                                    color: _mode == OrdersScreenMode.sent
                                        ? Colors.white
                                        : Constants.TEXT_COLOR),
                              ),
                              onPressed: () {
                                setState(() {
                                  _mode = OrdersScreenMode.sent;

                                  getOrders();
                                });
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: _mode == OrdersScreenMode.received
                                      ? Constants.PRIMARY_COLOR
                                      : Colors.white,
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: Text(
                                'Ricevuti',
                                style: TextStyle(
                                    color: _mode == OrdersScreenMode.received
                                        ? Colors.white
                                        : Constants.TEXT_COLOR),
                              ),
                              onPressed: () {
                                setState(() {
                                  _mode = OrdersScreenMode.received;

                                  getOrders();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _orders.isNotEmpty
                                  ? MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _orders.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              OrderDetailsScreen(
                                                                  offer: _orders[
                                                                      index])));
                                                },
                                                child:
                                                    offerCell(_orders[index]));
                                          }),
                                    )
                                  : Center(
                                      child: Text("Non ci sono noleggi qui")),
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
