class ProductColor {
  final int id;
  final String color;
  final String hexadecimal;

  ProductColor(this.id, this.color, this.hexadecimal);

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    ProductColor prod = ProductColor(json["id"], json["color"], json["hexadecimal"]);

    return prod;
  }
}