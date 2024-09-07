import 'package:flutter/material.dart';

class FrequencySelector extends StatefulWidget {
  final String selectedFrequency;
  final ValueChanged<String> onFrequencyChanged;
  final bool isReadOnly;

  FrequencySelector({
    Key? key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  _FrequencySelectorState createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  String _selectedFrequency = '';

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.selectedFrequency;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedFrequency,
      items: <String>['daily', 'weekly', 'monthly'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.capitalize()),
        );
      }).toList(),
      onChanged: widget.isReadOnly
          ? null
          : (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFrequency = newValue;
          });
          widget.onFrequencyChanged(newValue);
        }
      },
      isExpanded: true,
    );
  }
}

extension StringCapitalizeExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}