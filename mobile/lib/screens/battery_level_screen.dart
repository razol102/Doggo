import 'package:flutter/material.dart';
import 'package:mobile/services/ble_service.dart';

class BatteryLevelScreen extends StatefulWidget {
  final String deviceId;
  final BleService bleService;
  const BatteryLevelScreen({super.key, required this.deviceId, required this.bleService});

  @override
  _BatteryLevelScreenState createState() => _BatteryLevelScreenState(deviceId, bleService);
}

class _BatteryLevelScreenState extends State<BatteryLevelScreen> {
  final String deviceId;
  final BleService bleService;
  int _batteryLevel = 0;
  //final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  _BatteryLevelScreenState(this.deviceId, this.bleService);

  @override
  void initState() {
    super.initState();
    bleService.readBatteryLevelPeriodically(deviceId, setBatteryLevel);
  }

  void setBatteryLevel(int batteryLevel) {
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Level'),
      ),
      body: Center(
        child: Text(
          'Battery Level: $_batteryLevel%',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}