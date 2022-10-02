import 'package:sisterly/models/account.dart';

class Review {

  final Account user;
  final int stars;
  final String description;

  Review(this.user, this.stars, this.description);

 factory Review.fromJson(Map<String, dynamic> json) {
    Review prod = Review(Account.fromJson(json["user"]), json["stars"], json["description"]);

    return prod;
  }
}