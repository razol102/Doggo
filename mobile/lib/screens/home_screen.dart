import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: Text('Permission Denied'),
        content: Text('The app cannot function without the required permissions. Please grant them in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: _hasPermission
            ? ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeviceScanScreen()),
            );
          },
          child: Text('Start Scan'),
        )
            : _permissionDenied
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Permission Denied'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPermissionDeniedMessage,
              child: Text('Show Message'),
            ),
          ],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}