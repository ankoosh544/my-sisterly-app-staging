import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/chat.dart';
import 'package:sisterly/models/message.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/screens/profile_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

class ChatScreen extends StatefulWidget {

  final String code;
  final Chat chat;
  final String? initialMessage;

  const ChatScreen({Key? key, required this.code, required this.chat, this.initialMessage}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>  {

  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  List<Message> _messages = [];
  String? socketCode;
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getSocketCode();
      getMessages();
    });
  }

  @override
  void dispose() {
    channel!.sink.close();

    super.dispose();
  }

  getSocketCode() {
    setState(() {
      _isLoading = true;
    });

    var params = {
      "data": {
        "code": widget.code
      }
    };

    ApiManager(context).makePostRequest('/chat/code', params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      socketCode = res["data"].toString();

      connectSocket();
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  connectSocket() {
    String socketUrl = "ws://" + Constants.SERVER_URL.replaceAll("http://", "").replaceAll("https://", "") + "/ws/chat/" + socketCode.toString() + "/";

    //socketUrl = "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self";
    debugPrint("connecting to "+socketUrl.toString());

    try {
      channel = IOWebSocketChannel.connect(
          Uri.parse(socketUrl),
        headers: {'Authorization': "Bearer " + SessionData().token.toString() }
      );

      channel!.stream.listen((data) {
          Message msg = Message.fromJson(jsonDecode(data));
          //_messages.add(msg);

          if(msg.message != null) {
            _messages.insert(0, msg);
            debugPrint("messages " + _messages.length.toString());

            setState(() {

            });
          }
          print(data);

        },
        onError: (error) => print(error),
      );
    } catch(e) {
      debugPrint("socket exception");
      channel!.stream.listen((event) => handleMessage(event), cancelOnError: true, onDone: onDone, onError: (e) {
        print('here: $e');
      });
    }
  }

  handleMessage(event) {
    debugPrint("handleMessage");
  }

  onDone() {
    debugPrint("onDone");
  }

  getMessages() {
    setState(() {
      _isLoading = true;
    });

    var params = {
      "count": 100000
    };

    ApiManager(context).makePostRequest('/chat/' + widget.code + '/messages', params, (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      _messages = [];

      var data = res["data"];
      if (data != null) {
        for (var chat in data) {
          _messages.add(Message.fromJson(chat));
        }
      }

      String initialMessage = '';

      if (_messages.isEmpty) {
        initialMessage = widget.initialMessage!;
      }

      _messageController.value = TextEditingValue(
        text: initialMessage,
        selection: TextSelection.fromPosition(
          TextPosition(offset: initialMessage.length),
        )
      );

      //_messages = _messages.reversed.toList();

      debugPrint("initial messages "+_messages.length.toString());
      setState(() {

      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget messageCell(Message message) {
    if(message.sendByUser != null && message.sendByUser! == true) {
      return Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Constants.SECONDARY_COLOR_LIGHT,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
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
              child: Text(
                message.message.toString(),
                style: TextStyle(
                    color: Constants.DARK_TEXT_COLOR,
                    fontSize: 20,
                    fontFamily: Constants.FONT
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Constants.LIGHT_GREY_COLOR2,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
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
              child: Text(
                message.message.toString(),
                style: TextStyle(
                    color: Constants.DARK_TEXT_COLOR,
                    fontSize: 20,
                    fontFamily: Constants.FONT
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  String getUsername(Account profile) {
    return profile.username!.capitalize();
  }

  sendMessage() {
    if(_messageController.text.trim().isEmpty) {
      return;
    }

    var params = {
      "chat_code": widget.code,
      "message": _messageController.text.toString()
    };

    _messageController.text = "";

    _messages.insert(0, Message.fromJson({
      "message": params["message"],
      "send_by_user": true
    }));

    setState(() {

    });

    debugPrint("sendMessage " +jsonEncode(params));

    channel!.sink.add(jsonEncode(params));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(id: widget.chat.user.id)));
            },
              child: HeaderWidget(title: widget.chat.user.username.toString(), subtitleLink: "Vedi profilo",)
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Expanded(
                      child: _isLoading ? Center(child: CircularProgressIndicator()) : _messages.isNotEmpty ? MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListView.builder(
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return messageCell(_messages[index]);
                            }
                          ),
                        ),
                      ) : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Non ci sono messaggi in questa chat"),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
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
                                  hintText: "Messaggio",
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
                                onEditingComplete: sendMessage,
                                onChanged: (str) {
                                  setState(() {

                                  });
                                },
                                controller: _messageController,
                              ),
                            ),
                            if(_messageController.text.isNotEmpty) SizedBox(width: 8,),
                            if(_messageController.text.isNotEmpty) CircleAvatar(
                              backgroundColor: Constants.SECONDARY_COLOR,
                              child: IconButton(
                                splashColor: Constants.SECONDARY_COLOR,
                                icon: Icon(Icons.send, color: Colors.white,),
                                onPressed:() {
                                  sendMessage();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
