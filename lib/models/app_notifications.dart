class AppNotification {

  final String title;
  final String message;
  final DateTime? sendAt;

  AppNotification(
      this.title,
      this.message,
      this.sendAt);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    AppNotification notification = AppNotification(
        json["title"],
        json["message"],
        json["send_at"] != null ? DateTime.parse(json["send_at"]) : null,
    );

    return notification;
  }
}
