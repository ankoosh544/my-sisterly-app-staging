import 'package:sisterly/models/message.dart';

import 'account.dart';

class Chat {

  final String code;
  final Account user;
  final Message? lastMessage;

  Chat(
      this.code,
      this.user,
      this.lastMessage);

  factory Chat.fromJson(Map<String, dynamic> json) {
    Chat chat = Chat(
        json["code"],
        Account.fromJson(json["user"]),
        json["last_message"] != null ? Message.fromJson(json["last_message"]) : null,
    );

    return chat;
  }
}
