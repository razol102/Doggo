import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon; // Add optional icon parameter
  final double boxHeight;
  final double boxWidth;
  final double titleFontSize;
  final double subtitleFontSize;

  const TitleSubtitleCell({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon, // Initialize icon parameter
    required this.boxHeight,
    required this.boxWidth,
    required this.titleFontSize,
    required this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      width: boxWidth, // Use width
      height: boxHeight, // Use height
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: AppColors.darkG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.whiteColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: titleFontSize,
              ),
            ),
          ),
          SizedBox(height: 4), // Optional space between title and subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: subtitleFontSize, color: AppColors.grayColor),
                SizedBox(width: 4), // Space between icon and subtitle
              ],
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: subtitleFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
