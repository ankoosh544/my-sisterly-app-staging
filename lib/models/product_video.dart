class ProductVideo {
  final int id;
  final String video;
  final int order;

  ProductVideo(this.id, this.video, this.order);

  factory ProductVideo.fromJson(Map<String, dynamic> json) {
    ProductVideo prod = ProductVideo(json["id"], json["video"], json["order"]);

    return prod;
  }
}