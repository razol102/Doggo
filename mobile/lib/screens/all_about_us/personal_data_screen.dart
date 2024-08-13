import 'package:flutter/material.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class PersonalDataScreen extends StatefulWidget {
  static String routeName = "/PersonalDataScreen";

  const PersonalDataScreen({super.key});

  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userPhoneNumber = 'Loading...';
  String _userDateOfBirth = 'Loading...';

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
        //final dateOfBirth = DateTime.parse(userInfo['date_of_birth']).toLocal();
        setState(() {
          _userName = userInfo['name'];
          _userEmail = userInfo['email'];
          _userPhoneNumber = userInfo['phone_number'];
          //_userDateOfBirth = DateFormat('yyyy-MM-dd').format(dateOfBirth);
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _userName = 'Error loading data';
        _userEmail = 'Error loading data';
        _userPhoneNumber = 'Error loading data';
        _userDateOfBirth = 'Error loading data';
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
                  hintText: _userName.isEmpty ? "Loading..." : _userName,
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _userEmail.isEmpty ? "Loading..." : _userEmail,
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _userPhoneNumber.isEmpty ? "Loading..." : _userPhoneNumber,
                  icon: "assets/icons/phone_icon.png",
                  textInputType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: _userDateOfBirth.isEmpty ? "Loading..." : _userDateOfBirth,
                  icon: "assets/icons/date_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
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
