class Category {
  final int id;
  final String category;

  Category(this.id, this.category);

  factory Category.fromJson(Map<String, dynamic> json) {
    Category brand = Category(json["id"], json["category"]);
    return brand;
  }
}