import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/services/ble_service.dart';
import 'battery_level_screen.dart';

class DeviceScanScreen extends StatefulWidget {
  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  String? deviceId;
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();

    final scanCompleter = BleService().startScan((id) {
      setState(() {
        deviceId = id;
      });
    });

    Future.any(
        <Future>[scanCompleter.future, Future.delayed(Duration(seconds: 30))])
        .then((_) {
      if (deviceId == null) {
        setState(() {
          deviceId = 'not_found';
        });
      } else {
        BleService().connectToDevice(deviceId!, (level) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BatteryLevelScreen(batteryLevel: level),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanning for Devices'),
      ),
      body: Center(
        child: deviceId == 'not_found'
            ? Text('DoggoCollar not found :(\nPlease try again.')
            : (deviceId == null
            ? Text('Scanning for DoggoCollar...')
            : Text('Connecting to DoggoCollar...')),
      ),
    );
  }
}