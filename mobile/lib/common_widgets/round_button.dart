import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final Color backgroundColor;
  final Color titleColor;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.backgroundColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: MaterialButton(
          minWidth: double.maxFinite,
          height: 50,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textColor: AppColors.primaryColor1,
          child: Text(
            title,
            style: TextStyle(  // Changed from const TextStyle
              fontSize: 16,
              color: titleColor,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
