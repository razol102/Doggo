import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mobile/services/ble_service.dart';

class BleTestScreen extends StatefulWidget {
  static const routeName = '/BLETestScreen';
  @override
  _BleTestScreenState createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  final BleService _bleService = BleService();
  String _deviceId = '';
  //int _batteryLevel = 0;
  //int _stepCount = 0;
  bool _isConnected = false;
  String _statusMessage = 'Not connected';

  void _startScan() {
    setState(() {
      _statusMessage = 'Scanning...';
    });
    _bleService.startScan((DiscoveredDevice device) {
      setState(() {
        _deviceId = device.id;
        print("****************************************$_deviceId*********************************");
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
          setState(() {
            //_batteryLevel = batteryLevel;
            //print(_batteryLevel);
            _isConnected = true;
            _statusMessage = 'Connected';
          });
        },
            (int stepCount) {
          setState(() {
            //_stepCount = stepCount;
            //print(_stepCount);
          });
        },
      );
    }
  }

  void _disconnectFromDevice() {
    _bleService.disconnectFromDevice();
    setState(() {
      _isConnected = false;
      _statusMessage = 'Disconnected';
      //_batteryLevel = 0;
      //_stepCount = 0;
      _deviceId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Test Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_statusMessage, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            //Text('Battery Level: $_batteryLevel%', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            //Text('Step Count: $_stepCount', style: TextStyle(fontSize: 24)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isConnected ? null : _startScan,
              child: Text(_isConnected ? 'Connected' : 'Scan and Connect'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isConnected ? _disconnectFromDevice : null,
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
