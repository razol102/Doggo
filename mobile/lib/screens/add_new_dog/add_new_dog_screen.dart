import 'package:flutter/material.dart';
import 'package:mobile/screens/add_new_dog/add_safe_zone.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';
import 'package:mobile/common_widgets/date_selector.dart';

class AddNewDogScreen extends StatefulWidget {
  static String routeName = "/AddNewDogScreen";

  const AddNewDogScreen({super.key});

  @override
  _AddNewDogScreenState createState() => _AddNewDogScreenState();
}

class _AddNewDogScreenState extends State<AddNewDogScreen> {
  final List<String> dogBreeds = [
    "Labrador Retriever",
    "German Shepherd",
    "Golden Retriever",
    "Bulldog",
    "Beagle",
    "Poodle",
    "Rottweiler",
    "Yorkshire Terrier",
    "Dachshund",
    "Boxer",
    "Shih Tzu",
    "Doberman Pinscher",
    "Siberian Husky",
    "Great Dane",
    "Chihuahua",
    "Collie",
    "Border Collie",
    "Husky"
  ];

  String? selectedBreed;
  String? selectedGender;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/add_your_dog.png", width: media.width),
                const SizedBox(height: 15),
                const Text(
                  "Let’s add your dog",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: "Name",
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Image.asset(
                          "assets/icons/breed_icon.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedBreed,
                            items: dogBreeds
                                .map((breed) => DropdownMenuItem(
                                value: breed,
                                child: Text(
                                  breed,
                                  style: const TextStyle(
                                      color: AppColors.grayColor,
                                      fontSize: 14),
                                )))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBreed = value;
                              });
                            },
                            isExpanded: true,
                            hint: Text(
                              selectedBreed ?? "Choose Breed",
                              style: const TextStyle(
                                  color: AppColors.grayColor, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Image.asset(
                          "assets/icons/gender_icon.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGender,
                            items: ["Male", "Female"]
                                .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: const TextStyle(
                                      color: AppColors.grayColor,
                                      fontSize: 14),
                                )))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            isExpanded: true,
                            hint: Text(
                              selectedGender ?? "Choose Gender",
                              style: const TextStyle(
                                  color: AppColors.grayColor, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                DateSelector(birthdateController: _birthdateController),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _weightController,
                  hintText: "Weight (kg)",
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _heightController,
                  hintText: "Height (cm)",
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: "Next >",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSafeZoneScreen(
                          name: _nameController.text,
                          breed: selectedBreed,
                          gender: selectedGender,
                          birthdate: _birthdateController.text,
                          weight: _weightController.text,
                          height: _heightController.text,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
