import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StarsWidget extends StatelessWidget {

  final int stars;

  const StarsWidget({
    Key? key,
    required this.stars
  }) : super(key: key);

  getStars() {
    List<Widget> widgs = [];

    for(var i = 0; i < (stars > 0 ? stars : 1); i++) {
      widgs.add(SvgPicture.asset("assets/images/star.svg", width: 11, height: 11,),);
    }
 
    return widgs;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: getStars(),
    );
  }
}
