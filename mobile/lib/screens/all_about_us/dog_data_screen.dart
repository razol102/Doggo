import 'package:flutter/material.dart';
import 'package:mobile/services/http_service.dart'; // Update the import based on your project structure
import 'package:mobile/services/preferences_service.dart'; // Update the import based on your project structure
import 'package:intl/intl.dart';

import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart'; // For formatting date

class DogDataScreen extends StatefulWidget {
  static String routeName = "/DogDataScreen";

  const DogDataScreen({super.key});

  @override
  _DogDataScreenState createState() => _DogDataScreenState();
}

class _DogDataScreenState extends State<DogDataScreen> {
  String _dogName = 'Loading...';
  String _dogBreed = 'Loading...';
  String _dogGender = 'Loading...';
  String _dogDateOfBirth = 'Loading...';
  String _dogHeight = 'Loading...';
  String _dogWeight = 'Loading...';
  String _homeLatitude = 'Loading...';
  String _homeLongitude = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchDogData();
  }

  Future<void> _fetchDogData() async {
    try {
      int? dogId = await PreferencesService.getDogId();
      print('dogId : $dogId');
      if (dogId != null) {
        final dogInfo = await HttpService.getDogInfo(dogId);
        // final dateOfBirth = DateTime.parse(dogInfo['date_of_birth']).toLocal();
        setState(() {
          _dogName = dogInfo['name'];
          _dogBreed = dogInfo['breed'];
          _dogGender = dogInfo['gender'];
          // _dogDateOfBirth = DateFormat('yyyy-MM-dd').format(dateOfBirth);
          _dogHeight = '${dogInfo['height']} cm';
          _dogWeight = '${dogInfo['weight']} kg';
          _homeLatitude = dogInfo['home_latitude'].toString();
          _homeLongitude = dogInfo['home_longitude'].toString();
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _dogName = 'Error loading data';
        _dogBreed = 'Error loading data';
        _dogGender = 'Error loading data';
        _dogDateOfBirth = 'Error loading data';
        _dogHeight = 'Error loading data';
        _dogWeight = 'Error loading data';
        _homeLatitude = 'Error loading data';
        _homeLongitude = 'Error loading data';
      });
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/dog_profile.png", // Update the image as needed
                  width: media.width*0.5,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Dog Profile Info",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 25),
                RoundTextField(
                  hintText: _dogName.isEmpty ? "Loading..." : _dogName,
                  icon: "assets/icons/name_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _dogBreed.isEmpty ? "Loading..." : _dogBreed,
                  icon: "assets/icons/breed_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _dogGender.isEmpty ? "Loading..." : _dogGender,
                  icon: "assets/icons/gender_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _dogDateOfBirth.isEmpty ? "Loading..." : _dogDateOfBirth,
                  icon: "assets/icons/date_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _dogHeight.isEmpty ? "Loading..." : _dogHeight,
                  icon: "assets/icons/swap_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _dogWeight.isEmpty ? "Loading..." : _dogWeight,
                  icon: "assets/icons/weight_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _homeLatitude.isEmpty ? "Loading..." : _homeLatitude,
                  icon: "assets/icons/home_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _homeLongitude.isEmpty ? "Loading..." : _homeLongitude,
                  icon: "assets/icons/home_icon.png", // Update icon as needed
                  textInputType: TextInputType.text,
                  // readOnly: true, // Set to true to make it non-editable
                ),
                const SizedBox(height: 15),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
