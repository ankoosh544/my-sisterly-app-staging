class DeliveryModeOffer {
  final int id;
  final String delivery_mode;

  DeliveryModeOffer(this.id, this.delivery_mode);

  factory DeliveryModeOffer.fromJson(Map<String, dynamic> json) {
    DeliveryModeOffer prod = DeliveryModeOffer(json["id"], json["delivery_mode"]);

    return prod;
  }
}