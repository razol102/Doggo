
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/screens/add_new_dog/add_new_dog_screen.dart';
import 'package:mobile/screens/add_new_dog/configure_collar_screen.dart';
import 'package:mobile/screens/all_about_us/dog_data_screen.dart';
import 'package:mobile/screens/all_about_us/personal_data_screen.dart';
import 'package:mobile/screens/auth/forgot_password_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/signup_step1_screen.dart';
import 'package:mobile/screens/auth/signup_step2_screen.dart';
import 'package:mobile/screens/bottom_menu.dart';
import 'package:mobile/screens/activity/activity_screen.dart';
import 'package:mobile/screens/devices/BLE_connection_screen.dart';
import 'package:mobile/screens/devices/doggo_collar_screen.dart';
import 'package:mobile/screens/dog_care/food_nutrition_screen.dart';
import 'package:mobile/screens/dog_care/medical_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/map/map_screen.dart';
import 'package:mobile/screens/map/pension_vet_map_screen.dart';
import 'package:mobile/screens/medical/medical_records_screen.dart';
import 'package:mobile/screens/other/contact_us_screen.dart';
import 'package:mobile/screens/other/faq_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/social_network/social_network_screen.dart';
import 'package:mobile/screens/welcome_screen.dart';

final Map<String, WidgetBuilder> routes = {
  //welcome
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  //auth
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignUpStep1Screen.routeName: (context) => const SignUpStep1Screen(),
  SignUpStep2Screen.routeName: (context) => const SignUpStep2Screen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  //add new dog
  AddNewDogScreen.routeName: (context) => const AddNewDogScreen(),
  //menu
  BottomMenu.routeName: (context) => const BottomMenu(),
  //profile
  UserProfileScreen.routeName: (context) => const UserProfileScreen(),
  //collar
  DoggoCollarScreen.routeName: (context) => const DoggoCollarScreen(),
  //dog data
  DogDataScreen.routeName: (context) => const DogDataScreen(),
  //personal data
  PersonalDataScreen.routeName: (context) => const PersonalDataScreen(),
  //food nutrition
  FoodNutritionScreen.routeName: (context) => const FoodNutritionScreen(),
  //pension
  // PensionScreen.routeName: (context) => const PensionScreen(),
  //medical
  MedicalScreen.routeName: (context) => const MedicalScreen(),
  //medical records
  MedicalRecordsScreen.routeName: (context) => MedicalRecordsScreen(),
  //faq
  FaqScreen.routeName : (context) => FaqScreen(),
  //contact us
  ContactUsScreen.routeName : (context) => const ContactUsScreen(),
  //home
  HomeScreen.routeName: (context) => const HomeScreen(),
  //activity
  ActivityScreen.routeName: (context) => ActivityScreen(),
  //map
  //social network
  SocialNetworkScreen.routeName: (context) => SocialNetworkScreen(),
  MapScreen.routeName: (context) => const MapScreen(),
  //ble connection
  BleConnectionScreen.routeName: (context) => BleConnectionScreen(),
  //configure collar

  // add screens here
};