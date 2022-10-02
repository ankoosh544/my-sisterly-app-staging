import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FullscreenGalleryScreen extends StatefulWidget {

  final List<String> images;

  const FullscreenGalleryScreen({Key? key, required this.images}) : super(key: key);

  @override
  FullscreenGalleryScreenState createState() => FullscreenGalleryScreenState();
}

class FullscreenGalleryScreenState extends State<FullscreenGalleryScreen>  {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: CarouselSlider.builder(
                itemCount: widget.images.length,
                itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                    PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: Color(0xfff5f5f5)
                      ),
                      imageProvider: CachedNetworkImageProvider((widget.images[itemIndex].isNotEmpty ? widget.images[itemIndex] : "")),
                    ),
                options: CarouselOptions(

                    initialPage: 0
                ),
              ))
            ],
          ),
          Positioned(
            right: 16,
            top: 16,
            child: InkWell(
                onTap: () {
                  debugPrint("pop");
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: SvgPicture.asset("assets/images/close.svg", width: 18, height: 18, color: Colors.white,)
            ),
          ),
        ],
      ),
    );
  }
}
