import 'package:flutter/cupertino.dart';
import 'package:sisterly/screens/account_screen.dart';
import 'package:sisterly/screens/home_screen.dart';
import 'package:sisterly/screens/inbox_screen.dart';
import 'package:sisterly/screens/search_screen.dart';
import 'package:sisterly/screens/upload_screen.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/constants.dart';

class TabScreen extends StatefulWidget {

  final int startingTab;

  const TabScreen({Key? key, this.startingTab = 0}) : super(key: key);

  @override
  TabScreenState createState() => TabScreenState();
}

class TabScreenState extends State<TabScreen>  {

  static final GlobalKey<NavigatorState> uploadNavKey = GlobalKey<NavigatorState>(debugLabel: 'UploadNavigation');

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    selectedTab = widget.startingTab;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getTabItem(String icon, String iconActive, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
        debugPrint("index "+index.toString()+"  selectedTab: "+selectedTab.toString());
      },
      child: Container(
        //color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: SvgPicture.asset(selectedTab == index ? iconActive : icon, height: 20,),
      ),
    );
  }

  Widget getChild() {
    switch(selectedTab) {
      case 0: return HomeScreen();
      case 1: return SearchScreen();
      case 2: return InboxScreen();
      case 3: return AccountScreen();
      case 4: return Navigator(
        key: TabScreenState.uploadNavKey,
        initialRoute: "/",
        onGenerateRoute: (RouteSettings settings) {
          return CupertinoPageRoute(builder: (context) {
            return UploadScreen();
          });
        },
      );
    }

    return HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Constants.SECONDARY_COLOR,
          child: SvgPicture.asset("assets/images/plus.svg"),
          onPressed: () {
            setState(() {
              selectedTab = 4;
            });
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90.0),
            child: getChild(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                //color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, -10), // changes position of shadow
                  ),
                ],
              ),
              height: MediaQuery.of(context).padding.bottom > 0 ? 90 : 75,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 60,
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    bottom: 13,
                    left: 0,
                    right: 0,
                    child: SvgPicture.asset("assets/images/shape_shadow.svg", height: 90, fit: BoxFit.fill,),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getTabItem("assets/images/home.svg", "assets/images/home_active.svg", 0),
                          getTabItem("assets/images/search.svg", "assets/images/search_active.svg", 1),
                          SizedBox(width: 32,),
                          getTabItem("assets/images/mail.svg", "assets/images/mail_active.svg", 2),
                          getTabItem("assets/images/account.svg", "assets/images/account_active.svg", 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
