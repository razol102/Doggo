import 'package:flutter/material.dart';

class GoalCategorySelector extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final bool isReadOnly;

  GoalCategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  _GoalCategorySelectorState createState() => _GoalCategorySelectorState();
}

class _GoalCategorySelectorState extends State<GoalCategorySelector> {
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedCategory,
      items: <String>['steps', 'distance', 'calories_burned'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.split('_').map((part) => part.capitalize()).join(' ')),
        );
      }).toList(),
      onChanged: widget.isReadOnly
          ? null
          : (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
          widget.onCategoryChanged(newValue);
        }
      },
      isExpanded: true,
    );
  }
}

extension StringCapitalizeExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}