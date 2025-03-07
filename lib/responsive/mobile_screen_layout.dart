import 'package:bookes/theme/colors.dart';
import 'package:bookes/utils.dart/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';





class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    // pageController = PageController();
      pageController = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

       body: PageView(
        children: homeScreenItems,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        // children: homeScreenItems,
      ),
      // MyWidget(),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
         activeColor: Colors.blue,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            // label: AppLocalizations.of(context)!.profile,
           backgroundColor: primaryColor,
          
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.sports_soccer,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              // label: AppLocalizations.of(context)!.results,
              backgroundColor: primaryColor),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              // label: AppLocalizations.of(context)!.table,
              backgroundColor: primaryColor),
                      BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            // label: AppLocalizations.of(context)!.preferences,
            backgroundColor: primaryColor,
          ),

          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.person,
          //     color: (_page == 4) ? primaryColor : secondaryColor,
          //   ),
          //   label: '',
          //   backgroundColor: primaryColor,
          // ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}