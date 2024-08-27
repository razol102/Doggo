import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mobile/services/ble_service.dart';

class BleConnectionScreen extends StatefulWidget {
  static const routeName = '/BLEConnectionScreen';
  @override
  _BleConnectionScreenState createState() => _BleConnectionScreenState();
}

class _BleConnectionScreenState extends State<BleConnectionScreen> with WidgetsBindingObserver {
  final BleService _bleService = BleService();
  String _deviceId = '';
  String _statusMessage = 'Not connected';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateConnectionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateConnectionStatus();
    }
  }

  void _updateConnectionStatus() {
    setState(() {
      _statusMessage = _bleService.isConnected ? 'Connected' : 'Not connected';
    });
  }

  void _startScan() {
    setState(() {
      _statusMessage = 'Scanning...';
    });
    _bleService.startScan((DiscoveredDevice device) {
      setState(() {
        _deviceId = device.id;
        _statusMessage = 'Device found: ${device.name}';
      });
      _connectToDevice();
    });
  }

  void _connectToDevice() {
    if (_deviceId.isNotEmpty) {
      setState(() {
        _statusMessage = 'Connecting...';
      });
      _bleService.connectToDevice(
        _deviceId,
            (int batteryLevel) {
          _updateConnectionStatus();
        },
            (int stepCount) {
          // Handle step count update if needed
        },

          () {
            setState(() {
              _statusMessage = 'Disconnected';
              _deviceId = '';  // Reset device ID
            });
            _bleService.stopScan(); // Stop any ongoing scans
            _bleService.disconnect(); // Ensure the device is properly disconnected
            // Optionally, show a notification or alert dialog to the user
            _showDisconnectedDialog();
          }
      );
    }
  }

  void _showDisconnectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Device Disconnected'),
          content: Text('The BLE device has been disconnected.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _disconnectFromDevice() {
    _bleService.disconnectFromDevice();
    _bleService.resetService();
    _updateConnectionStatus();
    setState(() {
      _deviceId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_statusMessage, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bleService.isConnected ? null : _startScan,
              child: Text(_bleService.isConnected ? 'Connected' : 'Scan and Connect'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _bleService.isConnected ? _disconnectFromDevice : null,
              child: Text('Disconnect'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateConnectionStatus,
              child: Text('Refresh Connection Status'),
            ),
          ],
        ),
      ),
    );
  }
}