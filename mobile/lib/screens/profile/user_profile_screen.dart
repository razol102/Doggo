import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/profile/widgets/setting_row.dart';
import 'package:mobile/common_widgets/title_subtitle_cell.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/round_button.dart';

class UserProfileScreen extends StatefulWidget {
  static String routeName = "/UserProfileScreen";
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool positive = false;

  List devicesArr = [
    {"image": "assets/icons/doggo_collar_icon.png", "name": "Doggo Collar", "tag": "1"},
    {"image": "assets/icons/home_station_icon.png", "name": "Doggo Home Station", "tag": "2"},
  ];

  List dogCareArr = [
    {"image": "assets/icons/nutrition_icon.png", "name": "Food & Nutrition", "tag": "3"},
    {"image": "assets/icons/vaccination_icon.png", "name": "Medical Records", "tag": "4"},
    {"image": "assets/icons/emergency_icon.png", "name": "Emergency Contacts", "tag": "5"},
  ];

  List AllAboutUsArr = [
    {"image": "assets/icons/personal_data_icon.png", "name": "Personal Data", "tag": "6"},
    {"image": "assets/icons/dog_data_icon.png", "name": "Dog Data", "tag": "7"},
    {"image": "assets/icons/safe_zone_icon.png", "name": "Safe Zone", "tag": "8"},
  ];

  List otherArr = [
    {"image": "assets/icons/contact_us_icon.png", "name": "Contact Us", "tag": "9"},
    {"image": "assets/icons/setting_icon.png", "name": "Settings", "tag": "10"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Dog Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/images/dog_profile.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tommy",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Old but gold!",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: RoundButton(
                        onPressed: () {
                          // TODO: Add editor logic
                        },
                        backgroundColor: AppColors.primaryColor2,
                        titleColor: AppColors.blackColor,
                        icon: Icons.edit,
                        iconSize: 18.0
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "mixed",
                      subtitle: "Breed",
                      boxHeight: 70,
                      boxWidth: 0,
                      titleFontSize: 14,
                      subtitleFontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "25kg",
                      subtitle: "Weight",
                      boxHeight: 70,
                      boxWidth: 0,
                      titleFontSize: 14,
                      subtitleFontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: "13yo",
                      subtitle: "Age",
                      boxHeight: 70,
                      boxWidth: 0,
                      titleFontSize: 14,
                      subtitleFontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Doggo Devices",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: devicesArr.length,
                      itemBuilder: (context, index) {
                        var iObj = devicesArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dog Care",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: dogCareArr.length,
                      itemBuilder: (context, index) {
                        var iObj = dogCareArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "All About Us",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: AllAboutUsArr.length,
                      itemBuilder: (context, index) {
                        var iObj = AllAboutUsArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notification",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/p_notification.png",
                              height: 15, width: 15, fit: BoxFit.contain),
                          const SizedBox(
                            width: 15,
                          ),
                          const Expanded(
                            child: Text(
                              "Pop-up Notification",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          CustomAnimatedToggleSwitch<bool>(
                            current: positive,
                            values: const [false, true],
                            indicatorSize: const Size.square(30.0),
                            animationDuration: const Duration(milliseconds: 200),
                            animationCurve: Curves.linear,
                            onChanged: (b) => setState(() => positive = b),
                            iconBuilder: (context, local, global) {
                              return const SizedBox();
                            },
                            iconsTappable: false,
                            wrapperBuilder: (context, global, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 10.0,
                                    right: 10.0,
                                    height: 30.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: AppColors.secondaryG),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30.0)),
                                      ),
                                    ),
                                  ),
                                  child,
                                ],
                              );
                            },
                            foregroundIndicatorBuilder: (context, global) {
                              return SizedBox.fromSize(
                                size: const Size(10, 10),
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black38,
                                          spreadRadius: 0.05,
                                          blurRadius: 1.1,
                                          offset: Offset(0.0, 0.8))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Other",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
