class Brand {
  final int id;
  final String name;

  Brand(this.id, this.name);

  factory Brand.fromJson(Map<String, dynamic> json) {
    Brand brand = Brand(json["id"], json["name"]);
    return brand;
  }
}