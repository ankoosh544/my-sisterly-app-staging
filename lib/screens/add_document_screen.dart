import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
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
import 'package:sisterly/screens/product_success_screen.dart';
import 'package:sisterly/screens/sister_advice_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../models/account.dart';
import '../utils/constants.dart';

class AddDocumentScreen extends StatefulWidget {

  const AddDocumentScreen({Key? key}) : super(key: key);

  @override
  AddDocumentScreenState createState() => AddDocumentScreenState();
}

class AddDocumentScreenState extends State<AddDocumentScreen>  {

  final ImagePicker picker = ImagePicker();
  XFile? _frontDocumentImage;
  XFile? _backDocumentImage;
  String? _frontDocumentUrl;
  String? _backDocumentUrl;
  bool _isUploading = false;

  bool _isLoading = false;

  DateTime? _documentExpirationDate;

  final TextEditingController _documentNumberText = TextEditingController();
  final TextEditingController _fiscalCodeText = TextEditingController();

  Generic _selectedDocumentType = documentTypes.first;
  Account? _profile;

  final TextEditingController _expirationDayText = TextEditingController();
  final TextEditingController _expirationMonthText = TextEditingController();
  final TextEditingController _expirationYearText = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getUser();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUser() {
    setState(() {
      _isLoading = true;
    });
    ApiManager(context).makeGetRequest('/client/properties', {}, (res) {
      // print(res);
      setState(() {
        _isLoading = false;

        _profile = Account.fromJson(res["data"]);

        _fiscalCodeText.text = "";
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<bool> checkAndRequestCameraPermissions() async {
    PermissionStatus permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera
      ].request();
      return statuses[Permission.camera] == PermissionStatus.granted;
    } else {
      return true;
    }
  }

  _upload() {
    if(_documentNumberText.text.isEmpty) {
      ApiManager.showFreeErrorToast(context, "Il numero documento è obbligatorio");
      return;
    }

    if(_documentExpirationDate == null) {
      ApiManager.showFreeErrorToast(context, "La data di scadenza documento è obbligatoria");
      return;
    }

    if(_fiscalCodeText.text.isEmpty) {
      ApiManager.showFreeErrorToast(context, "Il codice fiscale è obbligatorio");
      return;
    }

    if(_frontDocumentImage == null) {
      ApiManager.showFreeErrorToast(context, "L'immagine fronte del documento è obbligatoria");
      return;
    }

    /*if(_backDocumentImage == null) {
      ApiManager.showFreeErrorToast(context, "L'immagine retro del documento è obbligatoria");
      return;
    }*/

    setState(() {
      _isUploading = true;
    });

    var params = {
      "document_type": _selectedDocumentType.id,
      "document_number": _documentNumberText.text,
      "expiration_date": DateFormat("yyyy-MM-dd").format(_documentExpirationDate!)
    };
    ApiManager(context).makeUploadDocumentsRequest(context, "POST", '/client/document', _frontDocumentImage, _backDocumentImage, params, (res) async {
      debugPrint('Document uploaded');
      setState(() {
        _isUploading = false;
      });

      await FirebaseAnalytics.instance.logEvent(name: "upload_document");

      saveProfile();
    }, (res) {
      debugPrint('Failed uploading photo');

      setState(() {
        _isUploading = false;
      });
    });

    setState(() {

    });
  }

  saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    var params = {
      "identity_code": _fiscalCodeText.text
    };

    ApiManager(context).makePostRequest('/client/update', params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });

  }

  setExpirationDate(DateTime? date) {
    if(date != null) {
      _expirationDayText.text = date.day.toString();
      _expirationMonthText.text = date.month.toString();
      _expirationYearText.text = date.year.toString();
    } else {
      _expirationDayText.text = "";
      _expirationMonthText.text = "";
      _expirationYearText.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Carica documento"),
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
                    children: <Widget>[
                      SizedBox(height: 8),
                      Text(
                        "Tipo documento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 8,),
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
                                items: documentTypes
                                    .map((Generic val) =>
                                    DropdownMenuItem<Generic>(
                                        child: Text(val.name,
                                            style: TextStyle(fontSize: 16)),
                                        value: val))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _selectedDocumentType = val!);
                                },
                                value: _selectedDocumentType),
                          )),
                      SizedBox(height: 32),
                      Text(
                        "Numero documento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 8,),
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
                            hintText: "Numero documento",
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
                          controller: _documentNumberText,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Data scadenza documento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4,),
                      InkWell(
                        onTap: () async {
                          debugPrint("show date picker");
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _documentExpirationDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 1)),
                            lastDate: DateTime.now().add(Duration(days: 70000)),
                          );

                          setState(() {
                            if(picked != null) {
                              _documentExpirationDate = picked;

                              setExpirationDate(_documentExpirationDate!);
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
                                      fontSize: 14,
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
                                    controller: _expirationDayText,
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
                                      fontSize: 14,
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
                                    controller: _expirationMonthText,
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
                                      fontSize: 14,
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
                                    controller: _expirationYearText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32,),
                      Text(
                        "Codice fiscale",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 8,),
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
                            hintText: "Codice fiscale",
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
                          controller: _fiscalCodeText,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Immagine fronte del documento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 8,),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Constants.SECONDARY_COLOR_LIGHT
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Constants.SECONDARY_COLOR),
                                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 46, vertical: 14)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))
                              ),
                              child: Text(
                                "Carica fronte",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: Constants.FONT
                                )
                              ),
                              onPressed: () async {
                                ImageSource? source = await showDialog<ImageSource>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      content: Text("Scegli immagine da"),
                                      actions: [
                                        FlatButton(
                                          child: Text("Scatta ora"),
                                          onPressed: () => Navigator.pop(context, ImageSource.camera),
                                        ),
                                        FlatButton(
                                          child: Text("Galleria"),
                                          onPressed: () => Navigator.pop(context, ImageSource.gallery),
                                        ),
                                      ]
                                  ),
                                );

                                if(source == ImageSource.camera) {
                                  _frontDocumentImage = (await picker.pickImage(source: ImageSource.camera))!;
                                } else {
                                  _frontDocumentImage = (await picker.pickImage(source: ImageSource.gallery))!;
                                }

                                setState(() {});
                              },
                            ),
                            if (_frontDocumentImage != null) SizedBox(height: 12),
                            if(_isUploading) CircularProgressIndicator(),
                            if (_frontDocumentImage != null) SizedBox(height: 16),
                            if (_frontDocumentImage != null) ClipRRect(
                              child: Image.file(File(_frontDocumentImage!.path)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            SizedBox(height: 10)
                          ]
                        )
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Immagine retro del documento",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 8,),
                      Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Constants.SECONDARY_COLOR_LIGHT
                          ),
                          child: Column(
                              children: [
                                SizedBox(height: 10),
                                TextButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Constants.SECONDARY_COLOR),
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 46, vertical: 14)),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))
                                  ),
                                  child: Text(
                                      "Carica retro",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: Constants.FONT
                                      )
                                  ),
                                  onPressed: () async {
                                    ImageSource? source = await showDialog<ImageSource>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          content: Text("Scegli immagine da"),
                                          actions: [
                                            FlatButton(
                                              child: Text("Scatta ora"),
                                              onPressed: () => Navigator.pop(context, ImageSource.camera),
                                            ),
                                            FlatButton(
                                              child: Text("Galleria"),
                                              onPressed: () => Navigator.pop(context, ImageSource.gallery),
                                            ),
                                          ]
                                      ),
                                    );

                                    if(source == ImageSource.camera) {
                                      _backDocumentImage = (await picker.pickImage(source: ImageSource.camera))!;
                                    } else {
                                      _backDocumentImage = (await picker.pickImage(source: ImageSource.gallery))!;
                                    }

                                    setState(() {});
                                  },
                                ),
                                if (_backDocumentImage != null) SizedBox(height: 12),
                                if(_isUploading) CircularProgressIndicator(),
                                if (_backDocumentImage != null) SizedBox(height: 16),
                                if (_backDocumentImage != null) ClipRRect(
                                  child: Image.file(File(_backDocumentImage!.path)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                SizedBox(height: 10)
                              ]
                          )
                      ),
                      SizedBox(height: 60),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Conferma'),
                          onPressed: () async {
                            _upload();
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

}
