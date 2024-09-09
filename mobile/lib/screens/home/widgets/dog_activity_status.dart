import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/title_subtitle_cell.dart';
import 'package:mobile/services/http_service.dart';
import 'dart:async';

import 'date_circles.dart';

class DogActivityStatus extends StatefulWidget {
  @override
  _DogActivityStatusState createState() => _DogActivityStatusState();
}

// class _DogActivityStatusState extends State<DogActivityStatus> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   int currentSteps = 0;
//   int totalSteps = 2000; // Avoid division by zero by default value
//   int calories = 0;
//   double distance = 0;
//   Timer? _timer;
//   double _currentProgress = 0;
//   DateTime selectedDate = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
//     _fetchActivityStatus(selectedDate);
//
//     // Set up the periodic timer
//     _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//       _fetchActivityStatus(selectedDate);
//     });
//   }
//
//   Future<void> _fetchActivityStatus(DateTime date) async {
//     try {
//       // Format the date to 'yyyy-MM-dd'
//       String formattedDate = DateFormat('yyyy-MM-dd').format(date);
//
//       // Fetch the dogId from preferences
//       final dogId = await PreferencesService.getDogId();
//
//       if (dogId != null) {
//         // Try fetching the activity status and daily steps goal
//         final status = await HttpService.fetchDogActivityStatus(formattedDate, dogId);
//         final dailyStepsGoal = await HttpService.getDailyStepsGoal(dogId);
//
//         // Update UI with fetched data
//         setState(() {
//           currentSteps = status['steps']!;
//           totalSteps = dailyStepsGoal;
//           calories = status['calories_burned']!;
//           distance = status['distance']!;
//
//           // Update animation progress
//           double newProgress = currentSteps / totalSteps;
//           _animation = Tween<double>(begin: _currentProgress, end: newProgress).animate(_controller);
//           _currentProgress = newProgress;
//           _controller.forward(from: 0);
//         });
//       }
//     } catch (e) {
//       print("an error occurred while trying fetch activity status: ${e.toString()}");
//     }
//   }
//
//
//   void _onDateSelected(DateTime date) {
//     setState(() {
//       selectedDate = date;
//     });
//     _fetchActivityStatus(date);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer?.cancel(); // Cancel the timer when disposing the widget
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         DateCircles(onDateSelected: _onDateSelected),
//         SizedBox(height: media.width * 0.07),
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return SizedBox(
//                   width: 200,
//                   height: 200,
//                   child: CircularProgressIndicator(
//                     value: _animation.value,
//                     strokeWidth: 10,
//                     backgroundColor: Colors.grey.shade200,
//                     valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor1),
//                   ),
//                 );
//               },
//             ),
//             Container(
//               width: 160,
//               height: 160,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/nala_profile.png"),
//                   // image: AssetImage("assets/images/dog_profile.png"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 15),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "$currentSteps",
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontFamily: "Poppins",
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.secondaryColor1,
//               ),
//             ),
//             SizedBox(width: 8),
//             Text(
//               "/ $totalSteps",
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: "Poppins",
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.blackColor,
//               ),
//             ),
//             SizedBox(width: 4),
//             const Text(
//               "Steps per day",
//               style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: "Poppins",
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.blackColor,
//               ),
//             )
//           ],
//         ),
//         SizedBox(height: 5),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TitleSubtitleCell(
//               title: "$calories",
//               subtitle: "Calories",
//               boxHeight: 80,
//               boxWidth: 120,
//               titleFontSize: 16,
//               subtitleFontSize: 14,
//               icon: Icons.local_fire_department,
//             ),
//             TitleSubtitleCell(
//               title: "$distance km",
//               subtitle: "Distance",
//               boxHeight: 80,
//               boxWidth: 120,
//               titleFontSize: 16,
//               subtitleFontSize: 14,
//               icon: Icons.pets_rounded,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class _DogActivityStatusState extends State<DogActivityStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentSteps = 0;
  int totalSteps = 2000; // Avoid division by zero by default value
  int calories = 0;
  double distance = 0;
  Timer? _timer;
  double _currentProgress = 0;
  DateTime selectedDate = DateTime.now();
  int? _dogId;
  String? _dogImagePath = "assets/images/dog_profile.png";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

    // Fetch dogId and image path
    _initializeDogIdAndImage();

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _fetchActivityStatus(selectedDate);
    });
  }

  Future<void> _initializeDogIdAndImage() async {
    try {
      final dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        setState(() {
          _dogId = dogId;
          _dogImagePath = _getImagePath(dogId); // Fetch the image path based on the dogId
        });
        _fetchActivityStatus(selectedDate);
      }
    } catch (e) {
      print("Error initializing dogId and image path: ${e.toString()}");
    }
  }

  // method for exhibition only!
  String _getImagePath(int dogId) {
    String imagePath;
    switch(dogId) {
      case 28:
        imagePath = "assets/images/nala_profile.png";
        break;
      default:
        imagePath = "assets/images/dog_profile.png";
        break;
    }

    return imagePath;

  }

  Future<void> _fetchActivityStatus(DateTime date) async {
    if (_dogId == null) return; // If dogId is not set, don't fetch data

    try {
      // Format the date to 'yyyy-MM-dd'
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Try fetching the activity status and daily steps goal
      final status = await HttpService.fetchDogActivityStatus(formattedDate, _dogId!);
      final dailyStepsGoal = await HttpService.getDailyStepsGoal(_dogId!);

      // Update UI with fetched data
      setState(() {
        currentSteps = status['steps']!;
        totalSteps = dailyStepsGoal;
        calories = status['calories_burned']!;
        distance = status['distance']!;

        // Update animation progress
        double newProgress = currentSteps / totalSteps;
        _animation = Tween<double>(begin: _currentProgress, end: newProgress).animate(_controller);
        _currentProgress = newProgress;
        _controller.forward(from: 0);
      });
    } catch (e) {
      print("Error fetching activity status: ${e.toString()}");
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _fetchActivityStatus(date);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DateCircles(onDateSelected: _onDateSelected),
        SizedBox(height: media.width * 0.07),
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor1),
                  ),
                );
              },
            ),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(_dogImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$currentSteps",
              style: const TextStyle(
                fontSize: 28,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryColor1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "/ $totalSteps",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "Steps per day",
              style: TextStyle(
                fontSize: 12,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TitleSubtitleCell(
              title: "$calories",
              subtitle: "Calories",
              boxHeight: 80,
              boxWidth: 120,
              titleFontSize: 16,
              subtitleFontSize: 14,
              icon: Icons.local_fire_department,
            ),
            TitleSubtitleCell(
              title: "$distance km",
              subtitle: "Distance",
              boxHeight: 80,
              boxWidth: 120,
              titleFontSize: 16,
              subtitleFontSize: 14,
              icon: Icons.pets_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
