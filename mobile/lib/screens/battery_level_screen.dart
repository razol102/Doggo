import 'package:flutter/material.dart';

class BatteryLevelScreen extends StatelessWidget {
  final int batteryLevel;

  BatteryLevelScreen({required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Battery Level'),
      ),
      body: Center(
        child: Text(
          'Battery Level: $batteryLevel%',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
