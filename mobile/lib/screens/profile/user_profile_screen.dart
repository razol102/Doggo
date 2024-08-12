import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:mobile/screens/all_about_us/dog_data_screen.dart';
import 'package:mobile/screens/all_about_us/personal_data_screen.dart';
import 'package:mobile/screens/devices/doggo_collar_screen.dart';
import 'package:mobile/screens/welcome_screen.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/profile/widgets/setting_row.dart';
import 'package:mobile/common_widgets/title_subtitle_cell.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/round_button.dart';
import '../../services/preferences_service.dart';

class UserProfileScreen extends StatefulWidget {
  static String routeName = "/UserProfileScreen";
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool NotificationsToggle = false;
  String? _dogName;
  String? _dogBreed;
  String? _dogWeight;
  String? _dogAge;

  List devicesArr = [
    {"image": "assets/icons/doggo_collar_icon.png", "name": "Doggo Collar", "tag": "1"},
  ];

  List dogCareArr = [
    {"image": "assets/icons/nutrition_icon.png", "name": "Food & Nutrition", "tag": "2"},
    {"image": "assets/icons/vaccination_icon.png", "name": "Medical Records", "tag": "3"},
    {"image": "assets/icons/emergency_icon.png", "name": "Emergency Contacts", "tag": "4"},
  ];

  List AllAboutUsArr = [
    {"image": "assets/icons/personal_data_icon.png", "name": "Personal Data", "tag": "5"},
    {"image": "assets/icons/dog_data_icon.png", "name": "Dog Data", "tag": "6"},
    {"image": "assets/icons/safe_zone_icon.png", "name": "Safe Zone", "tag": "7"},
  ];

  List otherArr = [
    {"image": "assets/icons/contact_us_icon.png", "name": "Contact Us", "tag": "8"},
    {"image": "assets/icons/setting_icon.png", "name": "Settings", "tag": "9"},
  ];

  Future<void> _logout() async {
    try {
      // Await the result of getUserId to ensure it's fully retrieved before using it
      final int? userId = await PreferencesService.getUserId();

      if (userId != null) {
        final response = await HttpService.logout(userId);
        await PreferencesService.clearUserId();
        Navigator.pushNamed(context, WelcomeScreen.routeName);
      } else {
        // Handle the case where userId is null (if needed)
        print("User ID is null");
      }

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleSettingTap(String tag) {
    print("tap: $tag");
    print("tap: $tag");
    switch (tag) {
      case '1':
      // Navigate to Doggo Collar settings
        Navigator.pushNamed(context, DoggoCollarScreen.routeName);
        break;
      case '2':
      // Navigate to Food & Nutrition settings or related screen
        Navigator.pushNamed(context, '/food_nutrition');
        break;
      case '3':
      // Navigate to Medical Records settings or related screen
        Navigator.pushNamed(context, '/medical_records');
        break;
      case '4':
      // Navigate to Emergency Contacts settings or related screen
        Navigator.pushNamed(context, '/emergency_contacts');
        break;
      case '5':
      // Navigate to Personal Data settings or related screen
        Navigator.pushNamed(context, PersonalDataScreen.routeName);
        break;
      case '6':
      // Navigate to Dog Data settings or related screen
        Navigator.pushNamed(context, DogDataScreen.routeName);
        break;
      case '7':
      // Navigate to Safe Zone settings or related screen
        Navigator.pushNamed(context, '/safe_zone');
        break;
      case '8':
      // Navigate to Contact Us screen
        Navigator.pushNamed(context, '/contact_us');
        break;
      case '9':
      // Navigate to Settings screen
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        print('No action defined for tag: $tag');
    }
  }

  void _fetchDogInfo() async {
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final dogInfo = await HttpService.getDogInfo(dogId);
      final dogName = dogInfo['name'];
      final dogBreed = dogInfo['breed'];
      final dogWeight = dogInfo['weight'].toString();
      final dogDateOfBirth = dogInfo['date_of_birth'];
      final dogAge = _calculateDogAge(dogDateOfBirth);
      setState(() {
        _dogName = dogName;
        _dogBreed = dogBreed;
        _dogWeight = dogWeight;
        _dogAge = dogAge;
      });
    }
  }

  String? _calculateDogAge(String? dateOfBirth) {
    if(dateOfBirth != null) {
      final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
      final DateTime dogDateOfBirth = formatter.parse(dateOfBirth);
      final DateTime today = DateTime.now();
      int ageInYears = today.year - dogDateOfBirth.year;

      // Adjust for cases where the birthday hasn't occurred yet this year
      if (today.month < dogDateOfBirth.month ||
          (today.month == dogDateOfBirth.month && today.day < dogDateOfBirth.day)) {
        ageInYears--;
      }

      return ageInYears.toString();
    }
    return null;
  }
  
  @override
  void initState() {
    super.initState();
    _fetchDogInfo();
  }

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
            onTap: () {
              _logout();
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_outlined, color: Colors.redAccent,),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dogName ?? 'Dog Name',
                          style: const TextStyle(
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
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: _dogBreed ?? '-',
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
                      title: _dogWeight != null ? "${_dogWeight}kg": '-',
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
                      title: _dogAge != null ? "${_dogAge}yo" : '-',
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
                          onPressed: () => _handleSettingTap(iObj["tag"].toString()),
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
                          onPressed: () => _handleSettingTap(iObj["tag"].toString()),
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
                          onPressed: () => _handleSettingTap(iObj["tag"].toString()),
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
                            current: NotificationsToggle,
                            values: const [false, true],
                            indicatorSize: const Size.square(30.0),
                            animationDuration: const Duration(milliseconds: 200),
                            animationCurve: Curves.linear,
                            onChanged: (b) => setState(() => NotificationsToggle = b),
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
                          onPressed: () => _handleSettingTap(iObj["tag"].toString()),
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
