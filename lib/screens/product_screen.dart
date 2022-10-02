import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:sisterly/models/chat.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/product_availability.dart';
import 'package:sisterly/models/var.dart';
import 'package:sisterly/screens/checkout_screen.dart';
import 'package:sisterly/screens/fullscreen_gallery_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/screens/tab_screen.dart';
import 'package:sisterly/screens/upload_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:sisterly/utils/session_data.dart';
import "package:sisterly/utils/utils.dart";
import 'package:sisterly/widgets/alert/custom_alert.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'documents_screen.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final bool inReview;

  const ProductScreen(this.product, {Key? key, this.inReview = false})
      : super(key: key);

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  late final PageController _calendarController;
  List<Product> _productsFavorite = [];
  DateTime _focusedDay = DateTime.now().add(Duration(days: 1));
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;
  ProductAvailability? _availability;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  List<XFile> _videos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingVideo = false;
  bool _isLoadingAvailability = false;
  List<Document> _documents = [];
  String _shipping = 'shipment';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      getProductsFavorite();
      getProductAvailabilty();
      _getDocuments();

      if (widget.product.deliveryType!.id == 3) {
        _shipping = "shipment";
      }

      if (widget.product.deliveryType!.id == 1) {
        _shipping = "withdraw";
      }

      await FirebaseAnalytics.instance.logViewItem(items: [
        AnalyticsEventItem(
            itemId: widget.product.id.toString(),
            itemName: widget.product.model.toString() +
                " - " +
                widget.product.brandName.toString())
      ]);
      MyApp.facebookAppEvents.logViewContent(id: widget.product.id.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getDocuments() {
    ApiManager(context).makeGetRequest('/client/document', {}, (res) {
      _documents = [];

      var data = res["data"];
      if (data != null) {
        for (var doc in data) {
          _documents.add(Document.fromJson(doc));
        }
      }

      setState(() {});
    }, (res) {});
  }

  Widget getInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + "  :",
          style: TextStyle(
              color: Constants.TEXT_COLOR,
              fontSize: 16,
              fontFamily: Constants.FONT),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
                color: Constants.DARK_TEXT_COLOR,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.FONT),
          ),
        ),
      ],
    );
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

  getProductAvailabilty() {
    setState(() {
      _isLoadingAvailability = true;
    });

    var params = {
      "year": _focusedDay.year.toString(),
      "month": _focusedDay.month.toString(),
      "delivery_mode": _shipping == 'shipment' ? 3 : 1
    };

    ApiManager(context).makeGetRequest(
        '/product/' + widget.product.id.toString() + '/valid_dates/', params,
        (res) {
      _availability = ProductAvailability.fromJson(res["data"]);
      setState(() {
        _isLoadingAvailability = false;
      });
    }, (res) {
      setState(() {
        _isLoadingAvailability = false;
      });
    });
  }

  contact() {
    var params = {"email_user_to": widget.product.owner.email};

    ApiManager(context).makePutRequest('/chat/', params, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      } else {
        ApiManager(context).makeGetRequest(
            '/chat/' + res["data"]["code"] + '/', {}, (chatRes) {
          String initialMessage = 'Hey sister, ho alcune domande sulla borsa ' +
              widget.product.model +
              ' di ' +
              widget.product.brandName;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ChatScreen(
                  chat: Chat.fromJson(chatRes["data"]),
                  code: res["data"]["code"],
                  initialMessage: initialMessage)));
        }, (res) {});
      }
    }, (res) {
      if (res["errors"] != null) {
        ApiManager.showFreeErrorMessage(context, res["errors"].toString());
      }
    });
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

  askUploadVideo() async {
    ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) =>
          AlertDialog(content: Text("Scegli video da"), actions: [
        FlatButton(
          child: Text("Registra ora"),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        FlatButton(
          child: Text("Galleria"),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ]),
    );

    if (source == ImageSource.camera) {
      _videos = [(await _picker.pickVideo(source: ImageSource.camera))!];
      uploadVideo();
    } else if (source == ImageSource.gallery) {
      _videos = [(await _picker.pickVideo(source: ImageSource.gallery))!];
      uploadVideo();
    }

    setState(() {});
  }

  uploadVideo() {
    if (_videos.isNotEmpty) {
      setState(() {
        _isUploadingVideo = true;
      });
      debugPrint("uploading " + _videos.length.toString() + " videos");
      int i = 1;

      var params = {"order": i++};
      ApiManager(context).makeUploadRequest(
          context,
          "PUT",
          '/client/media/' + widget.product.mediaId.toString() + '/videos',
          _videos[0].path,
          params, (res) {
        debugPrint('Video uploaded');
        setState(() {
          _isUploadingVideo = false;
        });

        ApiManager.showFreeSuccessMessageWithCallback(
            context, "Video uploaded successfully!", () {
          Navigator.pop(context);
        });
      }, (res) {
        debugPrint('Failed uploading video');
        _videos.clear();
        setState(() {
          _isUploadingVideo = false;
        });
      }, "video");

      setState(() {});
    }
  }

  DateTime nextWeekday(int day) {
    DateTime now = DateTime.now();
    return now.add(
      Duration(
        days: (day - now.weekday) % DateTime.daysPerWeek,
      ),
    );
  }

  void _handleShipmentRadioChange(String? value) {
    setState(() {
      _shipping = value!;
      _rangeStart = null;
      _rangeEnd = null;
    });

    getProductAvailabilty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.product.images.length > 0) {
                          showDialog(
                              context: context,
                              barrierColor: Colors.black12.withOpacity(0.6),
                              // Background color
                              barrierDismissible: true,
                              builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: FullscreenGalleryScreen(
                                    images: widget.product.images
                                        .map((e) => e.image)
                                        .toList(),
                                  )));
                        }
                        /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => FullscreenGalleryScreen(images: widget.product.images,),
                              fullscreenDialog: true
                            )
                        );*/
                      },
                      child: SizedBox(
                        height: 180,
                        child: PageView(
                          children: [
                            for (var img in widget.product.images)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CachedNetworkImage(
                                    height: 180,
                                    fit: BoxFit.fitHeight,
                                    imageUrl:
                                        (img.image.isNotEmpty ? img.image : ""),
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        SvgPicture.asset(
                                            "assets/images/placeholder_product.svg"),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 16,
                        right: 12,
                        child: isFavorite(widget.product)
                            ? InkWell(
                                child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                        "assets/images/saved.svg")),
                                onTap: () {
                                  setProductFavorite(widget.product, false);
                                },
                              )
                            : InkWell(
                                child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                        "assets/images/save.svg")),
                                onTap: () {
                                  setProductFavorite(widget.product, true);
                                },
                              )),
                    Positioned(
                      left: 16,
                      top: 8,
                      child: InkWell(
                        child: Container(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                                "assets/images/back_black.svg")),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.brandName,
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    widget.product.model,
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 20,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "${Utils.formatCurrency(widget.product.priceOffer)}",
                                    style: TextStyle(
                                        color: Constants.PRIMARY_COLOR,
                                        fontSize: 25,
                                        fontFamily: Constants.FONT,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "${Utils.formatCurrency(widget.product.sellingPrice)}",
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
                              InkWell(
                                onTap: () {
                                  String normalizedBrand = widget
                                      .product.brandName
                                      .replaceAll(RegExp(r'[^\w\s]+'), "")
                                      .replaceAll(" ", "_")
                                      .toLowerCase();
                                  String normalizedModel = widget.product.model
                                      .replaceAll(RegExp(r'[^\w\s]+'), "")
                                      .replaceAll(" ", "_")
                                      .toLowerCase();
                                  String shareText =
                                      "Guarda questo prodotto su Sisterly! https://sisterly.it/noleggio-borse/sisterly/" +
                                          normalizedBrand +
                                          "/" +
                                          normalizedModel +
                                          "/" +
                                          widget.product.id.toString();
                                  debugPrint("shareText " + shareText);
                                  Share.share(shareText);
                                },
                                child: Icon(Icons.share,
                                    color: Constants.SECONDARY_COLOR),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      /*Text(
                        "Mandatory Insurance",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 12),*/
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProfileScreen(id: widget.product.owner.id)));
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(68.0),
                              child: CachedNetworkImage(
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                imageUrl: (widget.product.owner.image ?? ""),
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    SvgPicture.asset(
                                        "assets/images/placeholder.svg"),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Pubblicata da " +
                                          widget.product.owner.username!
                                              .capitalize(),
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 16,
                                          fontFamily: Constants.FONT),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launch(
                                            "https://www.sisterly.it/faq.html");
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: Constants.PRIMARY_COLOR,
                                      ),
                                    )
                                  ],
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
                                    StarsWidget(
                                        stars: widget
                                            .product.owner.reviewsMedia!
                                            .toInt()),
                                    Text(
                                      widget.product.owner.reviewsMedia
                                          .toString(),
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
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 30,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      getInfoRow(
                          "Condizioni", widget.product.conditions.toString()),
                      SizedBox(
                        height: 8,
                      ),
                      getInfoRow("Anni", widget.product.year.toString()),
                      SizedBox(
                        height: 8,
                      ),
                      getInfoRow("Misura", widget.product.size.toString()),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 30,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Descrizione",
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.product.description.toString(),
                        style: TextStyle(
                            color: Constants.TEXT_COLOR,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: Constants.FONT),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        height: 30,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      /*Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "• Cross body bag in leather with woven pattern",
                            style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.FONT
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "• Single inside pocket with zip",
                            style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.FONT
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "• Metal closure",
                            style: TextStyle(
                                color: Constants.TEXT_COLOR,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.FONT
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),*/
                      //Divider(height: 30,),
                      //SizedBox(height: 8,),
                      getInfoRow("Materiale", widget.product.materialName),
                      SizedBox(
                        height: 8,
                      ),
                      getInfoRow(
                          "Colore",
                          widget.product.colors
                              .map((e) => e.color.capitalize())
                              .join(", ")),
                      SizedBox(
                        height: 8,
                      ),
                      getInfoRow(
                          "Categorie",
                          widget.product.categories
                              .map((e) => e.category.capitalize())
                              .join(", ")),
                      if (widget.product.deliveryType != null)
                        SizedBox(
                          height: 8,
                        ),
                      if (widget.product.deliveryType != null)
                        getInfoRow(
                            "Consegna",
                            getDeliveryTypeName(
                                widget.product.deliveryType!.id)),
                      /*SizedBox(height: 8,),
                      getInfoRow("Metal Accessories", "Gold Finish"),
                      SizedBox(height: 8,),
                      getInfoRow("Height", "18cm"),
                      SizedBox(height: 8,),
                      getInfoRow("Width", "26cm"),*/
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Come vuoi ricevere il prodotto?",
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 18,
                            fontFamily: Constants.FONT,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.product.deliveryType!.id == 3 ||
                                widget.product.deliveryType!.id == 13)
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
                                                : Constants.DARK_TEXT_COLOR),
                                  ),
                                  leading: Radio(
                                      value: 'shipment',
                                      groupValue: _shipping,
                                      activeColor: Constants.SECONDARY_COLOR,
                                      fillColor: MaterialStateColor.resolveWith(
                                          (states) => _shipping == 'shipment'
                                              ? Constants.SECONDARY_COLOR
                                              : Constants.DARK_TEXT_COLOR),
                                      onChanged: _handleShipmentRadioChange),
                                ),
                              ),
                            if (widget.product.deliveryType!.id == 1 ||
                                widget.product.deliveryType!.id == 13)
                              Expanded(
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
                                                : Constants.DARK_TEXT_COLOR),
                                  ),
                                  leading: Radio(
                                      value: 'withdraw',
                                      groupValue: _shipping,
                                      fillColor: MaterialStateColor.resolveWith(
                                          (states) => _shipping == 'withdraw'
                                              ? Constants.SECONDARY_COLOR
                                              : Constants.DARK_TEXT_COLOR),
                                      onChanged: _handleShipmentRadioChange),
                                ),
                              ),
                          ]),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy', 'it_IT')
                                .format(_focusedDay)
                                .capitalize(),
                            style: TextStyle(
                                color: Constants.PRIMARY_COLOR,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.FONT),
                          ),
                          if (_isLoadingAvailability)
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator()),
                          Wrap(
                            children: [
                              InkWell(
                                onTap: () {
                                  _calendarController.previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: RotatedBox(
                                    quarterTurns: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: SvgPicture.asset(
                                        "assets/images/arrow_right.svg",
                                        width: 10,
                                      ),
                                    )),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  _calendarController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: SvgPicture.asset(
                                    "assets/images/arrow_right.svg",
                                    width: 10,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Opacity(
                        opacity: _isLoadingAvailability ? 0.4 : 1,
                        child: AbsorbPointer(
                          absorbing: _isLoadingAvailability,
                          child: TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay: DateTime.utc(2040, 3, 14),
                            focusedDay: _focusedDay,
                            rowHeight: 28,
                            rangeStartDay: _rangeStart,
                            rangeEndDay: _rangeEnd,
                            rangeSelectionMode: _rangeSelectionMode,
                            enabledDayPredicate: (day) {
                              if (_availability != null &&
                                  _availability!.validDays.contains(day.day)) {
                                return true;
                              }

                              return false;
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                  _rangeStart =
                                      null; // Important to clean those
                                  _rangeEnd = null;
                                  _rangeSelectionMode =
                                      RangeSelectionMode.toggledOff;

                                  getProductAvailabilty();
                                });
                              }
                            },
                            onRangeSelected: (start, end, focusedDay) {
                              setState(() {
                                _selectedDay = null;
                                _focusedDay = focusedDay;
                                _rangeStart = start;
                                _rangeEnd = end;
                                _rangeSelectionMode =
                                    RangeSelectionMode.toggledOn;

                                getProductAvailabilty();
                              });
                            },
                            onCalendarCreated: (controller) =>
                                _calendarController = controller,
                            onPageChanged: (focusedDay) {
                              debugPrint("focusedDay " + focusedDay.toString());
                              setState(() {
                                _focusedDay = focusedDay;
                              });

                              getProductAvailabilty();
                            },
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            daysOfWeekStyle: DaysOfWeekStyle(
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromARGB(31, 134, 61, 61))),
                              ),
                            ),
                            daysOfWeekHeight: 40,
                            calendarBuilders: CalendarBuilders(
                              dowBuilder: (context, day) {
                                final text = DateFormat.E("it_IT")
                                    .format(day)
                                    .capitalize();

                                return Center(
                                  child: Text(
                                    text,
                                    style: TextStyle(color: Color(0xff333333)),
                                  ),
                                );
                              },
                              withinRangeBuilder: (context, day, focusedDay) {
                                //debugPrint("defaultBuilder");
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Constants.SECONDARY_COLOR),
                                  child: FittedBox(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ))),
                                );
                              },
                              rangeStartBuilder: (context, day, focusedDay) {
                                //debugPrint("defaultBuilder");
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Constants.SECONDARY_COLOR),
                                  child: FittedBox(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ))),
                                );
                              },
                              rangeEndBuilder: (context, day, focusedDay) {
                                //debugPrint("defaultBuilder");
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Constants.SECONDARY_COLOR),
                                  child: FittedBox(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ))),
                                );
                              },
                              defaultBuilder: (context, day, focusedDay) {
                                //debugPrint("defaultBuilder");
                                return Container(
                                  alignment: Alignment.center,
                                  decoration:
                                      BoxDecoration(color: Color(0x40ffa8a8)),
                                  child: FittedBox(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ))),
                                );
                              },
                              disabledBuilder: (context, day, focusedDay) {
                                //debugPrint("defaultBuilder");
                                return Container(
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                                color: Color(0xffcccccc),
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          ))),
                                );
                              },
                            ),
                            headerVisible: false,
                            locale: "it_IT",
                          ),
                        ),
                      ),
                      if (widget.product.usePriceAlgorithm)
                        SizedBox(
                          height: 40,
                        ),
                      if (widget.product.usePriceAlgorithm)
                        Text(
                            "Questa borsa rientra in un gruppo ristretto di prodotti ai quali si applicano scontistiche particolari per noleggi con durate superiori a 3 giorni"),
                      SizedBox(
                        height: 16,
                      ),
                      if (_documents.isEmpty) SizedBox(height: 15),
                      if (_documents.isEmpty)
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DocumentsScreen()));

                            _getDocuments();
                          },
                          child: Card(
                            color: Color(0x88FF8A80),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: const [
                                  Text(
                                    'Per procedere con la prenotazione della borsa è necessario caricare i documenti necessari',
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
                      // if(widget.product.owner.id == SessionData().userId) Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Text('Nascondi'),
                      //     Switch(
                      //       value: widget.product.status == 5 ? true : false,
                      //       onChanged: (value) {
                      //         CustomAlert.show(context,
                      //           //title: AppLocalizations.of(context).translate("generic_success"),
                      //           confirmButtonColor: Constants.SECONDARY_COLOR,
                      //           subtitle: value ?
                      //             'Nascondi temporaneamente questo prodotto, potrai renderlo nuovamente disponibile appena vorrai dalla sezione "i tuoi prodotti"'
                      //             : 'Puoi usare il tuo portafoglio su Sisterly.',
                      //           showCancelButton: true,
                      //           cancelButtonText: "Annulla",
                      //           cancelButtonColor: Colors.white,
                      //           //style: CustomAlertStyle.success,
                      //           onPress: (bool isConfirm) {
                      //             if (!isConfirm) {
                      //               Navigator.of(context).pop();
                      //               return false;
                      //             }

                      //             var params = {
                      //               "active": !value
                      //             };

                      //             ApiManager(context).makePostRequest('/product/' + widget.product.id.toString() + "/active", params, (res) {
                      //               if(res["errors"] != null) {
                      //                 ApiManager.showFreeErrorMessage(context, res["errors"].toString());
                      //               }
                      //               else {
                      //                 Fluttertoast.showToast(
                      //                   msg: value ? 'Il tuo prodotto è ora non disponibile' : 'Il tuo prodotto è ora disponibile',
                      //                   toastLength: Toast.LENGTH_LONG,
                      //                   timeInSecForIosWeb: 3,
                      //                   gravity: ToastGravity.CENTER,
                      //                   backgroundColor: Colors.redAccent,
                      //                   textColor: Colors.white,
                      //                   fontSize: 16.0
                      //                 );

                      //                 Future.delayed(const Duration(seconds: 3), (){
                      //                   Navigator.of(context).pushAndRemoveUntil(
                      //                     MaterialPageRoute(builder: (BuildContext context) => TabScreen()), (_) => false);
                      //                 });
                      //               }
                      //             }, (res) {});

                      //             return false;
                      //           }
                      //         );
                      //       },
                      //     ),
                      //   ],
                      // ),
                      // if(widget.product.owner.id == SessionData().userId) GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(id: null, unavailableState: true)));
                      //   },
                      //   child: Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.end,
                      //       children: const [
                      //         Text(
                      //           'Prodotti nascosti',
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             decoration: TextDecoration.underline,
                      //             fontFamily: Constants.FONT
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      if (_documents.isEmpty) SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.product.owner.id != SessionData().userId)
                            Expanded(
                                child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  primary: Constants.PRIMARY_COLOR,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  side: const BorderSide(
                                      color: Constants.PRIMARY_COLOR, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                              child: Text(
                                "Contatta",
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                contact();
                              },
                            )),
                          if (widget.product.owner.id != SessionData().userId)
                            SizedBox(
                              width: 12,
                            ),
                          if (widget.product.owner.id != SessionData().userId)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Constants.SECONDARY_COLOR,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 46, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                child: Text('Prenota'),
                                onPressed: () async {
                                  if (_documents.isEmpty) {
                                    ApiManager.showFreeErrorMessage(context,
                                        "Per procedere con la prenotazione della borsa è necessario caricare i documenti necessari");
                                    return;
                                  }

                                  if (widget.product.owner.holidayMode!) {
                                    ApiManager.showFreeErrorMessage(context,
                                        "L'utente in questione ha attivato la modalità vacanza, non sarà possibile prenotare la borsa fino al suo rientro. Riprova tra qualche giorno");
                                    return;
                                  }

                                  if (_rangeStart == null ||
                                      _rangeEnd == null) {
                                    ApiManager.showFreeErrorMessage(context,
                                        "Seleziona il periodo desiderato. Minimo 3 giorni.");
                                    return;
                                  }

                                  if (_rangeEnd!
                                          .difference(_rangeStart!)
                                          .inDays <
                                      2) {
                                    ApiManager.showFreeErrorMessage(context,
                                        "Seleziona un periodo minimo di 3 giorni.");
                                    return;
                                  }

                                  if (_shipping == "shipment") {
                                    if (_rangeStart!.weekday == 6 ||
                                        _rangeStart!.weekday == 7 ||
                                        _rangeEnd!.weekday == 6 ||
                                        _rangeEnd!.weekday == 7) {
                                      //sabato o domenica
                                      ApiManager.showFreeErrorMessage(context,
                                          "Il noleggio CON SPEDIZIONE non può iniziare o terminare il Sabato e/o la Domenica");
                                      return;
                                    }

                                    /*DateTime now = DateTime.now();
                                  if(DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day).difference(DateTime(now.year, now.month, now.day)).inDays == 1) {
                                    ApiManager.showFreeErrorMessage(context, "Il noleggio non può partire il giorno seguente rispetto a quello di prenotazione");
                                    return;
                                  }

                                  if(now.weekday == 5 || now.weekday == 6 || now.weekday == 7 ) { //venerdi, sabato o domenica
                                    var nextMonday = nextWeekday(1);
                                    debugPrint("now: "+now.toIso8601String());
                                    debugPrint("nextMonday: "+nextMonday.toIso8601String());

                                    if(DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day).difference(DateTime(nextMonday.year, nextMonday.month, nextMonday.day)).inDays == 0) {
                                      ApiManager.showFreeErrorMessage(context, "Se oggi è Venerdì, Sabato o Domenica, il noleggio NON può partire dal Lunedì successivo");
                                      return;
                                    }
                                  }*/
                                  }

                                  await FirebaseAnalytics.instance
                                      .logAddToCart(items: [
                                    AnalyticsEventItem(
                                        itemId: widget.product.id.toString(),
                                        itemName: widget.product.model
                                                .toString() +
                                            " - " +
                                            widget.product.brandName.toString())
                                  ]);

                                  MyApp.facebookAppEvents.logAddToCart(
                                      id: widget.product.id.toString(),
                                      type: "product",
                                      currency: "EUR",
                                      price: widget.product.priceOffer);

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CheckoutScreen(
                                            product: widget.product,
                                            startDate: _rangeStart!,
                                            endDate: _rangeEnd!,
                                            shipping: _shipping,
                                          )));
                                },
                              ),
                            ),
                          if (widget.product.owner.id == SessionData().userId)
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Constants.SECONDARY_COLOR,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 46, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                  child: Text('Modifica'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                UploadScreen(
                                                  editProduct: widget.product,
                                                )));
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Constants.SECONDARY_COLOR,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 46, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                  child: Text('Elimina'),
                                  onPressed: () {
                                    CustomAlert.show(context,
                                        //title: AppLocalizations.of(context).translate("generic_success"),
                                        confirmButtonColor:
                                            Constants.SECONDARY_COLOR,
                                        subtitle: widget.product.activeOrder
                                            ? "Ti ricordiamo che hai un noleggio in programma per questa borsa. Se decidi di eliminarla dovrai avvisare e rimborsare la Borrower. (fai riferimento alle condizioni generali di noleggio)"
                                            : "Voi veramente eliminare la tua borsa da Sisterly",
                                        showCancelButton: true,
                                        cancelButtonText: "Annulla",
                                        cancelButtonColor: Colors.white,
                                        //style: CustomAlertStyle.success,
                                        onPress: (bool isConfirm) {
                                      if (!isConfirm) {
                                        Navigator.of(context).pop();
                                        return false;
                                      }

                                      ApiManager(context).makeDeleteRequest(
                                          "/product/" +
                                              widget.product.id.toString() +
                                              '/', (res) {
                                        print(res);
                                        Fluttertoast.showToast(
                                            msg:
                                                'Richiesta prodotto eliminata!',
                                            toastLength: Toast.LENGTH_LONG,
                                            timeInSecForIosWeb: 3,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.redAccent,
                                            textColor: Colors.white,
                                            fontSize: 16.0);

                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          TabScreen()),
                                                  (_) => false);
                                        });
                                      }, (res) {
                                        setState(() {
                                          _isLoadingAvailability = false;
                                        });

                                        Fluttertoast.showToast(
                                            msg: 'Richiesta prodotto Fallita!',
                                            toastLength: Toast.LENGTH_LONG,
                                            timeInSecForIosWeb: 3,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.redAccent,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      });

                                      return false;
                                    });
                                  },
                                ),
                              ],
                            )),
                        ],
                      ),
                      if (widget.product.owner.id == SessionData().userId &&
                          widget.inReview)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _isUploadingVideo
                              ? Center(child: CircularProgressIndicator())
                              : Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Constants.SECONDARY_COLOR,
                                            textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 46, vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                        child: Text('Carica video'),
                                        onPressed: () {
                                          askUploadVideo();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      if (widget.product.owner.id == SessionData().userId)
                        SizedBox(
                          height: 190,
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
