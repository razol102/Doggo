import 'package:flutter/material.dart';
import '../common_widgets/round_button.dart';
import '../utils/app_colors.dart';
import '../../common_widgets/round_textfield.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = "/SignUpScreen";

  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.1),
                            const Text(
                              "Sign Up",
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
                            SizedBox(height: constraints.maxHeight * 0.05),
                            RoundTextField(
                              textEditingController: _fullNameController,
                              hintText: "Full Name",
                              icon: 'assets/icons/profile_icon.png',
                              textInputType: TextInputType.name,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _birthdateController,
                              hintText: "Birthdate",
                              icon: 'assets/icons/date_icon.png',
                              textInputType: TextInputType.name,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _emailController,
                              hintText: "Email",
                              icon: 'assets/icons/message_icon.png',
                              textInputType: TextInputType.emailAddress,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _phoneController,
                              hintText: "Phone Number",
                              icon: 'assets/icons/phone_icon.png',
                              textInputType: TextInputType.phone,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _passwordController,
                              hintText: "Password",
                              icon: 'assets/icons/lock_icon.png',
                              textInputType: TextInputType.text,
                              isObscureText: true,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _confirmPasswordController,
                              hintText: "Confirm Password",
                              icon: 'assets/icons/lock_icon.png',
                              textInputType: TextInputType.text,
                              isObscureText: true,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.05),
                            RoundButton(
                              title: "Sign Up",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Perform sign-up action
                                }
                              },
                              backgroundColor: AppColors.whiteColor,
                              titleColor: AppColors.blackColor,
                            ),
                            const Spacer(),
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
