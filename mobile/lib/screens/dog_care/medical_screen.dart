import 'package:flutter/material.dart';
import 'package:mobile/common_widgets/setting_row.dart';
import '../../utils/app_colors.dart';
import '../map/pension_vet_map_screen.dart';
import '../medical/medical_records_screen.dart';

class MedicalScreen extends StatefulWidget {
  static String routeName = "/MedicalScreen";

  const MedicalScreen({super.key});

  @override
  _MedicalScreenState createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {

  List medicalArr = [
    {"image": "assets/icons/medical_icon.png", "name": "Veterinarian Information", "tag": "1"},
    {"image": "assets/icons/medical_icon.png", "name": "Vaccinations", "tag": "2"},
    {"image": "assets/icons/medical_icon.png", "name": "Medical Records", "tag": "3"},
  ];

  @override
  void initState() {
    super.initState();
  }

  void _handleSettingTap(String tag) {
    switch (tag) {
      case '1':
      // Navigate to vet info screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PensionVetMapScreen(
              type: 'vet',
            ),
          ),
        );
        break;        break;
      case '2':
      // Navigate to vaccinations screen
      //   Navigator.pushNamed(context, VaccinationsScreen.routeName);
        break;
      case '3':
      // Navigate to Medical records screen
        Navigator.pushNamed(context, MedicalRecordsScreen.routeName);
        break;
      default:
        print('No action defined for tag: $tag');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                Image.asset("assets/images/medical_background.png", width: media.width * 0.5),
                const SizedBox(height: 15),
                const Text(
                  "Medical Info",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 25),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: medicalArr.length,
                  itemBuilder: (context, index) {
                    var iObj = medicalArr[index] as Map? ?? {};
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
        ),
      ),
    );
  }
}
