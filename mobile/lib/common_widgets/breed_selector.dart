import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';

class BreedSelector extends StatelessWidget {
  final List<String> dogBreeds = [
    "Labrador Retriever",
    "German Shepherd",
    "Golden Retriever",
    "Bulldog",
    "Beagle",
    "Poodle",
    "Rottweiler",
    "Yorkshire Terrier",
    "Dachshund",
    "Boxer",
    "Shih Tzu",
    "Doberman Pinscher",
    "Siberian Husky",
    "Great Dane",
    "Chihuahua",
    "Collie",
    "Border Collie",
    "Husky"
  ];
  final String? selectedBreed;
  final ValueChanged<String?> onBreedChanged;

  BreedSelector({
    Key? key,
    required this.selectedBreed,
    required this.onBreedChanged,
  }) : super(key: key);

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
              "assets/icons/breed_icon.png",
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: AppColors.grayColor,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedBreed,
                items: dogBreeds
                    .map((breed) => DropdownMenuItem(
                  value: breed,
                  child: Text(
                    breed,
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 14,
                    ),
                  ),
                ))
                    .toList(),
                onChanged: onBreedChanged,
                isExpanded: true,
                hint: Text(
                  selectedBreed ?? "Choose Breed",
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
