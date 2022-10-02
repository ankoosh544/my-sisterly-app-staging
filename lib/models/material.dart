class MyMaterial {
  final int id;
  final String material;

  MyMaterial(this.id, this.material);

  factory MyMaterial.fromJson(Map<String, dynamic> json) {
    MyMaterial mat = MyMaterial(json["id"], json["material"]);
    return mat;
  }
}