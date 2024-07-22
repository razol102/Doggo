import 'package:flutter/material.dart';

class AppColors{
  static const primaryColor1 =  Color(0xFFFDDD7E);
  static const primaryColor2 =  Color(0xFFFDB45E);

  static const secondaryColor1 =  Color(0xFF91481C);
  static const secondaryColor2 =  Color(0xFFFFA33C);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF1D1617);
  static const grayColor = Color(0xFF7B6F72);
  static const lightGrayColor = Color(0xFFF7F8F8);
  static const midGrayColor = Color(0xFFADA4A5);

  static List<Color> get primaryG => [primaryColor1,primaryColor2];
  static List<Color> get secondaryG => [secondaryColor1,secondaryColor2];
  static List<Color> get darkG => [secondaryColor1, const Color(0xFFB73A00)];
}