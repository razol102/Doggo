import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/utils/common.dart';

class DateCircles extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  DateCircles({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _DateCirclesState createState() => _DateCirclesState();
}

class _DateCirclesState extends State<DateCircles> {
  int _selectedIndex = 6; // Default selection is circle 6 - today

  List<String> weekDaysDate = getCurrentWeekDaysDate();
  List<String> weekDays = getCurrentWeekDays();

  void _onCircleTap(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    DateTime selectedDate = DateTime.now().subtract(Duration(days: 6 - index));
    widget.onDateSelected(selectedDate); // Call the callback function with the selected date
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () => _onCircleTap(index),
          child: Column(
            children: [
              Text(
                weekDays[index],
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 5,),
              CircleAvatar(
                backgroundColor: _selectedIndex == index
                    ? AppColors.primaryColor1
                    : Colors.grey.shade200,
                child: Text(
                  weekDaysDate[index],
                  style: TextStyle(color: _selectedIndex == index ? AppColors.secondaryColor1 : AppColors.blackColor,
                      fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.w300,
                      fontFamily: "Poppins"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
