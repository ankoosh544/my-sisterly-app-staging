class ProductAvailability {
  final int month;
  final int year;
  final List<int> validDays;

  ProductAvailability(
    this.month,
    this.year,
    this.validDays,
  );

  factory ProductAvailability.fromJson(Map<String, dynamic> json) {
    ProductAvailability prod = ProductAvailability(
        json["month"], json["year"], json["valid_days"].cast<int>());
    return prod;
  }
}
