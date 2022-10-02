class CreditCard {
  final String id;
  final String? alias;
  final String bankCode;
  final String? cardProvider;
  final String country;
  final String expirationDate;
  bool active;

  CreditCard(this.id, this.alias, this.bankCode, this.cardProvider, this.country, this.expirationDate, this.active);

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(json["id"], json["alias"], json["bank_code"], json["card_provider"], json["country"], json["expiration_date"], json["active"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "alias": alias,
      "bankCode": bankCode,
      "cardProvider": cardProvider,
      "country": country,
      "expirationDate": expirationDate,
      "active": active
    };
  }
}