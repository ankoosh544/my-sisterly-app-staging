class ProductImage {
  final int id;
  final String image;
  final int order;

  ProductImage(this.id, this.image, this.order);

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    ProductImage prod = ProductImage(json["id"], json["image"], json["order"]);

    return prod;
  }
}