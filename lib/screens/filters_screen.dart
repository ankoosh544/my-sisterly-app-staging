import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/models/brand.dart';
import 'package:sisterly/models/category.dart';
import 'package:sisterly/models/delivery_mode.dart';
import 'package:sisterly/models/filters.dart';
import 'package:sisterly/models/product_color.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/models/var.dart';

class FiltersScreen extends StatefulWidget {

  final Filters? filters;

  const FiltersScreen({Key? key, @required this.filters}) : super(key: key);

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {

  final TextEditingController _modelText = TextEditingController();

  final TextEditingController _fromDayText = TextEditingController();
  final TextEditingController _fromMonthText = TextEditingController();
  final TextEditingController _fromYearText = TextEditingController();

  final TextEditingController _toDayText = TextEditingController();
  final TextEditingController _toMonthText = TextEditingController();
  final TextEditingController _toYearText = TextEditingController();

  List<ProductColor> _colorsList = [];
  List<DeliveryMode> _deliveryModesList = [];
  List<Category> _categories = [];
  List<Brand> _brands = [];

  Filters _filters = Filters();

  @override
  void initState() {
    super.initState();

    if(widget.filters != null) _filters = widget.filters!;

    Future.delayed(Duration.zero, () {
      getColors();
      getDeliveryModes();
      getCategories();
      getBrands();

      setFromDate(_filters.availableFrom);
      setToDate(_filters.availableTo);
    });
  }

  getCategories() {
    ApiManager(context).makeGetRequest('/client/categories', {}, (res) {
      var data = res["data"];
      _categories.clear();
      if (data != null) {
        setState(() {
          for (var b in data) {
            _categories.add(Category.fromJson(b));
          }
        });
      }
    }, (res) {});
  }

  getBrands() {
    ApiManager(context).makeGetRequest('/admin/brand', {}, (res) {
      var data = res["data"];
      _brands.clear();
      if (data != null) {
        setState(() {
          for (var b in data) {
            _brands.add(Brand.fromJson(b));
          }
        });
      }
    }, (res) {});
  }

  getColors() {
    ApiManager(context).makeGetRequest('/admin/color', {}, (res) {
      _colorsList = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          _colorsList.add(ProductColor.fromJson(prod));
        }
      }

      setState(() {

      });
    }, (res) {

    });
  }

  getDeliveryModes() {
    ApiManager(context).makeGetRequest('/product/delivery_modes', {}, (res) {
      _deliveryModesList = [];

      var data = res["data"];
      if (data != null) {
        for (var prod in data) {
          _deliveryModesList.add(DeliveryMode.fromJson(prod));
        }
      }

      setState(() {

      });
    }, (res) {

    });
  }

  applyFilters() {
    _filters.model = _modelText.text;

    Navigator.of(context).pop(_filters);
  }

  Widget getTag(int id, String label, List<int> selected) {
    return InkWell(
      onTap: () {
        if(selected.contains(id)) {
          selected.remove(id);
        } else {
          selected.add(id);
        }

        setState(() {

        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected.contains(id) ? Color(0xfffedcdc) : Color(0xffeff2f5),
          borderRadius: BorderRadius.circular(60)
        ),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
              color: selected.contains(id) ? Constants.DARK_TEXT_COLOR : Constants.LIGHT_TEXT_COLOR,
              fontSize: 16,
              height: 1.8,
              fontFamily: Constants.FONT
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getCategoryRadio(String label, bool selected) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Wrap(
        children: [
          SvgPicture.asset(selected ? "assets/images/checked.svg" : "assets/images/check.svg"),
          SizedBox(width: 8,),
          Text(
            label,
            style: TextStyle(
                color: selected ? Constants.DARK_TEXT_COLOR : Constants.LIGHT_TEXT_COLOR,
                fontSize: 16,
                height: 1.8,
                fontFamily: Constants.FONT
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget getColorBullet(int id, Color color, List<int> selected) {
    return InkWell(
      onTap: () {
        if(selected.contains(id)) {
          selected.remove(id);
        } else {
          selected.add(id);
        }

        setState(() {

        });
      },
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30)
        ),
        child: selected.contains(id) ? SvgPicture.asset("assets/images/check_color.svg", width: 13, height: 10, fit: BoxFit.scaleDown) : SizedBox()
      ),
    );
  }

  setFromDate(DateTime? date) {
    if(date != null) {
      _fromDayText.text = date.day.toString();
      _fromMonthText.text = date.month.toString();
      _fromYearText.text = date.year.toString();
    } else {
      _fromDayText.text = "";
      _fromMonthText.text = "";
      _fromYearText.text = "";
    }
  }

  setToDate(DateTime? date) {
    if(date != null) {
      _toDayText.text = date.day.toString();
      _toMonthText.text = date.month.toString();
      _toYearText.text = date.year.toString();
    } else {
      _toDayText.text = "";
      _toMonthText.text = "";
      _toYearText.text = "";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    int sensitivity = 8;
                    if (details.delta.dy > sensitivity) {
                      // Down Swipe
                      debugPrint("down swipe");
                    } else if(details.delta.dy < -sensitivity){
                      // Up Swipe
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Text(
                        "Filtri di ricerca",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Constants.PRIMARY_COLOR,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40,),
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
                                decoration: InputDecoration(
                                  hintText: "Nome modello...",
                                  hintStyle: const TextStyle(
                                      color: Constants.PLACEHOLDER_COLOR),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  prefixIcon: SvgPicture.asset("assets/images/search.svg", width: 13, fit: BoxFit.scaleDown,),
                                  contentPadding: const EdgeInsets.all(16),
                                  filled: true,
                                  fillColor: Constants.WHITE,
                                ),
                                controller: _modelText,
                              ),
                            ),
                            SizedBox(height: 40,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Brand",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 16,),
                                if(_filters.brand != null && _filters.brand! > 0) InkWell(
                                  onTap: () {
                                    setState(() {
                                      _filters.brand = null;
                                    });
                                  },
                                  child: Text(
                                    "Cancella",
                                    style: TextStyle(
                                        color: Constants.SECONDARY_COLOR,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.FONT),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8,),
                            if (_brands.isNotEmpty)  Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4ca3c4d4),
                                      spreadRadius: 8,
                                      blurRadius: 12,
                                      offset:
                                      Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Brand>(
                                      items: _brands.map((Brand b) => DropdownMenuItem<Brand>(
                                          child: Text(b.name, style: TextStyle(fontSize: 16)),
                                          value: b
                                      )
                                      ).toList(),
                                      onChanged: (val) => setState(() => _filters.brand = val!.id),
                                      value: _filters.brand != null ? _brands.firstWhere((element) => element.id == _filters.brand) : null
                                  ),
                                )
                            ),
                            SizedBox(height: 40,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Categoria",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 16,),
                                if(_filters.category != null && _filters.category! > 0) InkWell(
                                  onTap: () {
                                    setState(() {
                                      _filters.category = null;
                                    });
                                  },
                                  child: Text(
                                    "Cancella",
                                    style: TextStyle(
                                        color: Constants.SECONDARY_COLOR,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.FONT),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8,),
                            if (_categories.isNotEmpty)  Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4ca3c4d4),
                                      spreadRadius: 8,
                                      blurRadius: 12,
                                      offset:
                                      Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Category>(
                                      items: _categories.map((Category b) => DropdownMenuItem<Category>(
                                          child: Text(b.category, style: TextStyle(fontSize: 16)),
                                          value: b
                                      )
                                      ).toList(),
                                      onChanged: (val) => setState(() => _filters.category = val!.id),
                                      value: _filters.category != null ? _categories.firstWhere((element) => element.id == _filters.category) : null
                                  ),
                                )
                            ),
                            /*Text(
                              "Category",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: [
                                getCategoryRadio("Shoulder Bag", false),
                                getCategoryRadio("Clutch", true),
                                getCategoryRadio("By Hand", true),
                                getCategoryRadio("Shoppers", true),
                                getCategoryRadio("Backpack", true)
                              ],
                            ),
                            SizedBox(height: 24,),*/
                            SizedBox(height: 40,),
                            Text(
                              "Condizioni",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: productConditions.map((item) {
                                return getTag(item.id, item.name, _filters.conditions);
                              }).toList()
                            ),
                            SizedBox(height: 24,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Colore",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                InkWell(
                                  child: Text(
                                    _filters.colors.isNotEmpty ? "Deseleziona tutti" : "Seleziona tutti",
                                    style: TextStyle(
                                        color: Constants.GREY,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.FONT),
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if(_filters.colors.isNotEmpty) {
                                        _filters.colors = [];
                                      } else {
                                        _filters.colors = _colorsList.map((e) => e.id).toList();
                                      }
                                    });
                                  },
                                )
                              ],
                            ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: _colorsList.map((e) => getColorBullet(e.id, HexColor(e.hexadecimal), _filters.colors)).toList(),
                            ),
                            SizedBox(height: 24,),
                            Text(
                              "Modalità di consegna",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: _deliveryModesList.map((e) => getTag(e.id, getDeliveryTypeName(e.id), _filters.deliveryModes),).toList(),
                            ),
                            SizedBox(height: 24,),
                            Text(
                              "Prezzo massimo",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                          ]
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            inactiveTrackColor: Color(0x66ffa8a8), // Custom Gray Color
                            activeTrackColor: Constants.SECONDARY_COLOR,
                            thumbColor: Constants.SECONDARY_COLOR,
                            overlayColor: Constants.LIGHT_GREY_COLOR,
                            activeTickMarkColor: Colors.white,
                            showValueIndicator: ShowValueIndicator.always,
                            valueIndicatorColor: Constants.SECONDARY_COLOR,
                            trackHeight: 3
                          ),
                          child: Slider(
                            value: _filters.maxPrice,
                            min: 0,
                            max: 100,
                            label: _filters.maxPrice.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _filters.maxPrice = value;
                              });
                            },
                          ),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "€0",
                                  style: TextStyle(
                                      color: Constants.LIGHT_GREY_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT),
                                ),
                                Text(
                                  "€100",
                                  style: TextStyle(
                                      color: Constants.LIGHT_GREY_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT),
                                ),
                              ],
                            ),
                            /*SizedBox(height: 32,),
                            Text(
                              "Inspirations",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                            Wrap(
                              children: [
                                getTag("Holiday", false),
                                getTag("Wedding", true),
                                getTag("Wedding", true),
                                getTag("Wedding", true),
                                getTag("Wedding", true)
                              ],
                            ),*/
                            SizedBox(height: 32,),
                            Text(
                              "Disponibilità",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8,),
                            Text(
                              "Da",
                              style: TextStyle(
                                  color: Constants.TEXT_COLOR,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4,),
                            InkWell(
                              onTap: () async {
                                debugPrint("show date picker");
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _filters.availableFrom ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(Duration(days: 1)),
                                  lastDate: DateTime.now().add(Duration(days: 700)),
                                );

                                setState(() {
                                  if(picked != null) {
                                    _filters.availableFrom = picked;

                                    setFromDate(_filters.availableFrom!);

                                    if(_filters.availableTo!.isBefore(_filters.availableFrom!)) {
                                      _filters.availableTo = _filters.availableFrom;
                                      setToDate(_filters.availableTo!);
                                    }
                                  }
                                });
                              },
                              child: AbsorbPointer(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: "gg",
                                            hintStyle: const TextStyle(color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
                                            filled: true,
                                            fillColor: Constants.WHITE,
                                          ),
                                          controller: _fromDayText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "mm",
                                            hintStyle: const TextStyle(
                                                color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
                                            filled: true,
                                            fillColor: Constants.WHITE,
                                          ),
                                          controller: _fromMonthText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "aaaa",
                                            hintStyle: const TextStyle(
                                                color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
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
                            SizedBox(height: 24,),
                            Text(
                              "A",
                              style: TextStyle(
                                  color: Constants.TEXT_COLOR,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4,),
                            InkWell(
                              onTap: () async {
                                debugPrint("show date picker TO");
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _filters.availableTo ?? DateTime.now().add(Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(Duration(days: 700)),
                                );

                                setState(() {
                                  if(picked != null) {
                                    _filters.availableTo = picked;

                                    setToDate(_filters.availableTo!);

                                    if (_filters.availableFrom!.isAfter(
                                        _filters.availableTo!)) {
                                      debugPrint("Correct date");
                                      _filters.availableFrom =
                                          _filters.availableTo;
                                      setFromDate(_filters.availableFrom!);
                                    }
                                  }
                                });
                              },
                              child: AbsorbPointer(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "gg",
                                            hintStyle: const TextStyle(
                                                color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
                                            filled: true,
                                            fillColor: Constants.WHITE,
                                          ),
                                          controller: _toDayText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "mm",
                                            hintStyle: const TextStyle(
                                                color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
                                            filled: true,
                                            fillColor: Constants.WHITE,
                                          ),
                                          controller: _toMonthText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x4ca3c4d4),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset:
                                              Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          cursorColor: Constants.PRIMARY_COLOR,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Constants.FORM_TEXT,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "aaaa",
                                            hintStyle: const TextStyle(
                                                color: Constants.PLACEHOLDER_COLOR),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            suffixIcon: SvgPicture.asset("assets/images/arrow_down.svg", width: 10, height: 6, fit: BoxFit.scaleDown),
                                            contentPadding: const EdgeInsets.all(12),
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
                            SizedBox(height: 32,),
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Show hand withdrawals",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                CupertinoSwitch(
                                  value: _handWithdrawals,
                                  activeColor: Constants.SECONDARY_COLOR,
                                  onChanged: (bool value) { setState(() { _handWithdrawals = value; }); },
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Show shipping",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                CupertinoSwitch(
                                  value: _handWithdrawals,
                                  activeColor: Constants.SECONDARY_COLOR,
                                  onChanged: (bool value) { setState(() { _handWithdrawals = value; }); },
                                ),
                              ],
                            ),
                            Divider(),*/
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Mostra solo nella tua città",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                CupertinoSwitch(
                                  value: _filters.onlySameCity,
                                  activeColor: Constants.SECONDARY_COLOR,
                                  onChanged: (bool value) { setState(() { _filters.onlySameCity = value; }); },
                                ),
                              ],
                            ),
                            /*Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Show compulsory insurance",
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.FONT),
                                  textAlign: TextAlign.center,
                                ),
                                CupertinoSwitch(
                                  value: _handWithdrawals,
                                  activeColor: Constants.SECONDARY_COLOR,
                                  onChanged: (bool value) { setState(() { _handWithdrawals = value; }); },
                                ),
                              ],
                            )*/
                          ],
                        ),
                      ),
                      SizedBox(height: 40,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Constants.SECONDARY_COLOR,
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                        ),
                        child: Text('Applica'),
                        onPressed: () {
                          applyFilters();
                        },
                      ),
                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            top: 16,
            right: 16,
            child: InkWell(
              child: Icon(Icons.close),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
        )
      ],
    );
  }
}
