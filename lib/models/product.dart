import 'package:sisterly/models/category.dart';
import 'package:sisterly/models/delivery_mode.dart';
import 'package:sisterly/models/product_color.dart';
import 'package:sisterly/models/product_image.dart';
import 'package:sisterly/models/product_location.dart';
import 'package:sisterly/models/product_video.dart';
import 'package:sisterly/models/var.dart';

import 'account.dart';
import 'lender_kit.dart';

class Product {
  final int id;
  final String model;
  List<ProductImage> images = [];
  List<ProductVideo> videos = [];
  final Account owner;
  final int brandId;
  final String brandName;
  final int colorId;
  final String colorName;
  final String colorHex;
  List<ProductColor> colors = [];
  List<Category> categories = [];
  final int materialId;
  final String? description;
  final String materialName;
  final double priceRetail;
  final double priceOffer;
  final double sellingPrice;
  final String? conditions;
  final int? conditionsId;
  final String? size;
  final int? sizeId;
  final String? year;
  final int? yearId;
  final DeliveryMode? deliveryType;
  final int? mediaId;
  bool usePriceAlgorithm;
  bool useDiscount;
  final LenderKit? lenderKitToSend;
  final ProductLocation? location;
  final int status;
  final bool activeOrder;

  Product(
      this.id,
      this.model,
      this.owner,
      this.description,
      this.brandId,
      this.brandName,
      this.categories,
      this.colors,
      this.colorId,
      this.colorName,
      this.colorHex,
      this.materialId,
      this.materialName,
      this.priceRetail,
      this.priceOffer,
      this.sellingPrice,
      this.conditions,
      this.conditionsId,
      this.size,
      this.sizeId,
      this.year,
      this.yearId,
      this.deliveryType,
      this.usePriceAlgorithm,
      this.useDiscount,
      this.lenderKitToSend,
      this.mediaId,
      this.location,
      this.status,
      this.activeOrder);

  static getArrayDesc(item) {
    if (item.isNotEmpty && item.length > 1) {
      return item[1];
    }

    return "";
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    Product prod = Product(
      json["id"],
      json["model"],
      Account.fromJson(json["owner"]),
      json["description"],
      json["brand"]["id"],
      json["brand"]["name"],
      [],
      [],
      json["color"]["id"],
      json["color"]["color"],
      json["color"]["hexadecimal"],
      json["material"]["id"],
      json["material"]["material"],
      json["price_retail"],
      json["price_offer"],
      json["selling_price"],
      getGenericName(json["conditions"]["id"], productConditions),
      json["conditions"]["id"],
      getGenericName(json["size"]["id"], bagSizes),
      json["size"]["id"],
      getGenericName(json["year"]["id"], bagYears),
      json["year"]["id"],
      DeliveryMode.fromJson(json["delivery_type"]),
      json["use_price_algorithm"] ?? false,
      json["use_discount"] ?? false,
      LenderKit.fromJson(json["lender_kit_to_send"]),
      json["media"]["id"],
      ProductLocation.fromJson(json["location"]),
      json["status"]['id'] ?? 1,
      json["in_active_order"] ?? false,
    );

    var media = json["media"];

    for(var img in media["images"]) {
      prod.images.add(ProductImage.fromJson(img));
    }

    prod.images.sort((a, b) {
      return a.order - b.order;
    });

    for(var vid in media["videos"]) {
      prod.videos.add(ProductVideo.fromJson(vid));
    }

    if(json["colors"] != null) {
      for (var col in json["colors"]) {
        prod.colors.add(ProductColor.fromJson(col));
      }
    }

    if(json["categories"] != null) {
      for (var col in json["categories"]) {
        prod.categories.add(Category.fromJson(col));
      }
    }

    return prod;
  }
}
