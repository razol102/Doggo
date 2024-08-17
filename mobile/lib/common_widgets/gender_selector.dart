import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onGenderChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 50,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset(
              "assets/icons/gender_icon.png",
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: AppColors.grayColor,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGender,
                items: ["Male", "Female"]
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(
                    gender,
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 14,
                    ),
                  ),
                ))
                    .toList(),
                onChanged: onGenderChanged,
                isExpanded: true,
                hint: Text(
                  selectedGender ?? "Choose Gender",
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
