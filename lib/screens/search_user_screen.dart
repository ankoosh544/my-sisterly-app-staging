import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/chat.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';

import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

import 'chat_screen.dart';

class SearchUserScreen extends StatefulWidget {

  const SearchUserScreen({Key? key}) : super(key: key);

  @override
  SearchUserScreenState createState() => SearchUserScreenState();
}

class SearchUserScreenState extends State<SearchUserScreen>  {

  bool _isLoading = false;
  List<Account> _users = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUsers() {
    setState(() {
      _isLoading = true;
    });

    var params = {

    };

    if(_searchController.text.isNotEmpty) {
      params["username"] = _searchController.text.toString();
    }

    ApiManager(context).makePostRequest('/client/search', params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _users = [];

      var data = res["data"];
      if (data != null) {
        for (var user in data) {
          _users.add(Account.fromJson(user));
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget userCell(Account user) {
    return InkWell(
      onTap: () async {
        var params = {
          "email_user_to": user.email
        };

        ApiManager(context).makePutRequest('/chat/', params, (res) {
          if (res["errors"] != null) {
            ApiManager.showFreeErrorMessage(context, res["errors"].toString());
          } else {
            ApiManager(context).makeGetRequest('/chat/' + res["data"]["code"]  + '/', {}, (chatRes) {
              String initialMessage = 'Come stai, ' + user.firstName! + '?';
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChatScreen(chat: Chat.fromJson(chatRes["data"]), code: res["data"]["code"], initialMessage: initialMessage)));
            }, (res) {

            });
          }
        }, (res) {
          if (res["errors"] != null) {
            ApiManager.showFreeErrorMessage(context, res["errors"].toString());
          }
        });
      },
      child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(52.0),
                    child: CachedNetworkImage(
                      width: 52, height: 52, fit: BoxFit.cover,
                      imageUrl: (user.image ?? ""),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder.svg"),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                getUsername(user),
                                style: TextStyle(
                                    color: Constants.DARK_TEXT_COLOR,
                                    fontSize: 16,
                                    fontFamily: Constants.FONT,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getUsername(Account profile) {
    return profile.username!.capitalize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          HeaderWidget(title: "Cerca utente"),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.text,
                                cursorColor: Constants.PRIMARY_COLOR,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Constants.FORM_TEXT,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Username...",
                                  hintStyle: const TextStyle(
                                      color: Constants.PLACEHOLDER_COLOR),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(60),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  filled: true,
                                  fillColor: Constants.LIGHT_GREY_COLOR2,

                                ),
                                onEditingComplete: () {
                                  getUsers();
                                },
                                onChanged: (str) {
                                  setState(() {

                                  });
                                },
                                controller: _searchController,
                              ),
                            ),
                            if(_searchController.text.isNotEmpty) SizedBox(width: 8,),
                            if(_searchController.text.isNotEmpty) CircleAvatar(
                              backgroundColor: Constants.SECONDARY_COLOR,
                              child: IconButton(
                                splashColor: Constants.SECONDARY_COLOR,
                                icon: Icon(Icons.search, color: Colors.white,),
                                onPressed:() {
                                  getUsers();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: _isLoading ? Center(child: CircularProgressIndicator()) : _users.isNotEmpty ? MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (BuildContext context, int index) {
                              return userCell(_users[index]);
                            }
                          ),
                        ) : Text(""),
                      ),
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
