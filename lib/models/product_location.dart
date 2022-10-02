class ProductLocation {
  final String city;
  final String zip;
  final String country;

  ProductLocation(this.city, this.zip, this.country);

  factory ProductLocation.fromJson(Map<String, dynamic> json) {
    ProductLocation prod = ProductLocation(json["city"], json["zip"], json["country"]);

    return prod;
  }

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "zip": zip,
      "country": country
    };
  }
}