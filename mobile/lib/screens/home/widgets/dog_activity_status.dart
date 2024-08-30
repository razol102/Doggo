import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common_widgets/round_button.dart';
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

class _DogActivityStatusState extends State<DogActivityStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentSteps = 0;
  int totalSteps = 2000; // Avoid division by zero
  int calories = 0;
  double distance = 0;
  Timer? _timer;
  double _currentProgress = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _fetchActivityStatus(selectedDate);

    // Set up the periodic timer
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _fetchActivityStatus(selectedDate);
    });
  }

  Future<void> _fetchActivityStatus(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final status = await HttpService.fetchDogActivityStatus(formattedDate, dogId);
      final dailyStepsGoal = await HttpService.getDailyStepsGoal(dogId);
      setState(() {
        currentSteps = status['steps']!;
        totalSteps = dailyStepsGoal;
        calories = status['calories_burned']!;
        distance = status['distance']!;
        double newProgress = currentSteps / totalSteps;
        _animation = Tween<double>(begin: _currentProgress, end: newProgress).animate(_controller);
        _currentProgress = newProgress;
        _controller.forward(from: 0);
      });
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor1),
                  ),
                );
              },
            ),
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("assets/images/dog_profile.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
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
            SizedBox(width: 8),
            Text(
              "/ $totalSteps",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(width: 4),
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
        SizedBox(height: 5),
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
