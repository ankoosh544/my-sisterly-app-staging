import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/chat.dart';
import 'package:sisterly/models/app_notifications.dart';
import 'package:sisterly/screens/search_user_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

import '../widgets/alert/custom_alert.dart';
import 'chat_screen.dart';

enum InboxScreenMode {
  messages, notifications
}

class InboxScreen extends StatefulWidget {

  const InboxScreen({Key? key}) : super(key: key);

  @override
  InboxScreenState createState() => InboxScreenState();
}

class InboxScreenState extends State<InboxScreen>  {

  bool _isLoading = false;
  List<Chat> _conversations = [];
  List<AppNotification> _notifications = [];
  InboxScreenMode _mode = InboxScreenMode.messages;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getConversations();
      getNotifications();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getConversations() {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeGetRequest('/chat/', {}, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _conversations = [];

      var data = res["data"];
      if (data != null) {
        for (var chat in data) {
          _conversations.add(Chat.fromJson(chat));
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  getNotifications() {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeGetRequest('/client/all_notifications', {}, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _notifications = [];

      var data = res["data"];
      if (data != null) {
        for (var chat in data) {
          _notifications.add(AppNotification.fromJson(chat));
        }
      }
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return "Adesso";
    }

    String roughTimeString = DateFormat('jm').format(dateTime);

    if (localDateTime.day == now.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));

    if (localDateTime.day == yesterday.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return "Ieri";
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);

      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
  }

  Widget conversationCell(Chat chat) {
    return InkWell(
      onTap: () async {
        String initialMessage = 'Come stai, ' + chat.user.firstName! + '?';
        await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChatScreen(chat: chat, code: chat.code, initialMessage: initialMessage)));
        getConversations();
      },
      child: Stack(
        children: [
          Container(
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
                          imageUrl: (chat.user.image ?? ""),
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
                                    getUsername(chat.user),
                                    style: TextStyle(
                                        color: Constants.DARK_TEXT_COLOR,
                                        fontSize: 16,
                                        fontFamily: Constants.FONT,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                if(chat.lastMessage != null) Text(
                                  getVerboseDateTimeRepresentation(chat.lastMessage!.sendAt!.toLocal()),
                                  style: TextStyle(
                                      color: Constants.LIGHT_GREY_COLOR,
                                      fontSize: 14,
                                      fontFamily: Constants.FONT
                                  ),
                                ),
                              ],
                            ),
                            if(chat.lastMessage != null) SizedBox(height: 6),
                            if(chat.lastMessage != null) Text(
                              chat.lastMessage!.message.toString(),
                              style: TextStyle(
                                  color: Constants.DARK_TEXT_COLOR,
                                  fontSize: 16,
                                  fontFamily: Constants.FONT
                              ),
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
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
                onTap: () {
                  CustomAlert.show(context,
                      //title: AppLocalizations.of(context).translate("generic_success"),
                      confirmButtonColor: Constants.SECONDARY_COLOR,
                      subtitle: "Vuoi procedere con l'eliminazione?",
                      showCancelButton: true,
                      cancelButtonText: "Annulla",
                      cancelButtonColor: Colors.white,
                      //style: CustomAlertStyle.success,
                      onPress: (bool isConfirm) {
                        Navigator.of(context, rootNavigator: true).pop();

                        if(isConfirm) {
                          ApiManager(context).makeDeleteRequest('/chat/' + chat.code + "/", (res) {
                            getConversations();
                          }, (res) {
                            getConversations();
                          });
                        }

                        return false;
                      });
                  //ApiManager.showFreeSuccessMessage(context, "");
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Constants.SECONDARY_COLOR,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Icon(Icons.clear, color: Colors.white, size: 22,)
                )
            ),
          )
        ],
      ),
    );
  }

  Widget notificationCell(AppNotification notification) {
    return InkWell(
      onTap: () async {
        /*await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ChatScreen(chat: chat, code: chat.code)));
        getConversations();*/
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
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black38,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset("assets/images/sisterly_logo.svg", width: 30,),
                    )
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
                                notification.title,
                                style: TextStyle(
                                    color: Constants.DARK_TEXT_COLOR,
                                    fontSize: 16,
                                    fontFamily: Constants.FONT,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            if(notification.sendAt != null) Text(
                              getVerboseDateTimeRepresentation(notification.sendAt!),
                              style: TextStyle(
                                  color: Constants.LIGHT_GREY_COLOR,
                                  fontSize: 14,
                                  fontFamily: Constants.FONT
                              ),
                            ),
                          ],
                        ),
                        if(notification.message != null) SizedBox(height: 6),
                        if(notification.message != null) Text(
                          notification.message.toString(),
                          style: TextStyle(
                              color: Constants.DARK_TEXT_COLOR,
                              fontSize: 16,
                              fontFamily: Constants.FONT
                          ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: _mode == InboxScreenMode.messages ? FloatingActionButton(
        backgroundColor: Constants.SECONDARY_COLOR,
        child: SvgPicture.asset("assets/images/chat_white.svg", width: 25,),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SearchUserScreen()));
          getConversations();
        },
      ) : null,
      body: Column(
        children: [
          HeaderWidget(title: "Sisterly Chats"),
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
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 10,
                              blurRadius: 30,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: _mode == InboxScreenMode.messages ? Constants.PRIMARY_COLOR : Colors.white,
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                              ),
                              child: Text('Messaggi', style: TextStyle(color: _mode == InboxScreenMode.messages ? Colors.white : Constants.TEXT_COLOR),),
                              onPressed: () {
                                getConversations();
                                setState(() {
                                  _mode = InboxScreenMode.messages;
                                });
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: _mode == InboxScreenMode.notifications ? Constants.PRIMARY_COLOR : Colors.white,
                                  elevation: 0,
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
                              ),
                              child: Text('Notifiche', style: TextStyle(color: _mode == InboxScreenMode.notifications ? Colors.white : Constants.TEXT_COLOR),),
                              onPressed: () {
                                getNotifications();
                                setState(() {
                                  _mode = InboxScreenMode.notifications;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                      Expanded(
                        child: _isLoading ? Center(child: CircularProgressIndicator()) : _conversations.isNotEmpty ? MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: _mode == InboxScreenMode.notifications ? ListView.builder(
                              itemCount: _notifications.length,
                              itemBuilder: (BuildContext context, int index) {
                                return notificationCell(_notifications[index]);
                              }
                          ) : ListView.builder(
                              itemCount: _conversations.length,
                              itemBuilder: (BuildContext context, int index) {
                                return conversationCell(_conversations[index]);
                              }
                          ),
                        ) : Text("Non ci sono chat al momento"),
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
