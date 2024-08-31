import 'package:flutter/material.dart';

class SocialNetworkScreen extends StatelessWidget {
  static String routeName = "/SocialNetworkScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/coming_soon_background.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
