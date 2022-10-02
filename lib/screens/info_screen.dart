import 'package:cached_network_image/cached_network_image.dart';
import 'package:sisterly/models/account.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/review.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:sisterly/widgets/header_widget.dart';
import 'package:sisterly/widgets/stars_widget.dart';

import '../utils/constants.dart';
import "package:sisterly/utils/utils.dart";

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  InfoScreenState createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  bool _isLoading = false;
  Account? _profile;
  bool _viewAll = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getUsername() {
    if (_profile == null) return "";
    return _profile!.username!.capitalize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.PRIMARY_COLOR,
        body: Column(
          children: [
            HeaderWidget(title: "Information"),
          ],
        ));
  }
}
