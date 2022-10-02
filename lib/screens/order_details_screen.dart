import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/account_screen.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/offer_success_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/widgets/checkout/checkout_product_card.dart';
import 'package:sisterly/widgets/stars_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Offer offer;

  const OrderDetailsScreen({Key? key, required this.offer}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String _shipping = 'shipment';

  final TextEditingController _fromDayText = TextEditingController();
  final TextEditingController _fromMonthText = TextEditingController();
  final TextEditingController _fromYearText = TextEditingController();
  final TextEditingController _toDayText = TextEditingController();
  final TextEditingController _toMonthText = TextEditingController();
  final TextEditingController _toYearText = TextEditingController();

  bool _insurance = true;
  DateTime _availableFrom = DateTime.now();
  DateTime _availableTo = DateTime.now().add(Duration(days: 7));
  String _rentPrice = "0";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        _shipping = widget.offer.deliveryMode.id == 3 ? "shipment" : "withdraw";
        _availableFrom = widget.offer.dateStart;
        _availableTo = widget.offer.dateEnd;
      });

      setFromDate(_availableFrom);
      setToDate(_availableTo);
    });
  }

  setFromDate(DateTime date) {
    _fromDayText.text = date.day.toString();
    _fromMonthText.text = date.month.toString();
    _fromYearText.text = date.year.toString();
  }

  setToDate(DateTime date) {
    _toDayText.text = date.day.toString();
    _toMonthText.text = date.month.toString();
    _toYearText.text = date.year.toString();
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: InkWell(
                              child: SizedBox(
                                  child: SvgPicture.asset(
                                      "assets/images/back.svg")),
                              onTap: () {
                                Navigator.of(context).pop();
                              })),
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Ordine #" + widget.offer.id.toString(),
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
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 4),
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
                      AbsorbPointer(
                          child: CheckoutProductCard(
                              product: widget.offer.product)),
                      SizedBox(height: 25),
                      profileBanner(),
                      AbsorbPointer(
                        absorbing: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25),
                            Text(
                              "Modalità di consegna",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 18,
                                  fontFamily: Constants.FONT,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      horizontalTitleGap: 0,
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(
                                        'Spedizione',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: _shipping == 'shipment'
                                                    ? Constants.SECONDARY_COLOR
                                                    : Constants
                                                        .DARK_TEXT_COLOR),
                                      ),
                                      leading: Radio(
                                        value: 'shipment',
                                        groupValue: _shipping,
                                        activeColor: Constants.SECONDARY_COLOR,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => _shipping ==
                                                        'shipment'
                                                    ? Constants.SECONDARY_COLOR
                                                    : Constants
                                                        .DARK_TEXT_COLOR),
                                        onChanged: (String? value) {},
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      horizontalTitleGap: 0,
                                      title: Text(
                                        'Di persona',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: _shipping == 'withdraw'
                                                    ? Constants.SECONDARY_COLOR
                                                    : Constants
                                                        .DARK_TEXT_COLOR),
                                      ),
                                      leading: Radio(
                                        value: 'withdraw',
                                        groupValue: _shipping,
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => _shipping ==
                                                        'withdraw'
                                                    ? Constants.SECONDARY_COLOR
                                                    : Constants
                                                        .DARK_TEXT_COLOR),
                                        onChanged: (String? value) {},
                                      ),
                                    ),
                                  ),
                                ]),
                            if (_shipping != 'withdraw' &&
                                widget.offer.addressIdCarrier != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 15),
                                  Text(
                                    "Indirizzo di consegna",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 15),
                                  _renderAddress(widget.offer.addressIdCarrier!)
                                ],
                              ),
                            SizedBox(height: 35),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Da",
                                        style: TextStyle(
                                            color: Constants.DARK_TEXT_COLOR,
                                            fontSize: 18,
                                            fontFamily: Constants.FONT,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        DateFormat("dd-MM-yyyy")
                                            .format(_availableFrom),
                                        style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "A",
                                        style: TextStyle(
                                            color: Constants.DARK_TEXT_COLOR,
                                            fontSize: 18,
                                            fontFamily: Constants.FONT,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        DateFormat("dd-MM-yyyy")
                                            .format(_availableTo),
                                        style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 35),
                            if (widget.offer.totalNet == null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Noleggio",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Utils.formatCurrency(widget.offer.price),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            if (widget.offer.totalNet == null)
                              SizedBox(height: 16),
                            if (widget.offer.totalNet == null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Protezione acquisti",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Utils.formatCurrency(
                                        widget.offer.insurance),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            if (widget.offer.totalNet == null &&
                                _shipping == "shipment")
                              SizedBox(height: 16),
                            if (widget.offer.totalNet == null &&
                                _shipping == "shipment")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Spedizione",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Utils.formatCurrency(15),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            if (widget.offer.totalNet == null &&
                                widget.offer.total != null &&
                                widget.offer.total! > 0)
                              SizedBox(height: 16),
                            if (widget.offer.totalNet == null &&
                                widget.offer.total != null &&
                                widget.offer.total! > 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Totale pagato",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    Utils.formatCurrency(widget.offer.total),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            if (widget.offer.totalNet != null)
                              SizedBox(height: 16),
                            if (widget.offer.totalNet != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Il tuo guadagno",
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    widget.offer.totalNet! <= 0
                                        ? Utils.formatCurrency(0) + ' 0.0'
                                        : Utils.formatCurrency(
                                            widget.offer.totalNet),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            SizedBox(height: 35)
                          ],
                        ),
                      )
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

  Widget profileBanner() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ProfileScreen(
                  id: widget.offer.user.id,
                )));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(68.0),
            child: CachedNetworkImage(
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              imageUrl: (widget.offer.user.image ?? ""),
              placeholder: (context, url) => CircularProgressIndicator(),
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
                widget.offer.user.username.toString(),
                style: TextStyle(
                    color: Constants.DARK_TEXT_COLOR,
                    fontSize: 20,
                    fontFamily: Constants.FONT),
              ),
              /*SizedBox(height: 6,),
              Text(
                "Milan",
                style: TextStyle(
                    color: Constants.LIGHT_TEXT_COLOR,
                    fontSize: 15,
                    fontFamily: Constants.FONT
                ),
              ),*/
              SizedBox(
                height: 6,
              ),
              Wrap(
                spacing: 3,
                children: [
                  StarsWidget(stars: widget.offer.user.reviewsMedia!.toInt()),
                  Text(
                    widget.offer.user.reviewsMedia.toString(),
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
    );
  }

  Widget inputField(
      String label, TextEditingController controller, bool readOnly) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 25),
      Text(label,
          style: TextStyle(
            color: Constants.TEXT_COLOR,
            fontSize: 16,
            fontFamily: Constants.FONT,
          )),
      const SizedBox(height: 7),
      Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x4ca3c4d4),
              spreadRadius: 8,
              blurRadius: 12,
              offset: Offset(0, 0), // changes position of shadow
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
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Constants.PLACEHOLDER_COLOR),
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
          controller: controller,
          readOnly: readOnly,
        ),
      ),
    ]);
  }

  Widget _renderAddress(Address address) {
    return Container(
      padding: EdgeInsets.all(25),
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: address.active
              ? Constants.SECONDARY_COLOR_LIGHT
              : Constants.LIGHT_GREY_COLOR2),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(address.name.toString(),
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: Constants.FONT,
                    fontWeight: FontWeight.bold)),
            Text(address.address1,
                style: TextStyle(fontSize: 16, fontFamily: Constants.FONT)),
            Text(address.city + " - " + address.province,
                style: TextStyle(fontSize: 16, fontFamily: Constants.FONT)),
            Text(address.country,
                style: TextStyle(fontSize: 16, fontFamily: Constants.FONT)),
          ]),
        ]),
      ),
    );
  }
}
