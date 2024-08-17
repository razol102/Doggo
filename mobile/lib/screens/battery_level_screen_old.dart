// import 'package:flutter/material.dart';
// import 'package:mobile/services/ble_service.dart';
//
// class BatteryLevelScreen extends StatelessWidget {
//   final String deviceId;
//   final int batteryLevel;
//   final int stepCount;
//   final BleService bleService;
//
//   BatteryLevelScreen({
//     required this.deviceId,
//     required this.batteryLevel,
//     required this.stepCount,
//     required this.bleService,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('DoggoCollar Status'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.bluetooth_connected),
//             color: Colors.green,
//             onPressed: () {
//               bleService.disconnect();
//               Navigator.pop(context);
//             },
//           )
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Connected to $deviceId'),
//             Text('Battery Level: $batteryLevel%'),
//             Text('Step Count: $stepCount'),
//           ],
//         ),
//       ),
//     );
//   }
// }
