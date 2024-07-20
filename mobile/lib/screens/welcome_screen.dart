import 'package:mobile/screens/signup_screen.dart';
import 'package:mobile/utils/app_colors.dart';

import 'package:flutter/material.dart';
import '../../common_widgets/round_gradient_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static String routeName = "/WelcomeScreen";

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: media.width * 0.2),
              const Text(
                "Welcome!",
                style: TextStyle(
                  color: AppColors.secondaryColor1,
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
              Image.asset("assets/images/welcome_promo.png",
                  width: media.width * 1.5, fit: BoxFit.fitWidth),
              const Text(
                "Your companion for a healthier & happier\nlife with your dog",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: media.width * 0.05),
              RoundGradientButton(
                title: "Login",
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, SignUpScreen.routeName);
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 11,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 14,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                        )
                      )
                    ]
                  )
                )
              )

            ],
          ),
        ),
      ),
    );
  }
}