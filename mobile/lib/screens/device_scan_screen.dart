// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:mobile/services/ble_service.dart';
// import 'battery_level_screen_old.dart';
//
// class DeviceScanScreen extends StatefulWidget {
//   final Function(String) onDeviceSelected;
//
//   DeviceScanScreen({required this.onDeviceSelected});
//
//   @override
//   _DeviceScanScreenState createState() => _DeviceScanScreenState();
// }
//
// class _DeviceScanScreenState extends State<DeviceScanScreen> {
//   final BleService _bleService = BleService();
//   StreamSubscription<DiscoveredDevice>? _scanSubscription;
//   String? _deviceId;
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   void _startScan() {
//     setState(() {
//       _isScanning = true;
//     });
//
//     _scanSubscription = _bleService.scanForDevices().listen((device) {
//       if (device.name == 'DoggoCollar') {
//         setState(() {
//           _deviceId = device.id;
//           _isScanning = false;
//         });
//         _connectToDevice(device.id);
//       }
//     }, onError: (error) {
//       setState(() {
//         _isScanning = false;
//       });
//       print('Scan error: $error');
//     });
//   }
//
//   void _connectToDevice(String deviceId) {
//     _bleService.connectToDevice(
//       deviceId,
//           (batteryLevel) {
//         setState(() {
//           _bleService.batteryLevel = batteryLevel;
//         });
//       },
//           (stepCount) {
//         setState(() {
//           _bleService.stepCount = stepCount;
//         });
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => BatteryLevelScreen(
//               deviceId: deviceId,
//               batteryLevel: _bleService.batteryLevel,
//               stepCount: _bleService.stepCount,
//               bleService: _bleService,
//             ),
//           ),
//         );
//       },
//     ).catchError((error) {
//       print('Connection error: $error');
//       setState(() {
//         _isScanning = true;
//         _startScan();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _scanSubscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scanning for Devices'),
//       ),
//       body: Center(
//         child: _isScanning
//             ? const CircularProgressIndicator()
//             : (_deviceId == null
//             ? const Text('Scanning for DoggoCollar...')
//             : const Text('Connecting to DoggoCollar...')),
//       ),
//     );
//   }
// }
