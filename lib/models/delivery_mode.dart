class DeliveryMode {
  final int id;
  final String description;

  DeliveryMode(this.id, this.description);

  factory DeliveryMode.fromJson(Map<String, dynamic> json) {
    DeliveryMode prod = DeliveryMode(json["id"], getDescription(json));

    return prod;
  }

  static getDescription(json) {
    if(json["description"] != null) {
      return json["description"];
    } else if(json["delivery_type"] != null) {
      return json["delivery_type"];
    } else {
      return "";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description
    };
  }
}