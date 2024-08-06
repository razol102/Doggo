
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/screens/auth/forgot_password_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/signup_step1_screen.dart';
import 'package:mobile/screens/auth/signup_step2_screen.dart';
import 'package:mobile/screens/ble_test_screen.dart';
import 'package:mobile/screens/bottom_menu.dart';
import 'package:mobile/screens/activity/activity_screen.dart';
import 'package:mobile/screens/devices/BLE_connection_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/map/map_screen.dart';
import 'package:mobile/screens/profile/user_profile_screen.dart';

final Map<String, WidgetBuilder> routes = {
  //auth
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignUpStep1Screen.routeName: (context) => const SignUpStep1Screen(),
  SignUpStep2Screen.routeName: (context) => const SignUpStep2Screen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  //menu
  BottomMenu.routeName: (context) => const BottomMenu(),
  //profile
  UserProfileScreen.routeName: (context) => const UserProfileScreen(),
  //home
  HomeScreen.routeName: (context) => const HomeScreen(),
  //activity
  ActivityScreen.routeName: (context) => const ActivityScreen(),
  //map
  MapScreen.routeName: (context) => const MapScreen(),
  //ble connection
  BleConnectionScreen.routeName: (context) => BleConnectionScreen(),
  //BleTestScreen.routeName: (context) => BleTestScreen(),
  // add screens here
};