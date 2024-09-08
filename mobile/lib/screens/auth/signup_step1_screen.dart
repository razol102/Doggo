import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/services/validation_methods.dart';
import 'package:mobile/screens/auth/signup_step2_screen.dart';
import 'package:mobile/common_widgets/round_button.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_textfield.dart';
import 'package:mobile/common_widgets/date_selector.dart';

class SignUpStep1Screen extends StatefulWidget {
  static String routeName = "/SignUpStep1Screen";

  const SignUpStep1Screen({super.key});

  @override
  _SignUpStep1ScreenState createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'IL'); // Set initial phone number to +972
  String? _fullNameError;
  String? _phoneError;

  void _validateInputs() {
    setState(() {
      _fullNameError = ValidationMethods.validateNotEmpty(_fullNameController.text, 'Full Name');
      _phoneError = ValidationMethods.validatePhoneNumber(_phoneController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor1, AppColors.primaryColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                physics: constraints.maxHeight > 600 ? const NeverScrollableScrollPhysics() : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.15),
                            const Text(
                              "Register Now",
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 35,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 4.0,
                                    color: Color.fromARGB(128, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            RoundTextField(
                              textEditingController: _fullNameController,
                              hintText: "Full Name",
                              icon: 'assets/icons/profile_icon.png',
                              textInputType: TextInputType.name,
                              isObscureText: false,
                              errorText: _fullNameError,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            DateSelector(birthdateController: _birthdateController),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber number) {
                                  _phoneController.text = number.phoneNumber!;
                                },
                                formatInput: true,
                                selectorConfig: const SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DROPDOWN,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                inputDecoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Phone',
                                  errorText: _phoneError,
                                ),
                                initialValue: _initialPhoneNumber,
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            RoundButton(
                              title: "Next",
                              onPressed: () {
                                _validateInputs();
                                if (_fullNameError == null && _phoneError == null) {
                                  Navigator.pushNamed(
                                    context,
                                    SignUpStep2Screen.routeName,
                                    arguments: {
                                      'fullName': _fullNameController.text,
                                      'birthdate': _birthdateController.text,
                                      'phoneNumber': _phoneController.text,
                                    },
                                  );
                                }
                              },
                              backgroundColor: AppColors.whiteColor,
                              titleColor: AppColors.secondaryColor1,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            // Google & Facebook sign up
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: Container(
                            //         height: 1,
                            //         color: AppColors.grayColor.withOpacity(0.5),
                            //       ),
                            //     ),
                            //     const Text(
                            //       "  Or  ",
                            //       style: TextStyle(
                            //         color: AppColors.grayColor,
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w400,
                            //       ),
                            //     ),
                            //     Expanded(
                            //       child: Container(
                            //         height: 1,
                            //         color: AppColors.grayColor.withOpacity(0.5),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 20),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     GestureDetector(
                            //       onTap: () {
                            //         // Handle Google login
                            //       },
                            //       child: Container(
                            //         width: 50,
                            //         height: 50,
                            //         alignment: Alignment.center,
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(14),
                            //           border: Border.all(
                            //             color: AppColors.secondaryColor1.withOpacity(0.5),
                            //             width: 1,
                            //           ),
                            //         ),
                            //         child: Image.asset(
                            //           "assets/icons/google_icon.png",
                            //           width: 20,
                            //           height: 20,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 30),
                            //     GestureDetector(
                            //       onTap: () {
                            //         // Handle Facebook login
                            //       },
                            //       child: Container(
                            //         width: 50,
                            //         height: 50,
                            //         alignment: Alignment.center,
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(14),
                            //           border: Border.all(
                            //             color: AppColors.secondaryColor1.withOpacity(0.5),
                            //             width: 1,
                            //           ),
                            //         ),
                            //         child: Image.asset(
                            //           "assets/icons/facebook_icon.png",
                            //           width: 20,
                            //           height: 20,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, LoginScreen.routeName);
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor1,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
