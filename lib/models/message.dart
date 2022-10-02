
class Message {

  final String? chatCode;
  final String? message;
  final bool? sendByUser;
  final DateTime? sendAt;

  Message(
      this.chatCode,
      this.message,
      this.sendByUser,
      this.sendAt);

  factory Message.fromJson(Map<String, dynamic> json) {
    Message message = Message(
        json["chat_code"],
        json["message"],
        json["send_by_user"],
        json["send_at"] != null ? DateTime.parse(json["send_at"] + "Z") : null,
    );

    return message;
  }
}
