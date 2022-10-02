class Filters {

  String? model;
  List<int> conditions = [];
  List<int> colors = [];
  List<int> deliveryModes = [];
  double maxPrice = 100;
  DateTime? availableFrom;
  DateTime? availableTo;
  bool onlySameCity = false;
  int? brand;
  int? category;

  areSet() {
    return model != null
        || conditions.isNotEmpty
        || colors.isNotEmpty
        || deliveryModes.isNotEmpty
        || maxPrice != 100
        || onlySameCity
        || brand != null
        || category != null
    ;
  }

}