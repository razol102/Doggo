import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_scan_screen.dart';

class HomeScreenOld extends StatefulWidget {

  static String routeName = "/HomeScreen";

  const HomeScreenOld({super.key});

  @override
  _HomeScreenOldState createState() => _HomeScreenOldState();
}

class _HomeScreenOldState extends State<HomeScreenOld> {
  bool _hasPermission = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    var locationStatus = await Permission.location.request();
    var bluetoothStatus = await Permission.bluetoothScan.request();
    var bluetoothConnectStatus = await Permission.bluetoothConnect.request();

    setState(() {
      _hasPermission = locationStatus.isGranted &&
          bluetoothStatus.isGranted &&
          bluetoothConnectStatus.isGranted;
      _permissionDenied = locationStatus.isDenied ||
          bluetoothStatus.isDenied ||
          bluetoothConnectStatus.isDenied;
    });
  }

  void _showPermissionDeniedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('The app cannot function without the required permissions. Please grant them in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: _hasPermission
            ? ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DeviceScanScreen()),
            );
          },
          child: const Text('Start Scan'),
        )
            : _permissionDenied
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Permission Denied'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPermissionDeniedMessage,
              child: const Text('Show Message'),
            ),
          ],
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}