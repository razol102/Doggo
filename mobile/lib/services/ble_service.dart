import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleService {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  static const DOG_COLLAR_SERVICE = '0000180F-0000-1000-8000-00805f9b34fb';
  static const BATTERY_LEVEL_CHARACTERISTIC_UUID = '00002A19-0000-1000-8000-00805f9b34fb';

  Completer<void> startScan(Function(String) onDeviceDiscovered) {
    final completer = Completer<void>();
    flutterReactiveBle.scanForDevices(
      withServices: [Uuid.parse(DOG_COLLAR_SERVICE)],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      onDeviceDiscovered(device.id);
      completer.complete(); // Complete the completer when a device is found
    }, onError: (error) {
      print('Scan error: $error');
      completer.completeError(error); // Complete with error if one occurs
    });
    return completer;
  }


  // TODO: servicesWithCharacteristicsToDiscover: {serviceId: [char1, char2]},
  //       connectionTimeout: const Duration(seconds: 2)
  // TODO: discoverServices?
  void connectToDevice(String deviceId, Function(int) onBatteryLevelRead) {
    flutterReactiveBle.connectToDevice(id: deviceId).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        _onConnected(deviceId, onBatteryLevelRead);
      }
    }, onError: (error) {
      print('Connection error: $error');
    });
  }

  void _onConnected(String deviceId, Function(int) updateState) {
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(DOG_COLLAR_SERVICE),
      characteristicId: Uuid.parse(BATTERY_LEVEL_CHARACTERISTIC_UUID),
    );

    flutterReactiveBle.readCharacteristic(characteristic).then((value) {
      int batteryLevel = value[0]; // Battery level is a single byte
      updateState(batteryLevel);
    }).catchError((error) {
      print('Error reading characteristic: $error');
    });
  }
}
