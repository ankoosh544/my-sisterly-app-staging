class LenderKit {
  final int id;
  final String lenderKitToSend;

  LenderKit(this.id, this.lenderKitToSend);

  factory LenderKit.fromJson(Map<String, dynamic> json) {
    LenderKit prod = LenderKit(json["id"], json["lender_kit_to_send"]);

    return prod;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "lender_kit_to_send": lenderKitToSend
    };
  }
}