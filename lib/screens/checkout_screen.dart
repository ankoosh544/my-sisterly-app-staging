import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/var.dart';
import 'package:sisterly/screens/choose_payment_screen.dart';
import 'package:sisterly/screens/offer_success_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/widgets/checkout/checkout_product_card.dart';
import 'package:sisterly/widgets/stars_widget.dart';

import '../models/offer.dart';
import 'offers_contract_buyer_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final DateTime startDate;
  final DateTime endDate;
  final String shipping;

  const CheckoutScreen(
      {Key? key,
      required this.product,
      required this.startDate,
      required this.endDate,
      required this.shipping})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _shipping = 'shipment';

  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _address2 = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController(text: "IT");
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _discountText = TextEditingController();

  final TextEditingController _fromDayText = TextEditingController();
  final TextEditingController _fromMonthText = TextEditingController();
  final TextEditingController _fromYearText = TextEditingController();
  final TextEditingController _toDayText = TextEditingController();
  final TextEditingController _toMonthText = TextEditingController();
  final TextEditingController _toYearText = TextEditingController();

  Timer? _discountDebounce;
  bool _insurance = true;
  bool _hasAddress = false;
  bool _enableBuy = false;
  bool _saveAddress = true;
  bool _isLoadingTotal = false;
  List<Address> _addresses = [];
  Address? _activeAddress;
  bool _addNewAddress = false;
  bool _editAddress = false;
  bool _pushEnabled = false;
  Address? _addressToEdit;
  DateTime _availableFrom = DateTime.now();
  DateTime _availableTo = DateTime.now().add(Duration(days: 7));
  String _rentPrice = "0";
  String _deliveryPrice = "0";
  String _insurancePrice = "0";
  String _discountAmount = "0";
  String _discountPercent = "0";
  String _totalPrice = "0";

  @override
  void initState() {
    super.initState();

    checkPush(false);

    if (widget.product.deliveryType!.id == 3) {
      _shipping = "shipment";
    }

    if (widget.product.deliveryType!.id == 1) {
      _shipping = "withdraw";
    }

    _shipping = widget.shipping;

    Future.delayed(Duration.zero, () {
      _availableFrom = widget.startDate;
      _availableTo = widget.endDate;

      setFromDate(_availableFrom);
      setToDate(_availableTo);
      getAddresses(() {
        getTotalPrice();
      });
    });
  }

  checkPush(openAppIfFailed) async {
    final status = await OneSignal.shared.getDeviceState();
    bool isSimulator = await Utils.isSimulator();

    debugPrint("Push status hasNotificationPermission: " +
        status!.hasNotificationPermission.toString());
    debugPrint("Push status subscribed: " + status.subscribed.toString());
    debugPrint("Push status Utils.isSimulator(): " + isSimulator.toString());

    if ((status.hasNotificationPermission && status.subscribed) ||
        isSimulator) {
      _pushEnabled = true;
    } else {
      debugPrint("openNotificationSettings");
      if (openAppIfFailed) AppSettings.openNotificationSettings();
      _pushEnabled = false;
    }

    setState(() {});
  }

  setFromDate(DateTime date) {
    _fromDayText.text = date.day.toString();
    _fromMonthText.text = date.month.toString();
    _fromYearText.text = date.year.toString();
    getTotalPrice();
  }

  setToDate(DateTime date) {
    _toDayText.text = date.day.toString();
    _toMonthText.text = date.month.toString();
    _toYearText.text = date.year.toString();
    getTotalPrice();
  }

  getTotalPrice() {
    if (_shipping == "shipment" && _activeAddress == null) {
      return;
    }

    setState(() {
      _isLoadingTotal = true;
    });

    var params = {
      "rent_price": widget.product.priceOffer,
      "date_start": DateFormat("yyyy-MM-dd").format(_availableFrom),
      "date_end": DateFormat("yyyy-MM-dd").format(_availableTo),
      "delivery_mode": _shipping == 'shipment' ? 3 : 1,
    };

    if (_activeAddress != null && _shipping == 'shipment') {
      params["address_id"] = _activeAddress!.id.toString();
    }

    if (_discountText.text.isNotEmpty) {
      params["discount_code"] = _discountText.text;
    }

    ApiManager(context).makePostRequest(
        '/product/' + widget.product.id.toString() + '/offer/calculate_rent',
        params, (response) {
      setState(() {
        _isLoadingTotal = false;
      });
      if (response["data"] != null) {
        setState(() {
          _rentPrice = response["data"]["total_rent"].toString();
          _deliveryPrice = response["data"]["delivery_price"].toString();
          _insurancePrice = response["data"]["insurance_amount"].toString();
          _discountAmount = response["data"]["discount_amount"].toString();
          _discountPercent = response["data"]["discount_percent"].toString();
          _totalPrice = response["data"]["order_total"].toString();
          _enableBuy = true;
        });
      }

      if (response["errors"] != null) {
        _enableBuy = false;
        debugPrint("response ok " + response.toString());
        ApiManager.showFreeErrorToast(context, response["errors"][0]);
      }
    }, (response) {
      setState(() {
        _isLoadingTotal = false;
      });

      debugPrint("response error " + response.toString());
      /*if(response["errors"] != null) {
        ApiManager.showErrorToast(context, response["errors"][0]);
      }*/
    });
  }

  @override
  void dispose() {
    _discountDebounce?.cancel();
    super.dispose();
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
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Richiesta di noleggio",
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
                      if (!_pushEnabled) SizedBox(height: 15),
                      if (!_pushEnabled)
                        InkWell(
                          onTap: () async {
                            await Utils.enablePush(context, true);
                            checkPush(true);
                          },
                          child: Card(
                            color: Color(0x88FF8A80),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: const [
                                  Text(
                                    'Per procedere con l\'invio dell\'offerta, è necessario attivare le notifiche push',
                                    style: TextStyle(
                                      color: Constants.TEXT_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Clicca qui',
                                      style: TextStyle(
                                        color: Constants.TEXT_COLOR,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.FONT,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      AbsorbPointer(
                        absorbing: !_pushEnabled,
                        child: Opacity(
                          opacity: !_pushEnabled ? 0.4 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckoutProductCard(product: widget.product),
                              SizedBox(height: 25),
                              profileBanner(),
                              SizedBox(height: 25),
                              Text(
                                _shipping == "shipment"
                                    ? "Hai deciso di ricevere la borsa tramite corriere"
                                    : "Hai deciso di ritirare di persona la borsa",
                                style: TextStyle(
                                    color: Constants.DARK_TEXT_COLOR,
                                    fontSize: 18,
                                    fontFamily: Constants.FONT,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (_shipping == "shipment")
                                Card(
                                  color: Color(0x55e8e23e),
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            'Costo spedizione: ' +
                                                Utils.formatCurrency(
                                                    double.parse(
                                                        _deliveryPrice)),
                                            style: TextStyle(
                                              color: Constants.TEXT_COLOR,
                                              fontSize: 16,
                                              fontFamily: Constants.FONT,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_shipping != 'withdraw')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 15),
                                    Text(
                                      "A quale indirizzo vuoi riceverlo?",
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 15),
                                    if (!_hasAddress ||
                                        _addNewAddress ||
                                        _editAddress)
                                      Column(children: [
                                        inputField(
                                            "Nome e cognome", _name, false),
                                        inputField(
                                            "Indirizzo", _address, false),
                                        inputField(
                                            "Indirizzo 2", _address2, false),
                                        inputField("Città", _city, false),
                                        inputField(
                                            "Codice postale", _zip, false),
                                        inputField("Provincia", _state, false),
                                        inputField("Nazione", _country, true),
                                        inputField("Email", _email, false),
                                        inputField("Cellulare", _phone, false),
                                        const SizedBox(height: 25),
                                        if (!_editAddress)
                                          Row(children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Constants.GREEN_SAVE,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50))),
                                              child: Text('Salva',
                                                  style: TextStyle(
                                                    color: Constants.TEXT_COLOR,
                                                    fontSize: 16,
                                                    fontFamily: Constants.FONT,
                                                  )),
                                              onPressed: () async {
                                                setState(() {
                                                  _saveAddress = true;
                                                });
                                                await saveAddress();
                                              },
                                            ),
                                            Text('Salva per acquisti futuri',
                                                style: TextStyle(
                                                  color: Constants.TEXT_COLOR,
                                                  fontSize: 16,
                                                  fontFamily: Constants.FONT,
                                                )),
                                            Switch(
                                              value: _saveAddress,
                                              onChanged: (value) =>
                                                  setState(() {
                                                _saveAddress = value;
                                              }),
                                              activeColor:
                                                  Constants.SECONDARY_COLOR,
                                            )
                                          ]),
                                      ]),
                                    if (_editAddress)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Constants.GREEN_SAVE,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                        child: Text('Salva',
                                            style: TextStyle(
                                              color: Constants.TEXT_COLOR,
                                              fontSize: 16,
                                              fontFamily: Constants.FONT,
                                            )),
                                        onPressed: () {
                                          _updateAddress();
                                          setState(() {
                                            _editAddress = false;
                                            _addressToEdit = null;
                                          });
                                        },
                                      ),
                                    if (_hasAddress &&
                                        !_addNewAddress &&
                                        !_editAddress)
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(children: [
                                                if (_activeAddress != null)
                                                  _renderAddress(
                                                      _activeAddress!),
                                                for (var a in _addresses)
                                                  _renderAddress(a)
                                              ]),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Constants
                                                      .LIGHT_GREY_COLOR2,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50))),
                                              child: Text('+ Nuovo',
                                                  style: TextStyle(
                                                    color: Constants.TEXT_COLOR,
                                                    fontSize: 16,
                                                    fontFamily: Constants.FONT,
                                                  )),
                                              onPressed: () {
                                                setState(() {
                                                  _addNewAddress = true;
                                                });
                                              },
                                            ),
                                          ]),
                                  ],
                                ),
                              SizedBox(height: 25),
                              Text(
                                "Protezione acquisti obbligatoria",
                                style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 18,
                                  fontFamily: Constants.FONT,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(height: 15),
                              Row(children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _insurance = true;
                                  }),
                                  child: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: _insurance
                                            ? Constants.SECONDARY_COLOR_LIGHT
                                            : Constants.LIGHT_GREY_COLOR2),
                                    child: Text(
                                        Utils.formatCurrency(
                                            double.parse(_insurancePrice)),
                                        style: TextStyle(
                                          color: _insurance
                                              ? Colors.black
                                              : Constants.TEXT_COLOR,
                                          fontSize: 16,
                                          fontFamily: Constants.FONT,
                                        )),
                                  ),
                                ),
                                /*GestureDetector(
                                onTap: () => setState(() {
                                  _insurance = false;
                                }),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  margin: EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: !_insurance ? Constants.SECONDARY_COLOR_LIGHT : Constants.LIGHT_GREY_COLOR2
                                  ),
                                  child: Text('No',
                                      style: TextStyle(
                                        color: !_insurance ? Colors.black : Constants.TEXT_COLOR,
                                        fontSize: 16,
                                        fontFamily: Constants.FONT,
                                      )
                                  ),
                                ),
                              )*/
                              ]),
                              SizedBox(height: 35),
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
                              InkWell(
                                onTap: () async {
                                  debugPrint("show date picker");
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _availableFrom,
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 1)),
                                    lastDate:
                                        DateTime.now().add(Duration(days: 700)),
                                  );

                                  setState(() {
                                    if (picked != null) {
                                      _availableFrom = picked;

                                      setFromDate(_availableFrom);

                                      if (_availableTo
                                          .isBefore(_availableFrom)) {
                                        _availableTo = _availableFrom;
                                        setToDate(_availableTo);
                                      }
                                    }
                                  });
                                },
                                child: AbsorbPointer(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              hintText: "gg",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _fromDayText,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "mm",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _fromMonthText,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "aaaa",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _fromYearText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 24,
                              ),
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
                              InkWell(
                                onTap: () async {
                                  debugPrint("show date picker TO");
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _availableTo,
                                    firstDate: DateTime.now(),
                                    lastDate:
                                        DateTime.now().add(Duration(days: 700)),
                                  );

                                  setState(() {
                                    if (picked != null) {
                                      _availableTo = picked;

                                      setToDate(_availableTo);

                                      if (_availableFrom
                                          .isAfter(_availableTo)) {
                                        debugPrint("Correct date");
                                        _availableFrom = _availableTo;
                                        setFromDate(_availableFrom);
                                      }
                                    }
                                  });
                                },
                                child: AbsorbPointer(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "gg",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _toDayText,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "mm",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _toMonthText,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4ca3c4d4),
                                                spreadRadius: 2,
                                                blurRadius: 15,
                                                offset: Offset(0,
                                                    0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            cursorColor:
                                                Constants.PRIMARY_COLOR,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.FORM_TEXT,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "aaaa",
                                              hintStyle: const TextStyle(
                                                  color: Constants
                                                      .PLACEHOLDER_COLOR),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              suffixIcon: SvgPicture.asset(
                                                  "assets/images/arrow_down.svg",
                                                  width: 10,
                                                  height: 6,
                                                  fit: BoxFit.scaleDown),
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              filled: true,
                                              fillColor: Constants.WHITE,
                                            ),
                                            controller: _toYearText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 35),
                              Text(
                                "Hai un codice sconto?",
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
                                      offset: Offset(
                                          0, 0), // changes position of shadow
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
                                  onChanged: (discount) {
                                    if (_discountDebounce?.isActive ?? false)
                                      _discountDebounce!.cancel();
                                    _discountDebounce = Timer(
                                        const Duration(milliseconds: 500), () {
                                      getTotalPrice();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Inserisci codice sconto...",
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
                                  controller: _discountText,
                                ),
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              _isLoadingTotal
                                  ? Center(child: CircularProgressIndicator())
                                  : Row(
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
                                          Utils.formatCurrency(
                                              double.parse(_rentPrice)),
                                          style: TextStyle(
                                              color: Constants.DARK_TEXT_COLOR,
                                              fontSize: 18,
                                              fontFamily: Constants.FONT,
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 16),
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
                                        double.parse(_insurancePrice)),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 18,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              if (_shipping == "shipment") SizedBox(height: 16),
                              if (_shipping == "shipment")
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
                                      Utils.formatCurrency(
                                          double.parse(_deliveryPrice)),
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              SizedBox(height: 16),
                              if (double.parse(_discountAmount) > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sconto",
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      Utils.formatCurrency(
                                          double.parse(_discountAmount)),
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              if (double.parse(_discountAmount) > 0)
                                SizedBox(height: 16),
                              if (double.parse(_discountPercent) > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sconto",
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      ((double.parse(_discountPercent) * 100)
                                                  .round())
                                              .toString() +
                                          "%",
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 18,
                                          fontFamily: Constants.FONT,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              if (double.parse(_discountPercent) > 0)
                                SizedBox(height: 16),
                              _isLoadingTotal
                                  ? Center(child: CircularProgressIndicator())
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Totale da pagare",
                                          style: TextStyle(
                                              color: Constants.DARK_TEXT_COLOR,
                                              fontSize: 18,
                                              fontFamily: Constants.FONT,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          Utils.formatCurrency(
                                              double.parse(_totalPrice)),
                                          style: TextStyle(
                                              color: Constants.DARK_TEXT_COLOR,
                                              fontSize: 18,
                                              fontFamily: Constants.FONT,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 35),
                              Center(
                                child: Opacity(
                                  opacity: _enableBuy ? 1 : 0.4,
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
                                    child: Text('Procedi'),
                                    onPressed: () async {
                                      if (!_enableBuy) {
                                        ApiManager.showFreeErrorMessage(context,
                                            "Verifica i dati inseriti e riprova");
                                        return;
                                      }

                                      if (_discountDebounce != null &&
                                          _discountDebounce!.isActive) {
                                        return;
                                      }

                                      if (_availableTo
                                              .difference(_availableFrom)
                                              .inDays <
                                          2) {
                                        ApiManager.showFreeErrorMessage(context,
                                            "Seleziona un periodo minimo di 3 giorni.");
                                        return;
                                      }

                                      if (!_hasAddress ||
                                          (_saveAddress &&
                                              _addNewAddress &&
                                              !_editAddress)) {
                                        await saveAddress();
                                        getAddresses(() {
                                          next();
                                        });
                                      } else {
                                        next();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 35)
                            ],
                          ),
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

  next() {
    /*setState(() {
      _isLoading = true;
    });*/

    var params = {
      "price": double.tryParse(widget.product.priceOffer.toString()),
      "date_start": DateFormat("yyyy-MM-dd").format(_availableFrom),
      "date_end": DateFormat("yyyy-MM-dd").format(_availableTo),
      "delivery_mode": _shipping == 'shipment' ? 3 : 1
    };

    if (_activeAddress != null && _shipping == 'shipment') {
      params["address_id"] = int.tryParse(_activeAddress!.id.toString());
    }

    if (_discountText.text.isNotEmpty) {
      params["discount_code"] = _discountText.text;
    }

    ApiManager(context).makePutRequest(
        "/product/" + widget.product.id.toString() + "/offer/make/", params,
        (res) async {
      getOfferAndRedirect(res["data"]["id"]);
      /*await Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => OffersContractBuyerScreen(offer: offer)));*/
      /*Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => OfferSuccessScreen(totalPrice: double.parse(_totalPrice))));*/
    }, (res) {
      ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      /*setState(() {
        _isLoading = false;
      });*/
    });

    //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChoosePaymentScreen(address: _activeAddress!, shipping: _shipping, insurance: _insurance, product: widget.product)));
  }

  getOfferAndRedirect(offerId) {
    ApiManager(context).makeGetRequest(
        "/product/order/" + offerId.toString(), {}, (res) async {
      var offer = Offer.fromJson(res["data"]);
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              OffersContractBuyerScreen(offer: offer)));
    }, (res) {});
  }

  void _handleShipmentRadioChange(String? value) {
    setState(() {
      _shipping = value!;
    });
  }

  Widget profileBanner() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(68.0),
          child: CachedNetworkImage(
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            imageUrl: (widget.product.owner.image ?? ""),
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
              widget.product.owner.username.toString(),
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
                StarsWidget(stars: widget.product.owner.reviewsMedia!.toInt()),
                Text(
                  widget.product.owner.reviewsMedia.toString(),
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
          onChanged: (str) {
            if (!_enableBuy) {
              getTotalPrice();
            }
          },
          controller: controller,
          readOnly: readOnly,
        ),
      ),
    ]);
  }

  Widget _renderAddress(Address address) {
    debugPrint("coming to render address widget");
    debugPrint(address.toString());
    List<String> menu = ['Elimina', 'Predefinito', 'Modifica'];
    if (address.active) {
      debugPrint(address.active.toString());
      menu = ['Modifica'];
    }

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
            SizedBox(height: 10),
            if (address.email != null)
              Text(address.email ?? '',
                  style: TextStyle(fontSize: 16, fontFamily: Constants.FONT)),
            if (address.phone != null)
              Text(address.phone ?? '',
                  style: TextStyle(fontSize: 16, fontFamily: Constants.FONT)),
          ]),
          SizedBox(width: 25),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            PopupMenuButton<String>(
              child: Container(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.more_vert,
                ),
              ),
              padding: EdgeInsets.all(0),
              onSelected: (val) {
                switch (val) {
                  case 'Elimina':
                    _deleteAddress(address);
                    break;
                  case 'Predefinito':
                    _setActiveAddress(address);
                    break;
                  case 'Modifica':
                    setState(() {
                      _addressToEdit = address;
                      _editAddress = true;
                      _name.text = address.name.toString();
                      _address.text = address.address1;
                      _address2.text = address.address2 ?? "";
                      _city.text = address.city;
                      _zip.text = address.zip;
                      _state.text = address.province;
                      _country.text = address.country;
                      _email.text = address.email ?? "";
                      _phone.text = address.phone ?? "";
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return menu.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
            Visibility(
              visible: address.active,
              child: InkWell(
                child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Constants.PRIMARY_COLOR),
                    child: SvgPicture.asset("assets/images/check_color.svg",
                        width: 17, height: 19, fit: BoxFit.scaleDown)),
              ),
            )
          ])
        ]),
      ),
    );
  }

  getAddresses(Function? callback) {
    ApiManager(context).makeGetRequest('/client/address', {}, (response) {
      debugPrint(response.toString());
      debugPrint("HERE Address");
      _activeAddress = null;
      _addresses = [];
      if (response["data"] != null) {
        for (var address in response["data"]) {
          debugPrint(address["active"].toString());
          debugPrint("inf for loop");
          if (address["active"]) {
            _activeAddress = Address.fromJson(address);
          } else {
            _addresses.add(Address.fromJson(address));
          }
        }
        debugPrint(_activeAddress.toString());
        debugPrint("Active address");

        if (_addresses.isNotEmpty || _activeAddress != null) {
          debugPrint(_activeAddress.toString());
          debugPrint("============Address=============");
          setState(() {
            _hasAddress = true;
            _addNewAddress = false;
          });
        }

        setState(() {});

        if (callback != null) callback();
      }

      getTotalPrice();
    }, (response) {
      getTotalPrice();
    });
  }

  saveAddress() {
    if (_name.text.isNotEmpty &&
        _address.text.isNotEmpty &&
        _country.text.isNotEmpty &&
        _state.text.isNotEmpty &&
        _zip.text.isNotEmpty &&
        _city.text.isNotEmpty) {
      ApiManager(context).makePutRequest('/client/address', {
        "name": _name.text,
        "address1": _address.text,
        "country": _country.text,
        "province": _state.text,
        "zip": _zip.text,
        "city": _city.text,
        "latitude": -5,
        "longitude": -9,
        "address2": _address2.text,
        "note": "",
        "default": false,
        "active": _activeAddress == null
      }, (res) {
        getAddresses(null);
      }, (res) {
        getAddresses(null);
      });
    }
  }

  _deleteAddress(Address address) async {
    try {
      await ApiManager(context).internalMakeDeleteRequest(
          '/client/address/${address.id}', (res) {}, (res) {});

      _removeAddress(address);
    } catch (e) {
      //
    }
  }

  _removeAddress(Address address) {
    setState(() {
      int i = _addresses.indexWhere((a) => address.id == a.id);
      if (i >= 0) {
        _addresses.removeAt(i);
      } else {
        _activeAddress = null;
      }
    });
  }

  _setActiveAddress(Address address) async {
    try {
      address.active = true;
      await ApiManager(context).makePostRequest(
          '/client/address/${address.id}', address, (res) {}, (res) {});

      if (_activeAddress != null) {
        _activeAddress!.active = false;
        await ApiManager(context).makePostRequest(
            '/client/address/${_activeAddress!.id}',
            _activeAddress!,
            (res) {},
            (res) {});

        _addresses.add(_activeAddress!);
      }
      _activeAddress = address;
      debugPrint("ADDRESS check");
      debugPrint(_activeAddress.toString());
      _removeAddress(address);

      getTotalPrice();
    } catch (e) {
      //
    }
  }

  _updateAddress() async {
    if (_addressToEdit != null &&
        _name.text.isNotEmpty &&
        _address.text.isNotEmpty &&
        _country.text.isNotEmpty &&
        _state.text.isNotEmpty &&
        _zip.text.isNotEmpty &&
        _city.text.isNotEmpty) {
      ApiManager(context)
          .makePostRequest('/client/address/${_addressToEdit!.id}', {
        "name": _name.text,
        "address1": _address.text,
        "country": _country.text,
        "province": _state.text,
        "zip": _zip.text,
        "city": _city.text,
        "latitude": -5,
        "longitude": -5,
        "address2": _address2.text,
        "note": "",
        "default": false,
        "active": _addressToEdit!.active
      }, (res) {
        getAddresses(null);
      }, (res) {});
    }
  }
}
