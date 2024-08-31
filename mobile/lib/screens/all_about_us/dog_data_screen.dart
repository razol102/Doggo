import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common_widgets/breed_selector.dart';
import 'package:mobile/common_widgets/date_selector.dart';
import 'package:mobile/common_widgets/gender_selector.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/services/validation_methods.dart';

import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class DogDataScreen extends StatefulWidget {
  static const String routeName = "/DogDataScreen";

  final bool editMode;

  const DogDataScreen({Key? key, this.editMode = false}) : super(key: key);

  @override
  _DogDataScreenState createState() => _DogDataScreenState();
}

class _DogDataScreenState extends State<DogDataScreen> {
  late bool _isEditing;
  String _dogName = 'Loading...';
  String _dogBreed = 'Loading...';
  String _dogGender = 'Loading...';
  DateTime? _dogDateOfBirth;
  String _dogHeight = 'Loading...';
  String _dogWeight = 'Loading...';

  String? _nameError;
  String? _breedError;
  String? _genderError;
  String? _dateOfBirthError;
  String? _heightError;
  String? _weightError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  String? _selectedBreed;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode; // Initialize _isEditing based on the editMode parameter
    _fetchDogData();
  }

  Future<void> _fetchDogData() async {
    try {
      final int? dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        final dogInfo = await HttpService.getDogInfo(dogId);

        setState(() {
          _dogName = dogInfo['name'];
          _dogBreed = dogInfo['breed'];
          _selectedBreed = _dogBreed;
          _dogGender = dogInfo['gender'];
          _selectedGender = _dogGender;
          _dogDateOfBirth = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
              .parse(dogInfo['date_of_birth'], true)
              .toLocal();
          _dogHeight = '${dogInfo['height']} cm';
          _dogWeight = '${dogInfo['weight']} kg';

          _nameController.text = _dogName;
          _breedController.text = _dogBreed;
          _genderController.text = _dogGender;
          _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_dogDateOfBirth!);
          _weightController.text = dogInfo['weight'].toString();
          _heightController.text = dogInfo['height'].toString();
        });
      }
    } catch (e) {
      print('Error fetching dog data: $e');
      setState(() {
        _dogName = 'Error loading data';
        _dogBreed = 'Error loading data';
        _dogGender = 'Error loading data';
        _dogDateOfBirth = null;
        _dogHeight = 'Error loading data';
        _dogWeight = 'Error loading data';
      });
    }
  }

  Future<void> _saveDogProfile() async {
    setState(() {
      _nameError = ValidationMethods.validateNotEmpty(_nameController.text, 'Name');
      _breedError = _validateBreed(_selectedBreed);
      _genderError = _validateGender(_selectedGender);
      _dateOfBirthError = ValidationMethods.validateNotEmpty(_dateOfBirthController.text, 'Date of birth');
      _heightError = ValidationMethods.validatePositiveInt(_heightController.text, 'Height');
      _weightError = ValidationMethods.validatePositiveDouble(_weightController.text, 'Weight');
    });

    if (_nameError != null || _breedError != null || _genderError != null ||
        _dateOfBirthError != null || _heightError != null || _weightError != null) {
      return;
    }

    try {
      final int? dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        await HttpService.updateDogProfile(
            dogId,
            _nameController.text,
            _selectedBreed!,
            _selectedGender!,
            DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text).toString(),
            double.parse(_weightController.text),
            int.parse(_heightController.text)
        );
        await _fetchDogData();
        setState(() {
          _isEditing = false;
          _nameError = null;
          _breedError = null;
          _genderError = null;
          _dateOfBirthError = null;
          _heightError = null;
          _weightError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dog profile updated successfully")),
        );
      }
    } catch (e) {
      print('Failed to update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update dog profile: ${e.toString()}")),
      );
    }
  }

  String? _validateBreed(String? value) {
    if (value == null || value.isEmpty) {
      return 'Breed cannot be empty';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveDogProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/dog_profile.png",
                  width: media.width * 0.5,
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
                const SizedBox(height: 25),
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: _dogName.isEmpty ? "Loading..." : _dogName,
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: !_isEditing,
                  errorText: _nameError,
                ),
                const SizedBox(height: 15),
                _isEditing
                    ? BreedSelector(
                  selectedBreed: _selectedBreed,
                  onBreedChanged: (breed) {
                    setState(() {
                      _selectedBreed = breed;
                    });
                  },
                )
                    : RoundTextField(
                  textEditingController: _breedController,
                  hintText: _dogBreed.isEmpty ? "Loading..." : _dogBreed,
                  icon: "assets/icons/breed_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
                  errorText: _breedError,
                ),
                const SizedBox(height: 15),
                _isEditing
                    ? GenderSelector(
                  selectedGender: _selectedGender,
                  onGenderChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                )
                    : RoundTextField(
                  textEditingController: _genderController,
                  hintText: _dogGender.isEmpty ? "Loading..." : _dogGender,
                  icon: "assets/icons/gender_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
                  errorText: _genderError,
                ),
                const SizedBox(height: 15),
                DateSelector(
                  birthdateController: _dateOfBirthController,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _weightController,
                  hintText: _dogWeight.isEmpty ? "Loading..." : _dogWeight,
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.number,
                  readOnly: !_isEditing,
                  errorText: _weightError,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _heightController,
                  hintText: _dogHeight.isEmpty ? "Loading..." : _dogHeight,
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.number,
                  readOnly: !_isEditing,
                  errorText: _heightError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
