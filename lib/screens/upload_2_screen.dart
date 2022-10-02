import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/brand.dart';
import 'package:sisterly/models/delivery_mode.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/generic.dart';
import 'package:sisterly/models/material.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/product_color.dart';
import 'package:sisterly/models/var.dart';
import 'package:sisterly/screens/payment_method_screen.dart';
import 'package:sisterly/screens/product_edit_success_screen.dart';
import 'package:sisterly/screens/product_success_screen.dart';
import 'package:sisterly/screens/sister_advice_screen.dart';
import 'package:sisterly/screens/stripe_webview_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../main.dart';
import '../utils/constants.dart';
import 'documents_screen.dart';

class Upload2Screen extends StatefulWidget {
  final Product? editProduct;
  final dynamic step1Params;

  const Upload2Screen({Key? key, this.editProduct, this.step1Params}) : super(key: key);

  @override
  Upload2ScreenState createState() => Upload2ScreenState();
}

class Upload2ScreenState extends State<Upload2Screen> {
  Generic _selectedLenderKit = lenderKits[0];

  /* Address management */
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _address2 = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController(text: "IT");
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool _isLoading = false;
  bool _hasAddress = false;
  bool _saveAddress = true;
  List<Address> _addresses = [];
  Address? _activeAddress;
  bool _addNewAddress = false;
  bool _editAddress = false;
  Address? _addressToEdit;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _getAddresses(() {
        populateEditProduct();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  populateEditProduct() {
    if (widget.editProduct != null) {
      if(widget.editProduct!.lenderKitToSend != null) {
        try {
          _selectedLenderKit = lenderKits.firstWhere((element) => element.id == widget.editProduct!.lenderKitToSend!.id);
        } catch(e) {
          debugPrint("Lender kit not present in lender list");
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Ci siamo quasi..."),
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
                      Text(
                        "A quale indirizzo dobbiamo inviare il Sisterly Kit?",
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 18,
                            fontFamily: Constants.FONT,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 32),
                      if (!_hasAddress || _addNewAddress || _editAddress)
                        Column(children: [
                          inputField("Nome e cognome", _name, false),
                          inputField("Indirizzo", _address, false),
                          inputField("Indirizzo 2", _address2, false),
                          inputField("Città", _city, false),
                          inputField("Codice postale", _zip, false),
                          inputField("Provincia", _state, false),
                          inputField("Nazione", _country, true),
                          inputField("Email", _email, false),
                          inputField("Cellulare", _phone, false),
                          const SizedBox(height: 25),
                        ]),
                      if (_editAddress)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.GREEN_SAVE,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
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
                      if (_hasAddress && !_addNewAddress && !_editAddress)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  if (_activeAddress != null)
                                    _renderAddress(_activeAddress!),
                                  for (var a in _addresses) _renderAddress(a)
                                ]),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Constants.LIGHT_GREY_COLOR2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
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
                      SizedBox(
                        height: 32,
                      ),
                      Text(
                        "Ci siamo quasi!\n\nOgni Lender Sister ha bisogno del suo Lender Kit che contiene un tag univoco per rendere la tua borsa insostituibile (è obbligatorio applicare l’adesivo ed è fondamentale per tutelarti) e una dust bag in cui inserire la tua borsa prima di noleggiarla.\n\nA te la scelta: ",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
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
                            child: DropdownButton<Generic>(
                                items: lenderKits
                                    .map((Generic val) =>
                                        DropdownMenuItem<Generic>(
                                            child: Text(val.name,
                                                style: TextStyle(fontSize: 16)),
                                            value: val))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _selectedLenderKit = val!);
                                },
                                value: _selectedLenderKit),
                          )),
                      SizedBox(height: 32),
                      Center(
                        child: _isLoading ? CircularProgressIndicator() : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Conferma'),
                          onPressed: () async {
                            if (!_hasAddress ||
                                (_saveAddress &&
                                    _addNewAddress &&
                                    !_editAddress)) {
                              saveAddress(() async {
                                _getAddresses(() {
                                  _createProduct();
                                });
                              });
                            } else {
                              _createProduct();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 60)
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

  _createProduct() {
    debugPrint("_createProduct");

    setState(() {
      _isLoading = true;
    });

    var params = widget.step1Params;
    params["delivery_kit_pk"] = _activeAddress!.id;
    params["lender_kit_to_send"] = _selectedLenderKit.id;

    if(widget.editProduct != null) {
      ApiManager(context).makePostRequest('/product/' + widget.editProduct!.id.toString() + "/?version=v2", params, (res) {
        setState(() {
          _isLoading = false;
        });
        if(res["errors"] != null) {
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        } else {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => ProductEditSuccessScreen()), (_) => false);
        }
      }, (res) {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      ApiManager(context).makePutRequest('/product/?version=v2', params, (res) async {
        if(res["errors"] != null) {
          setState(() {
            _isLoading = false;
          });
          ApiManager.showFreeErrorMessage(context, res["errors"].toString());
        } else {
          debugPrint("product success " + jsonEncode(res["data"]));

          await FirebaseAnalytics.instance.logEvent(name: "create_product");
          MyApp.facebookAppEvents.logEvent(name: "create_product");

          if(_selectedLenderKit.id == 3) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (BuildContext context) =>
                    ProductSuccessScreen()), (_) => false);
          } else {
            askPayment(res["data"]["id"]);
          }
        }
      }, (res) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  askPayment(productId) {
    ApiManager(context).makePutRequest('/payment/make/lender-kit/' + productId.toString() + "?version=v2", {}, (res) async {
      setState(() {
        _isLoading = false;
      });
      if(res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        if(res["data"] != null && res["data"]["client_secret"] != null) {
          /*Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => StripeWebviewScreen(title: "Pagamento", url: res["data"]["redirect_url"],)));*/
          Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => PaymentMethodScreen(
                successCallback: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (BuildContext context) =>
                          ProductSuccessScreen()), (_) => false);
                },
                failureCallback: () {
                  ApiManager.showFreeErrorMessage(context, "Pagamento fallito");
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                paymentIntentId: null,
                paymentIntentSecret: res["data"]["client_secret"],
              )));
        } else {
          ApiManager.showFreeErrorMessage(context, "Pagamento fallito");
        }
        /*Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) =>
                ProductSuccessScreen()), (_) => false);*/
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
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
    List<String> menu = ['Elimina', 'Predefinito', 'Modifica'];
    if (address.active) {
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

  _getAddresses(Function? callback) {
    ApiManager(context).makeGetRequest('/client/address', {}, (response) {
      _activeAddress = null;
      _addresses = [];
      if (response["data"] != null) {
        for (var address in response["data"]) {
          if (address["active"]) {
            _activeAddress = Address.fromJson(address);
          } else {
            _addresses.add(Address.fromJson(address));
          }
        }

        if (_addresses.isNotEmpty || _activeAddress != null) {
          setState(() {
            _hasAddress = true;
            _addNewAddress = false;
          });
        }

        setState(() {});

        if (callback != null) callback();
      }
    }, (response) {});
  }

  saveAddress(callback) {
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
        if (callback != null) callback();
      }, (res) {
        if (callback != null) callback();
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
      _removeAddress(address);
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
        _getAddresses(null);
      }, (res) {});
    }
  }
}
