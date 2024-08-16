import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobile/common_widgets/date_selector.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/services/validation_methods.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class PersonalDataScreen extends StatefulWidget {
  static String routeName = "/PersonalDataScreen";

  const PersonalDataScreen({super.key});

  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  bool _isEditing = false;
  bool _isChangingPassword = false;
  final PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'IL'); // Set initial phone number to +972


  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userPhoneNumber = 'Loading...';
  DateTime? _userDateOfBirth;
  String _oldPassword = ''; // Store the current password

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _dateError;
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      int? userId = await PreferencesService.getUserId();
      if (userId != null) {
        final userInfo = await HttpService.getUserInfo(userId);
        setState(() {
          _userName = userInfo['name'];
          _userEmail = userInfo['email'];
          _userPhoneNumber = userInfo['phone_number'];
          _userDateOfBirth = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
              .parse(userInfo['date_of_birth'], true)
              .toLocal();
          _oldPassword = userInfo['password']; // Save the fetched password

          _nameController.text = _userName;
          _emailController.text = _userEmail;
          _phoneNumberController.text = _userPhoneNumber;
          _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_userDateOfBirth!);
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _userName = 'Error loading data';
        _userEmail = 'Error loading data';
        _userPhoneNumber = 'Error loading data';
        _userDateOfBirth = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _userDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _userDateOfBirth) {
      setState(() {
        _userDateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveUserProfile() async {
    setState(() {
      _nameError = ValidationMethods.validateNotEmpty(_nameController.text, 'Name');
      _emailError = ValidationMethods.validateEmail(_emailController.text);
      _phoneError = ValidationMethods.validatePhoneNumber(_phoneNumberController.text);
      _dateError = ValidationMethods.validateNotEmpty(_dateOfBirthController.text, 'Dat of birth');
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;

      if (_isChangingPassword) {
        if (_oldPasswordController.text != _oldPassword) {
          _oldPasswordError = "Incorrect old password";
        }
        if (_newPasswordController.text.isEmpty) {
          _newPasswordError = "New password cannot be empty";
        } else if (_newPasswordController.text != _confirmPasswordController.text) {
          _confirmPasswordError = "Passwords do not match";
        }
      }
    });

    // Check if there are any errors
    if (_nameError != null || _emailError != null || _phoneError != null || _dateError != null ||
        _oldPasswordError != null || _newPasswordError != null || _confirmPasswordError != null) {
      // Don't proceed if there are errors
      return;
    }

    try {
      int? userId = await PreferencesService.getUserId();
      if (userId != null) {
        // Determine which password to send
        String password = _isChangingPassword
            ? _newPasswordController.text
            : _oldPassword; // Send old password if not changing

        await HttpService.updateUserProfile(
          userId,
          _emailController.text,
          password,
          _nameController.text,
          _userDateOfBirth!,
          _phoneNumberController.text,
        );

        // Re-fetch data to reflect updated values
        await _fetchUserData();

        // Exit edit mode after saving
        setState(() {
          _isEditing = false;
          _isChangingPassword = false;
          // Clear all error messages
          _emailError = _phoneError = _dateError = _oldPasswordError = _newPasswordError = _confirmPasswordError = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      print('Failed to update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: ${e.toString()}")),
      );
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
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveUserProfile();
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
                  "assets/images/personal_data_background.png",
                  width: media.width * 0.8,
                ),
                const Text(
                  "Personal Data Info",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 25),
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: _userName.isEmpty ? "Loading..." : _userName,
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: !_isEditing,
                  errorText: _nameError,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _emailController,
                  hintText: _userEmail.isEmpty ? "Loading..." : _userEmail,
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                  readOnly: !_isEditing,
                  errorText: _emailError,
                ),
                const SizedBox(height: 15),
                _isEditing ?
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    _phoneNumberController.text = number.phoneNumber!;
                  },
                  formatInput: true,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _userPhoneNumber.isEmpty ? "Loading..." : '0${_userPhoneNumber.substring(4)}',
                  ),
                  initialValue: _initialPhoneNumber,
                ) :
                RoundTextField(
                  textEditingController: _phoneNumberController,
                  hintText: _userPhoneNumber.isEmpty ? "Loading..." : _userPhoneNumber,
                  icon: "assets/icons/phone_icon.png",
                  textInputType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 15),
                _isEditing?
                DateSelector(birthdateController: _dateOfBirthController) :
                RoundTextField(
                  hintText: _userDateOfBirth == null ? "Error retrieving date of birth" : _userDateOfBirth.toString(),
                  icon: "assets/icons/date_icon.png",
                  textInputType: TextInputType.datetime,
                  readOnly: true,
                ),
                const SizedBox(height: 15),
                if (_isEditing) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Change Password",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _isChangingPassword,
                        onChanged: (value) {
                          setState(() {
                            _isChangingPassword = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isChangingPassword) ...[
                    const SizedBox(height: 15),
                    RoundTextField(
                      textEditingController: _oldPasswordController,
                      hintText: "Enter old password",
                      icon: "assets/icons/password_icon.png",
                      textInputType: TextInputType.visiblePassword,
                      isObscureText: true,
                      readOnly: !_isEditing,
                      errorText: _oldPasswordError,
                    ),
                    const SizedBox(height: 15),
                    RoundTextField(
                      textEditingController: _newPasswordController,
                      hintText: "Enter new password",
                      icon: "assets/icons/password_icon.png",
                      textInputType: TextInputType.visiblePassword,
                      isObscureText: true,
                      readOnly: !_isEditing,
                      errorText: _newPasswordError,
                    ),
                    const SizedBox(height: 15),
                    RoundTextField(
                      textEditingController: _confirmPasswordController,
                      hintText: "Confirm new password",
                      icon: "assets/icons/password_icon.png",
                      textInputType: TextInputType.visiblePassword,
                      isObscureText: true,
                      readOnly: !_isEditing,
                      errorText: _confirmPasswordError,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
