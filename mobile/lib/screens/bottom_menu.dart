import 'dart:io';

import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'activity/activity_screen.dart';
import 'map/map_screen.dart';
import 'package:mobile/screens/social_network/social_network_screen.dart';
class BottomMenu extends StatefulWidget {
  static String routeName = "/BottomMenu";

  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int selectTab = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const UserProfileScreen(),
    ActivityScreen(),
    const MapScreen(),
     SocialNetworkScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {
          setState(() {
            selectTab = 0; // Home tab
          });
        },
        child: SizedBox(
          width: 60,
          height: 60,
          child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryG),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: selectTab == 0 ? AppColors.secondaryColor1 : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2)
                  ]),
              child: const Icon(Icons.home_rounded,
                  color: AppColors.whiteColor,
                  size: 38)
          ),
        ),
      ),
      body: IndexedStack(
        index: selectTab,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomAppBar(
        height: Platform.isIOS ? 70 : 65,
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        child: Container(
          height: Platform.isIOS ? 70 : 65,
          decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, -2))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  icon: "assets/icons/dog_profile_icon.png",
                  selectIcon: "assets/icons/dog_profile_select_icon.png",
                  isActive: selectTab == 1,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 1;
                      });
                    }
                  }),
              TabButton(
                  icon: "assets/icons/goals_icon.png",
                  selectIcon: "assets/icons/goals_select_icon.png",
                  isActive: selectTab == 2,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 2;
                      });
                    }
                  }),
              const SizedBox(width: 30),
              TabButton(
                  icon: "assets/icons/map_icon.png",
                  selectIcon: "assets/icons/map_select_icon.png",
                  isActive: selectTab == 3,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 3;
                      });
                    }
                  }),
              TabButton(
                  icon: "assets/icons/social_media_icon.png",
                  selectIcon: "assets/icons/social_media_select_icon.png",
                  isActive: selectTab == 4,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 4;
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String icon;
  final String selectIcon;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton(
      {Key? key,
        required this.icon,
        required this.selectIcon,
        required this.isActive,
        required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive ? selectIcon : icon,
            width: 25,
            height: 25,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: isActive ? 8 : 12),
          Visibility(
            visible: isActive,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.secondaryG),
                  borderRadius: BorderRadius.circular(2)),
            ),
          )
        ],
      ),
    );
  }
}
