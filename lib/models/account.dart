import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Account {
  
  final int? id;
  final String email;
  final String? description;
  final String? firstName;
  final String? lastName;
  final String? phone;
  String? username;
  final String? image;
  final bool? emailConfirmed;
  final double? reviewsMedia;
  final bool? holidayMode;
  final String? identityCode;
  final String? residencyCity;
  DateTime? birthday;

  Account(this.id, this.email, this.description, this.firstName, this.lastName, this.phone, this.username, this.image, this.emailConfirmed, this.reviewsMedia, this.holidayMode, this.identityCode, this.residencyCity, this.birthday);

  factory Account.fromJson(Map<String, dynamic> json) {
    //debugPrint("Account.fromJson " + json.toString());
    return Account(
      json["id"], 
      json["email"], 
      json["description"], 
      json["first_name"], 
      json["last_name"], 
      json["phone"], 
      json["username"], 
      json["image"], 
      json["email_confirmed"], 
      json["reviews_media"] is String ? double.parse(json["reviews_media"]) : (json["reviews_media"] as int).toDouble(), 
      json["holiday_mode"], 
      json["identity_code"], 
      json["residency_city"],
        json["birthday"] != null ? DateFormat("yyyy-MM-dd").parse(json["birthday"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "description": description,
      "first_name": firstName,
      "last_name": lastName,
      "username": username,
      "image": image,
      "phone": phone,
      "email_confirmed": emailConfirmed,
      "reviews_media": reviewsMedia,
      "holiday_mode": holidayMode,
      "identity_code": identityCode,
      "residency_city": residencyCity,
      "birthday": birthday
    };
  }
}