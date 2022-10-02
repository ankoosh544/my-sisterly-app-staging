import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/review.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';

import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

class ReviewsScreen extends StatefulWidget {

  final int userId;

  const ReviewsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ReviewsScreenState createState() => ReviewsScreenState();
}

class ReviewsScreenState extends State<ReviewsScreen>  {

  bool _isLoading = false;
  List<Review> _reviews = [];
  Account? _profile;
  bool _viewAll = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getUser();
      getReviews();
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
    ApiManager(context).makeGetRequest('/client/' + widget.userId.toString(), {}, (res) {
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

  getReviews() {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeGetRequest('/client/reviews/' + widget.userId.toString(), {}, (res) {
      var data = res["data"];
      if (data != null) {
        for (var prod in data["reviews"]) {
          _reviews.add(Review(Account.fromJson(prod["user"]),double.parse(prod["stars"]).toInt(), prod["description"]));
        }

      }
      setState(() {
        _isLoading = false;
      });

    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  String getUsername() {
    if(_profile == null) return "";
    return _profile!.username!.capitalize();
  }

  Widget reviewCell(Review review) {
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: CachedNetworkImage(
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    imageUrl: review.user.image ?? "",
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder.svg",),
                  ),
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user.username.toString(),
                        style: TextStyle(
                            color: Constants.DARK_TEXT_COLOR,
                            fontSize: 16,
                            fontFamily: Constants.FONT
                        ),
                      ),
                      SizedBox(height: 6,),
                      Wrap(
                        spacing: 3,
                        children: [
                          StarsWidget(stars: review.stars),
                          Text(
                            review.stars.toString(),
                            style: TextStyle(
                                color: Constants.DARK_TEXT_COLOR,
                                fontSize: 14,
                                fontFamily: Constants.FONT
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                /*SizedBox(width: 12,),
                Text(
                  "1 day ago",
                  style: TextStyle(
                      color: Constants.LIGHT_GREY_COLOR,
                      fontSize: 14,
                      fontFamily: Constants.FONT
                  ),
                ),*/
              ],
            ),
            SizedBox(height: 12,),
            Text(
              review.description,
              style: TextStyle(
                  color: Constants.TEXT_COLOR,
                  fontSize: 14,
                  fontFamily: Constants.FONT
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Recensioni"),
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
                        _isLoading || _profile == null ? CircularProgressIndicator() : Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(68.0),
                              child: CachedNetworkImage(
                                width: 68, height: 68, fit: BoxFit.cover,
                                imageUrl: (_profile!.image ?? ""),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder.svg"),
                              ),
                            ),
                            SizedBox(width: 12,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getUsername(),
                                  style: TextStyle(
                                      color: Constants.DARK_TEXT_COLOR,
                                      fontSize: 20,
                                      fontFamily: Constants.FONT
                                  ),
                                ),
                                /*SizedBox(height: 6,),
                                Text(
                                  "Milano",
                                  style: TextStyle(
                                      color: Constants.LIGHT_TEXT_COLOR,
                                      fontSize: 15,
                                      fontFamily: Constants.FONT
                                  ),
                                ),*/
                                SizedBox(height: 6,),
                                Wrap(
                                  spacing: 3,
                                  children: [
                                    if(_profile != null) StarsWidget(stars: _profile!.reviewsMedia!.toInt()),
                                    Text(
                                      _profile!.reviewsMedia!.toString(),
                                      style: TextStyle(
                                          color: Constants.DARK_TEXT_COLOR,
                                          fontSize: 14,
                                          fontFamily: Constants.FONT
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        /*SizedBox(height: 24,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/italy.svg", width: 22, height: 22,),
                                SizedBox(width: 8,),
                                Text(
                                  "Italian since 1996",
                                  style: TextStyle(
                                      color: Constants.LIGHT_TEXT_COLOR,
                                      fontSize: 14,
                                      fontFamily: Constants.FONT
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/italy.svg", width: 22, height: 22,),
                                SizedBox(width: 8,),
                                Text(
                                  "Italian since 1996",
                                  style: TextStyle(
                                      color: Constants.LIGHT_TEXT_COLOR,
                                      fontSize: 14,
                                      fontFamily: Constants.FONT
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/italy.svg", width: 22, height: 22,),
                                SizedBox(width: 8,),
                                Text(
                                  "SDA Bocconi School of Management",
                                  style: TextStyle(
                                      color: Constants.LIGHT_TEXT_COLOR,
                                      fontSize: 14,
                                      fontFamily: Constants.FONT
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),*/
                        SizedBox(height: 40,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recensioni",
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Constants.FONT
                              ),
                            ),
                            if(_reviews.isNotEmpty) InkWell(
                              child: Text(
                                _viewAll ? "Vedi meno" : "Vedi tutte",
                                style: TextStyle(
                                    color: Constants.SECONDARY_COLOR,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.FONT,
                                    decoration: TextDecoration.underline
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _viewAll = !_viewAll;
                                });
                              },
                            ),
                          ],
                        ),
                        _isLoading ? Center(child: CircularProgressIndicator()) : _reviews.isNotEmpty ? MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                              itemCount: _viewAll ? _reviews.length : (_reviews.length > 4 ? 4 : _reviews.length),
                            itemBuilder: (BuildContext context, int index) {
                              return reviewCell(_reviews[index]);
                            }
                          ),
                        ) : Text("Non ci sono recensioni al momento"),
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
