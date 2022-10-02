import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sisterly/models/account.dart';
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
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';

import '../utils/constants.dart';
import 'filters_screen.dart';
import "package:sisterly/utils/utils.dart";

class EditProfileScreen extends StatefulWidget {

  final int? id;

  const EditProfileScreen({Key? key, this.id}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen>  {

  final TextEditingController _usernameText = TextEditingController();
  final TextEditingController _firstNameText = TextEditingController();
  final TextEditingController _lastNameText = TextEditingController();
  final TextEditingController _descriptionText = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _birthDayText = TextEditingController();
  final TextEditingController _birthMonthText = TextEditingController();
  final TextEditingController _birthYearText = TextEditingController();

  final ImagePicker picker = ImagePicker();
  
  XFile? _profileImage;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  Account? _profile;

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
      _isLoadingProfile = true;
    });
    ApiManager(context).makeGetRequest('/client/properties', {}, (res) {
      // print(res);
      setState(() {
        _isLoadingProfile = false;
        _profile = Account.fromJson(res["data"]);

        _usernameText.text = _profile!.username.toString();
        _firstNameText.text = _profile!.firstName.toString();
        _lastNameText.text = _profile!.lastName.toString();
        _descriptionText.text = _profile!.description.toString();
        _cityController.text = _profile!.residencyCity.toString();

        if(_profile!.birthday != null) {
          setBirthDate(_profile!.birthday!);
        }
      });
    }, (res) {
      setState(() {
        _isLoadingProfile = false;
      });
    });
  }

  save() async {
    if (ApiManager.isEmpty(_usernameText.text.trim())) {
      ApiManager.showErrorToast(context, "signup_username_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_firstNameText.text.trim())) {
      ApiManager.showErrorToast(context, "signup_first_name_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_lastNameText.text.trim())) {
      ApiManager.showErrorToast(context, "signup_last_name_mandatory");
      return;
    }

    if (ApiManager.isEmpty(_descriptionText.text.trim())) {
      ApiManager.showErrorToast(context, "signup_description_mandatory");
      return;
    }

    if (_profile!.birthday == null) {
      ApiManager.showErrorToast(context, "signup_birthday_mandatory");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    var params = {
      "username": _usernameText.text,
      "first_name": _firstNameText.text,
      "last_name": _lastNameText.text,
      "description": _descriptionText.text,
      "residency_city": _cityController.text,
      "birthday": DateFormat("yyyy-MM-dd").format(_profile!.birthday!)
    };

    if(_profileImage != null) {
      ApiManager(context).makeUploadRequest(context, "POST", '/client/update', _profileImage!.path, params, (res) {
        // print(res);
        ApiManager.showFreeSuccessMessage(context, "Profilo salvato");
        Utils.updateCrmUser(context);

        setState(() {
          _isLoading = false;
        });
      }, (res) {
        setState(() {
          _isLoading = false;
        });
      }, "image");
    } else {
      ApiManager(context).makePostRequest('/client/update', params, (res) {
        // print(res);
        ApiManager.showFreeSuccessMessage(context, "Profilo salvato");
        Utils.updateCrmUser(context);
        setState(() {
          _isLoading = false;
        });
      }, (res) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  String getFullName() {
    if(_profile == null) return "";
    return _profile!.firstName!.capitalize() + " " + _profile!.lastName!.capitalize();
  }

  String getFirstName() {
    if(_profile == null) return "";
    return _profile!.firstName!.capitalize();
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
    /*if (_images.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });
      debugPrint("uploading " + _images.length.toString() + " images");
      int i = 1;
      for (var photo in _images) {
        ApiManager(context).makeUploadRequest(context, '/client/media/$_mediaId/images', photo.path, i++, (res) {
          debugPrint('Photo uploaded');
          setState(() {
            _isUploading = false;
          });
        }, (res) {
          debugPrint('Failed uploading photo');
          _images.remove(photo);
          setState(() {
            _isUploading = false;
          });
        });
      }

      setState(() {

      });
    }*/
  }

  setBirthDate(DateTime date) {
    _birthDayText.text = date.day.toString();
    _birthMonthText.text = date.month.toString();
    _birthYearText.text = date.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Modifica Profilo"),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 8),
                        _isLoadingProfile ? Center(child: CircularProgressIndicator()) : InkWell(
                          onTap: () async {
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

                            _profileImage = (await picker.pickImage(source: source!))!;

                            _upload();
                            setState(() {});
                          },
                          child: Center(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(90.0),
                                  child: _profileImage != null ? Image.file(File(_profileImage!.path), width: 90, height: 90, fit: BoxFit.cover) : CachedNetworkImage(
                                    width: 90, height: 90, fit: BoxFit.cover,
                                    imageUrl: (_profile!.image ?? ""),
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder.svg"),
                                  ),
                                ),
                                Positioned(bottom: 16, right: 16, child: SvgPicture.asset("assets/images/edit.svg", width: 20,))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Username",
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
                              hintText: "Username..",
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
                            controller: _usernameText,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Nome",
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
                              hintText: "Nome...",
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
                            controller: _firstNameText,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Cognome",
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
                              hintText: "Cognome...",
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
                            controller: _lastNameText,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Descrizione",
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
                              hintText: "Descrizione del profilo...",
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
                            controller: _descriptionText,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Città di residenza",
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
                              hintText: "Città di residenza...",
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
                            controller: _cityController,
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Data di nascita",
                          style: TextStyle(
                              color: Constants.TEXT_COLOR,
                              fontSize: 16,
                              fontFamily: Constants.FONT
                          ),
                        ),
                        SizedBox(height: 8,),
                        InkWell(
                          onTap: () async {
                            debugPrint("show date picker");
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _profile!.birthday != null ? _profile!.birthday! : DateTime.now(),
                              firstDate: DateTime.now().subtract(Duration(days: 150 * 365)),
                              lastDate: DateTime.now(),
                            );

                            setState(() {
                              if(picked != null) {
                                _profile!.birthday = picked;

                                setBirthDate(picked);
                              }
                            });
                          },
                          child: AbsorbPointer(
                            absorbing: true,
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
                                      controller: _birthDayText,
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
                                      controller: _birthMonthText,
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
                                      controller: _birthYearText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        SafeArea(
                          child: Center(
                            child: _isLoading ? CircularProgressIndicator() : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Constants.SECONDARY_COLOR,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: Text('Salva'),
                              onPressed: () {
                                save();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
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
