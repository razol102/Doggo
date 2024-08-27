// import 'package:flutter/material.dart';
// import 'package:mobile/services/http_service.dart';
// import 'package:mobile/services/preferences_service.dart';
// import 'package:mobile/services/validation_methods.dart';
//
// import '../../common_widgets/round_textfield.dart';
// import '../../utils/app_colors.dart';
//
// class MedicalScreen extends StatefulWidget {
//   static const String routeName = "/MedicalScreen";
//
//   const MedicalScreen({super.key});
//
//   @override
//   _MedicalScreenState createState() => _MedicalScreenState();
// }
//
// class _MedicalScreenState extends State<MedicalScreen> {
//   late bool _isEditing = false;
//   String _foodBrand = 'Loading...';
//   String _foodType = 'Loading...';
//   String _foodAmountGrams = 'Loading...';
//   String _dailySnacks = 'Loading...';
//   String _notes = 'Loading...';
//
//   String? _foodBrandError;
//   String? _foodTypeError;
//   String? _foodAmountGramsError;
//   String? _dailySnacksError;
//
//   final TextEditingController _foodBrandController = TextEditingController();
//   final TextEditingController _foodTypeController = TextEditingController();
//   final TextEditingController _foodAmountGramsController = TextEditingController();
//   final TextEditingController _dailySnacksController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchNutritionData();
//   }
//
//   Future<void> _fetchNutritionData() async {
//     try {
//       final int? dogId = await PreferencesService.getDogId();
//       if (dogId != null) {
//         final nutritionData = await HttpService.getNutritionData(dogId);
//         if (nutritionData != null) {
//           setState(() {
//             _foodBrand = nutritionData['food_brand'];
//             _foodType = nutritionData['food_type'];
//             _foodAmountGrams = nutritionData['food_amount_grams'];
//             _dailySnacks = nutritionData['daily_snacks'];
//             _notes = nutritionData['notes'];
//
//             _foodBrandController.text = _foodBrand;
//             _foodTypeController.text = _foodType;
//             _foodAmountGramsController.text = _foodAmountGrams;
//             _dailySnacksController.text = _dailySnacks;
//             _notesController.text = _notes;
//
//           });
//         } else { // No nutrition data
//           _resetNutritionData();
//         }
//       }
//     } catch (e) {
//       print('Error fetching nutrition data: $e');
//       _resetNutritionData();
//     }
//   }
//
//   void _resetNutritionData() {
//     setState(() {
//       _foodBrand = 'No nutrition information available';
//       _foodType = 'No nutrition information available';
//       _foodAmountGrams = 'No nutrition information available';
//       _dailySnacks = '0';
//       _notes = '-';
//     });
//   }
//
//   Future<void> _saveNutritionData() async {
//     setState(() {
//       _foodBrandError = ValidationMethods.validateNotEmpty(_foodBrandController.text, 'Food brand');
//       _foodTypeError = ValidationMethods.validateNotEmpty(_foodTypeController.text, 'Food type');
//       _foodAmountGramsError = ValidationMethods.validatePositiveInt(_foodAmountGramsController.text, 'Food amount');
//       if (_dailySnacksController.text.isEmpty) {
//         _dailySnacksController.text = '0';
//       }
//     });
//
//     if (_foodBrandError != null || _foodTypeError != null || _foodAmountGramsError != null || _dailySnacksError != null) {
//       return;
//     }
//
//     try {
//       final int? dogId = await PreferencesService.getDogId();
//       if (dogId != null) {
//         await HttpService.addUpdateNutrition(
//           dogId,
//           _foodBrandController.text,
//           _foodTypeController.text,
//           int.parse(_foodAmountGramsController.text),
//           int.parse(_dailySnacksController.text),
//           _notesController.text,
//         );
//         await _fetchNutritionData();
//         setState(() {
//           _isEditing = false;
//           _foodBrandError = null;
//           _foodTypeError = null;
//           _foodAmountGramsError = null;
//           _dailySnacksError = null;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Dog nutrition updated successfully")),
//         );
//       }
//     } catch (e) {
//       print('Failed to update nutrition: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update dog nutrition: ${e.toString()}")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: AppColors.whiteColor,
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               if (_isEditing) {
//                 _saveNutritionData();
//               } else {
//                 setState(() {
//                   _isEditing = true;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               children: [
//                 Image.asset(
//                   "assets/images/nutrition_background.png",
//                   width: media.width * 0.7,
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Dog Profile Info",
//                   style: TextStyle(
//                     color: AppColors.blackColor,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 RoundTextField(
//                   textEditingController: _foodBrandController,
//                   hintText: (_foodBrand == 'No nutrition information available' && _isEditing) ? "Food brand" : _foodBrand,
//                   icon: "assets/icons/food_brand_icon.png",
//                   textInputType: TextInputType.text,
//                   readOnly: !_isEditing,
//                   errorText: _foodBrandError,
//                 ),
//                 const SizedBox(height: 15),
//                 RoundTextField(
//                   textEditingController: _foodTypeController,
//                   hintText: (_foodType == 'No nutrition information available' && _isEditing) ? "Food type" : _foodType,
//                   icon: "assets/icons/food_type_icon.png",
//                   textInputType: TextInputType.text,
//                   readOnly: !_isEditing,
//                   errorText: _foodTypeError,
//                 ),
//                 const SizedBox(height: 15),
//                 RoundTextField(
//                   textEditingController: _foodAmountGramsController,
//                   hintText: (_foodAmountGrams == 'No nutrition information available' && _isEditing) ? "Food amount (grams)" : _foodAmountGrams,
//                   icon: "assets/icons/food_amount_icon.png",
//                   textInputType: TextInputType.number,
//                   readOnly: !_isEditing,
//                   errorText: _foodAmountGramsError,
//                 ),
//                 const SizedBox(height: 15),
//                 RoundTextField(
//                   textEditingController: _dailySnacksController,
//                   hintText: _dailySnacks.isEmpty ? "0" : _dailySnacks,
//                   icon: "assets/icons/snacks_icon.png",
//                   textInputType: TextInputType.number,
//                   readOnly: !_isEditing,
//                   errorText: _dailySnacksError,
//                 ),
//                 const SizedBox(height: 15),
//                 RoundTextField(
//                   textEditingController: _notesController,
//                   hintText: _notes.isEmpty ? "-" : _notes,
//                   icon: "assets/icons/notes_icon.png",
//                   textInputType: TextInputType.text,
//                   readOnly: !_isEditing,
//                 ),
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
