
import 'package:flutter/cupertino.dart';
import 'package:mobile/screens/forgot_password_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/signup_screen.dart';
import 'package:mobile/screens/welcome_screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  // add screens here
};