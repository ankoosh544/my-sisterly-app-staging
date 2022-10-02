import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/claim_success_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../utils/constants.dart';

class AddClaimScreen extends StatefulWidget {
  final Product? product;
  final Offer? offer;
  final bool isSeller;

  const AddClaimScreen({Key? key, this.product, this.offer, required this.isSeller}) : super(key: key);

  @override
  AddClaimScreenState createState() => AddClaimScreenState();
}

class AddClaimScreenState extends State<AddClaimScreen> {

  final TextEditingController _descriptionText = TextEditingController();
  String? _mediaId;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _getMediaId();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getMediaId() {
    ApiManager(context).makePutRequest('/client/media', {}, (res) {
      _mediaId = res["data"]["id"];

      setState(() {

      });
    }, (res) {});
  }

  _upload() {
    if (_images.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });
      debugPrint("uploading " + _images.length.toString() + " images");
      int i = 1;
      for (var photo in _images) {
        var params = {
          "order": i++
        };
        ApiManager(context).makeUploadRequest(context, "PUT", '/client/media/$_mediaId/images', photo.path, params, (res) {
          debugPrint('Photo uploaded');
          setState(() {
            _isUploading = false;
          });

          _imageUrls.add(res["data"]["image"]["image"]);
        }, (res) {
          debugPrint('Failed uploading photo');
          _images.remove(photo);
          setState(() {
            _isUploading = false;
          });
        }, "image");
      }

      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Reclamo"),
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
                      SizedBox(height: 8),
                      Text(
                        "Invia un reclamo",
                        // per il prodotto " + widget.product!.model.toString(),
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(height: 32),
                      Text(
                        "Commento",
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
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          cursorColor: Constants.PRIMARY_COLOR,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Constants.FORM_TEXT,
                          ),
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                widget.isSeller ? "Se ci sono danni causati da incuria da parte della borrower, segnalali subito." : "Se ci sono dei difetti in più rispetto a quello delle foto/descrizione della lender. Segnalali subito in modo da non assumerti le responsabilità per eventuali danni già presenti.",
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
                      if(!_isUploading) Text(
                        "Carica una foto",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT),
                      ),
                      if(_isUploading) CircularProgressIndicator(),
                      SizedBox(height: 8),
                      if(_imageUrls.isNotEmpty) ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: _imageUrls[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg"),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(color: Constants.SECONDARY_COLOR)),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 46, vertical: 14)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))
                        ),
                        child: Text(
                            "Carica foto",
                            style: TextStyle(
                                color: Constants.SECONDARY_COLOR,
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
                            _images = [(await _picker.pickImage(source: ImageSource.camera))!];
                          } else {
                            _images = [(await _picker.pickImage(source: ImageSource.gallery))!];
                          }

                          _upload();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Constants.SECONDARY_COLOR,
                              textStyle: const TextStyle(fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: Text('Invia'),
                          onPressed: () async {
                            next();
                          },
                        ),
                      ),
                      SizedBox(height: 60),
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
    debugPrint("next");
    if (_descriptionText.text.isEmpty) {
      ApiManager.showFreeErrorToast(context, "Inserisci un commento");
      return;
    }

    var params = {"description": _descriptionText.text.toString()};

    ApiManager(context).makePutRequest('/product/order/' + widget.offer!.id.toString() + "/complain", params, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => ClaimSuccessScreen()),
            (_) => false);
      }
    }, (res) {});
  }
}
