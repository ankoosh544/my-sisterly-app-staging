import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/screens/documents_screen.dart';
import 'package:sisterly/screens/edit_profile_screen.dart';
import 'package:sisterly/screens/inbox_screen.dart';
import 'package:sisterly/screens/offers_history_screen.dart';
import 'package:sisterly/screens/offers_screen.dart';
import 'package:sisterly/screens/orders_screen.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/screens/reviews_screen.dart';
import 'package:sisterly/screens/info_screen.dart';
import 'package:sisterly/screens/sister_advice_screen.dart';
import 'package:sisterly/screens/stripe_webview_screen.dart';
import 'package:sisterly/screens/welcome_2_screen.dart';
import 'package:sisterly/screens/welcome_screen.dart';
import 'package:sisterly/screens/wishlist_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:share/share.dart';
import "package:sisterly/utils/utils.dart";
import 'package:sisterly/widgets/alert/custom_alert.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import '../utils/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  Account? _profile;
  PackageInfo? _packageInfo;
  String? _stripeLoginUrl;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      getUser();
      getStripeLoginUrl();

      _packageInfo = await PackageInfo.fromPlatform();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getStripeLoginUrl() {
    ApiManager(context).makePostRequest('/client/stripe-connect/login', {},
        (res) async {
      setState(() {
        if (res["data"] != null) {
          _stripeLoginUrl = res["data"]["url"];
        }
      });
    }, (res) {});
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
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  String getFullName() {
    if (_profile == null) return "";
    return _profile!.firstName!.capitalize() +
        " " +
        _profile!.lastName!.capitalize();
  }

  Widget getItem(String icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: SvgPicture.asset(
                icon,
                width: 15,
                fit: BoxFit.scaleDown,
              )),
          SizedBox(
            width: 18,
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.FONT),
            ),
          ),
          SvgPicture.asset("assets/images/arrow.svg")
        ],
      ),
    );
  }

  Widget getSwitchItem(String icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: SvgPicture.asset(
                icon,
                width: 15,
                fit: BoxFit.scaleDown,
              )),
          SizedBox(
            width: 18,
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.FONT),
                ),
                SizedBox(
                  width: 12,
                ),
                InkWell(
                  onTap: () {
                    ApiManager.showFreeSuccessMessage(context,
                        "Devi partire e non riesci a consegnare le tue borse alle Borrower Sisters?\n\nVuoi indossare tu le tue borse e vuoi rendere momentaneamente non disponibili per il noleggio?\n\nSeleziona la modalità vacanza per nascondere le tue borse e toglila quando vuoi tornare a noleggiare.");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Icon(
                      Icons.info_outline,
                      color: Constants.SECONDARY_COLOR,
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_profile != null)
            CupertinoSwitch(
              value: _profile!.holidayMode!,
              activeColor: Constants.SECONDARY_COLOR,
              onChanged: (bool value) {
                var params = {"set_holiday_mode": value};
                ApiManager(context)
                    .makePostRequest('/client/holiday_mode', params, (res) {
                  // print(res);
                  //ApiManager.showFreeSuccessMessage(context, "Profilo salvato");

                  getUser();
                }, (res) {});
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Il tuo profilo"),
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
                        _isLoading
                            ? CircularProgressIndicator()
                            : Row(
                                children: [
                                  if (_profile != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(68.0),
                                      child: CachedNetworkImage(
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        imageUrl: (_profile!.image ?? ""),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            SvgPicture.asset(
                                                "assets/images/placeholder.svg"),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getFullName(),
                                        style: TextStyle(
                                            color: Constants.DARK_TEXT_COLOR,
                                            fontSize: 20,
                                            fontFamily: Constants.FONT),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Wrap(
                                        spacing: 3,
                                        children: [
                                          if (_profile != null)
                                            StarsWidget(
                                                stars: _profile!.reviewsMedia!
                                                    .toInt()),
                                          if (_profile != null)
                                            Text(
                                              _profile!.reviewsMedia!
                                                  .toString(),
                                              style: TextStyle(
                                                  color:
                                                      Constants.DARK_TEXT_COLOR,
                                                  fontSize: 14,
                                                  fontFamily: Constants.FONT),
                                            ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 24,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProfileScreen(
                                      id: null,
                                    )));
                          },
                          child: Text(
                            "Vai al tuo profilo",
                            style: TextStyle(
                                color: Constants.PRIMARY_COLOR,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontFamily: Constants.FONT),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Welcome2Screen(showLogin: false)));
                            },
                            child: getItem("assets/images/guidebook.svg",
                                "Guida Sisterly")),
                        InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EditProfileScreen()));

                              getUser();
                            },
                            child: getItem("assets/images/edit.svg",
                                "Modifica il tuo Profilo")),
                        InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DocumentsScreen()));

                              getUser();
                            },
                            child: getItem(
                                "assets/images/document.svg", "Documenti")),
                        Opacity(
                          opacity: _stripeLoginUrl != null ? 1.0 : 0.4,
                          child: InkWell(
                              onTap: () async {
                                if (_stripeLoginUrl != null) {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              StripeWebviewScreen(
                                                  url: _stripeLoginUrl!,
                                                  title: "Wallet")));

                                  //_stripeLoginUrl

                                  getUser();
                                } else {}
                              },
                              child: getItem(
                                  "assets/images/wallet.svg", "Wallet")),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WishlistScreen()));
                            },
                            child: getItem("assets/images/articles_saved.svg",
                                "Wishlist")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OrdersScreen()));
                            },
                            child:
                                getItem("assets/images/rent 2.svg", "Noleggi")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OffersScreen()));
                            },
                            child: getItem(
                                "assets/images/offers.svg", "Richieste")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      OffersHistoryScreen()));
                            },
                            child: getItem(
                                "assets/images/rent 2.svg", "Storico noleggi")),
                        /*InkWell(
                            onTap: () {

                            },
                            child: getItem("assets/images/chat.svg", "Sister Talks")
                        ),*/
                        InkWell(
                            onTap: () {
                              Share.share(
                                  'Hey sister! Più siamo e più borse abbiamo! Unisciti a Sisterly e diventa una di noi. https://sisterly.page.link/sisterly');
                            },
                            child: getItem("assets/images/invite.svg",
                                "Invita una Sister")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      InfoScreen()));
                            },
                            child: getItem("assets/images/info.svg", "Info")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ProfileScreen(
                                        id: null,
                                      )));
                            },
                            child: getItem(
                                "assets/images/bags.svg", "I tuoi prodotti")),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ReviewsScreen(
                                        userId: SessionData().userId!,
                                      )));
                            },
                            child: getItem("assets/images/review.svg",
                                "Le tue recensioni")),
                        getSwitchItem(
                            "assets/images/vacation.svg", "Modalità Vacanza"),
                        InkWell(
                            onTap: () {
                              CustomAlert.show(context,
                                  //title: AppLocalizations.of(context).translate("generic_success"),
                                  confirmButtonColor: Constants.SECONDARY_COLOR,
                                  subtitle:
                                      "Hey Sister,\nsei sicura di voler eliminare il tuo account?",
                                  showCancelButton: true,
                                  cancelButtonText: "Annulla",
                                  cancelButtonColor: Colors.white,
                                  //style: CustomAlertStyle.success,
                                  onPress: (bool isConfirm) {
                                if (!isConfirm) {
                                  Navigator.of(context).pop();
                                  return false;
                                }

                                Utils.deleteCrmUser(context);
                                debugPrint("AFTER DELETE CRM USER");

                                ApiManager(context).makeDeleteRequest(
                                    "/client/account_delete", (res) {
                                  debugPrint(res.toString());

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  SessionData().logout(context);
                                }, (res) {
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  Fluttertoast.showToast(
                                      msg: 'Impossibile eliminare account!',
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
                            child: getItem(
                                "assets/images/delete.svg", "Elimina Account")),
                        InkWell(
                            onTap: () {
                              SessionData().logout(context);
                            },
                            child: getItem("assets/images/logout.svg", "Esci")),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(),
                        SizedBox(
                          height: 16,
                        ),
                        if (_packageInfo != null)
                          Text(
                            "Versione " +
                                _packageInfo!.version +
                                " (" +
                                _packageInfo!.buildNumber +
                                ")",
                            style: TextStyle(
                                color: Constants.LIGHT_GREY_COLOR,
                                fontSize: 16,
                                fontFamily: Constants.FONT),
                          ),
                        SizedBox(
                          height: 16,
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
