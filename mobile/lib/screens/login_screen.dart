import 'package:flutter/material.dart';
import 'package:mobile/screens/forgot_password_screen.dart';
import '../common_widgets/round_button.dart';
import '../utils/app_colors.dart';
import '../../common_widgets/round_textfield.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/LoginScreen";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                physics: constraints.maxHeight > 600 ? NeverScrollableScrollPhysics() : null,
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
                            SizedBox(height: constraints.maxHeight * 0.2),
                            const Text(
                              "Login",
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
                              textEditingController: _emailController,
                              hintText: "Email",
                              icon: 'assets/icons/message_icon.png',
                              textInputType: TextInputType.emailAddress,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _passwordController,
                              hintText: "Password",
                              icon: 'assets/icons/lock_icon.png',
                              textInputType: TextInputType.text,
                              isObscureText: true,
                              rightIcon: GestureDetector(
                                onTap: () {
                                  // Handle show/hide password
                                  setState(() {
                                    _passwordController.text.isNotEmpty;
                                  });
                                },
                                child: const Icon(
                                  Icons.visibility,
                                  color: AppColors.grayColor,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppColors.secondaryColor1,
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.05),
                            RoundButton(
                              title: "Login",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Perform login action
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
