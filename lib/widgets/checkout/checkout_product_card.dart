import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/utils/utils.dart';

class CheckoutProductCard extends StatelessWidget {

  final Product product;

  const CheckoutProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(15)
            ),
            child: CachedNetworkImage(
              height: 76,
              width: 100,
              imageUrl: (product.images.isNotEmpty ? product.images.first.image : ""),
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => SvgPicture.asset("assets/images/placeholder_product.svg"),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.model.toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontSize: 16,
                    ),
                  ),
                ]
              ),
            ),
          )
        ]
      )
    );
  }
}
