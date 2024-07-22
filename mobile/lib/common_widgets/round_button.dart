import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RoundButton extends StatelessWidget {
  final String? title;  // Nullable title
  final Function() onPressed;
  final Color backgroundColor;
  final Color titleColor;
  final IconData? icon;  // Optional icon parameter
  final double? iconSize;

  const RoundButton({
    super.key,
    this.title,  // Nullable title
    required this.onPressed,
    required this.backgroundColor,
    required this.titleColor,
    this.icon,  // Optional icon parameter
    this.iconSize

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[

                Icon(icon, color: titleColor,size: iconSize),
              ],
              if (icon != null && title != null) const SizedBox(width: 8),
              if (title != null) Text(
                title!,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

