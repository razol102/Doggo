import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/screens/welcome_screen.dart';
import 'package:mobile/utils/app_colors.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Doggo Collar',
      debugShowCheckedModeBanner: false,
      routes: routes,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor1,
        useMaterial3: true,
        fontFamily: "Poppins"
      ),
      home: const WelcomeScreen(),
    );
  }
}