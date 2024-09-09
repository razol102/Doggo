import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String hintText;
  final String icon;
  final TextInputType textInputType;
  final bool isObscureText;
  final Widget? rightIcon;
  final bool readOnly;
  final String? errorText;
  final String? title;

  const RoundTextField({
    super.key,
    this.textEditingController,
    required this.hintText,
    required this.icon,
    required this.textInputType,
    this.isObscureText = false,
    this.rightIcon,
    this.readOnly = false,
    this.errorText,
    this.title
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(padding: const EdgeInsets.only(left: 12),
          child: Text(
            title!,
            style: const TextStyle(
              color: AppColors.grayColor,
              fontSize: 12,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGrayColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: textEditingController,
            keyboardType: textInputType,
            obscureText: isObscureText,
            readOnly: readOnly,
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hintText,
              prefixIcon: Container(
                alignment: Alignment.center,
                width: 20,
                height: 20,
                child: Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  color: AppColors.grayColor,
                ),
              ),
              suffixIcon: rightIcon,
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.grayColor),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}