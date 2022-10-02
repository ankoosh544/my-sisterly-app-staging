import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/state.dart';

import 'address.dart';
import 'delivery_mode_offer.dart';

class Offer {
  final int id;
  final Account user;
  final Product product;
  final State state;
  final double? price;
  final double? shipmentFee;
  final double? insurance;
  final double? total;
  final double? totalNet;
  final DateTime dateStart;
  final DateTime dateEnd;
  final DeliveryModeOffer deliveryMode;
  final Address? addressIdCarrier;

  Offer(
      this.id,
      this.user,
      this.product,
      this.state,
      this.price,
      this.total,
      this.totalNet,
      this.dateStart,
      this.dateEnd,
      this.deliveryMode,
      this.addressIdCarrier,
      this.insurance,
      this.shipmentFee);

  static getArrayDesc(item) {
    if (item.isNotEmpty && item.length > 1) {
      return item[1];
    }

    return "";
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    Offer prod = Offer(
        json["id"],
        Account.fromJson(json["user"]),
        Product.fromJson(json["product"]),
        State.fromJson(json["state"]),
        json["price"] != null ? double.parse(json["price"].toString()) : 0,
        json["total"] != null ? double.parse(json["total"].toString()) : 0,
        json["total_net"] != null ? double.parse(json["total_net"].toString()) : 0,
        DateTime.parse(json["date_start"]),
        DateTime.parse(json["date_end"]),
        DeliveryModeOffer.fromJson(json["delivery_mode"]),
        json["address_id_carrier"] != null
            ? Address.fromJsonOffer(json["address_id_carrier"])
            : null,
        json["insurance"] != null
            ? double.parse(json["insurance"].toString())
            : 0,
        json["shipment_fee"] != null
            ? double.parse(json["shipment_fee"].toString())
            : 0);

    return prod;
  }
}
