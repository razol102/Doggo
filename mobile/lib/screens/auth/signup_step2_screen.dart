import 'package:flutter/material.dart';
import '../../common_widgets/round_button.dart';
import '../../utils/app_colors.dart';
import '../../common_widgets/round_textfield.dart';

class SignUpStep2Screen extends StatefulWidget {
  static String routeName = "/SignUpStep2Screen";

  const SignUpStep2Screen({super.key});

  @override
  _SignUpStep2ScreenState createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // To store data passed from the previous screen
  Map<String, dynamic>? _signupData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments passed from SignUpStep1Screen
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      _signupData = arguments;
    }
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
                              "Almost There...",
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
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _confirmPasswordController,
                              hintText: "Confirm Password",
                              icon: 'assets/icons/lock_icon.png',
                              textInputType: TextInputType.text,
                              isObscureText: true,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            RoundButton(
                              title: "Register",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Ensure passwords match
                                  if (_passwordController.text != _confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Passwords do not match")),
                                    );
                                    return;
                                  }

                                  // Use the retrieved data
                                  final fullName = _signupData?['fullName'];
                                  final birthdate = _signupData?['birthdate'];
                                  final phoneNumber = _signupData?['phoneNumber'];
                                  final email = _emailController.text;
                                  final password = _passwordController.text;

                                  // Perform the registration action
                                  //TODO: delete after implementation
                                  print("Full Name: $fullName");
                                  print("Birthdate: $birthdate");
                                  print("Phone Number: $phoneNumber");
                                  print("Email: $email");
                                  print("Password: $password");

                                  // await registerUser(fullName, birthdate, phoneNumber, email, password);
                                  // After successful registration, navigate to a different screen or show a success message
                                }
                              },
                              backgroundColor: AppColors.whiteColor,
                              titleColor: AppColors.secondaryColor1,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
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
