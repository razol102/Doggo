import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mobile/services/preferences_service.dart';
import 'http_service.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  static const BATTERY_SERVICE_UUID = '0000180F-0000-1000-8000-00805f9b34fb';
  static const BATTERY_LEVEL_CHARACTERISTIC_UUID = '00002A19-0000-1000-8000-00805f9b34fb';

  static const STEP_SERVICE_UUID = '0000180D-0000-1000-8000-00805f9b34fb';
  static const STEP_COUNT_CHARACTERISTIC_UUID = '00002A37-0000-1000-8000-00805f9b34fb';

  Timer? _timer;
  int _batteryLevel = 0;
  int _stepCount = 0;
  String _deviceId = '';
  bool isConnected = false;

  Completer<void>? _scanCompleter;

  Future<void> startScan(Function(DiscoveredDevice) onDeviceDiscovered) async {
    _scanCompleter = Completer<void>();
    flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.name == "DoggoCollar") {
        if (!_scanCompleter!.isCompleted) {
          onDeviceDiscovered(device);
          _scanCompleter!.complete();
        }
      }
    }, onError: (error) {
      print('Scan error: $error');
      if (!_scanCompleter!.isCompleted) {
        _scanCompleter!.completeError(error);
      }
    });
    return _scanCompleter!.future;
  }

  void connectToDevice(String deviceId, Function(int) onBatteryLevelRead, Function(int) onStepCountRead,
      Function() onDeviceDisconnected) {
    _deviceId = deviceId;
    flutterReactiveBle.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 30),
    ).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Connected, discovering services...');
        isConnected = true;
        flutterReactiveBle.discoverServices(deviceId).then((_) {
          print('Services discovered');
          _onConnected(deviceId, onBatteryLevelRead, onStepCountRead
          );
          _startPeriodicUpdates();
        }).catchError((error) {
          print('Error discovering services: $error');
          isConnected = false;
          onDeviceDisconnected(); // Notify disconnection
        });
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        isConnected = false;
        _timer?.cancel();
        onDeviceDisconnected(); // Notify disconnection
      }
    }, onError: (error) {
      print('Connection error: $error');
      isConnected = false;
      onDeviceDisconnected(); // Notify disconnection
    });
  }

  void _onConnected(
      String deviceId,
      Function(int) updateBatteryLevel,
      Function(int) updateStepCount) {
    print('Attempting to read characteristics...');
    final batteryCharacteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(BATTERY_SERVICE_UUID),
      characteristicId: Uuid.parse(BATTERY_LEVEL_CHARACTERISTIC_UUID),
    );

    final stepCharacteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(STEP_SERVICE_UUID),
      characteristicId: Uuid.parse(STEP_COUNT_CHARACTERISTIC_UUID),
    );

    _readAndSendCharacteristics(
        batteryCharacteristic, stepCharacteristic,updateBatteryLevel, updateStepCount);
  }

  Future<void> _readAndSendCharacteristics(
      QualifiedCharacteristic batteryCharacteristic,
      QualifiedCharacteristic stepCharacteristic,
      Function(int) updateBatteryLevel,
      Function(int) updateStepCount,
      ) async {

    int? _dogId = await PreferencesService.getDogId();

    flutterReactiveBle.readCharacteristic(batteryCharacteristic).then((value) {
      print('Battery value: $value');
      _batteryLevel = value[0];
      updateBatteryLevel(_batteryLevel);
      HttpService.sendBatteryLevelToBackend(_dogId!.toString(), _batteryLevel);
    }).catchError((error) {
      print('Error reading battery characteristic: $error');
    });

    flutterReactiveBle.readCharacteristic(stepCharacteristic).then((value) {
      print('Step value: $value');
      _stepCount = _bytesToInt(value);
      updateStepCount(_stepCount);
      HttpService.sendStepCountToBackend(_dogId!.toString(), _stepCount);
    }).catchError((error) {
      print('Error reading step characteristic: $error');
    });

      }

  void _startPeriodicUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) { // TODO: Change the duration if needed
      if (_deviceId.isNotEmpty && isConnected) {
        final batteryCharacteristic = QualifiedCharacteristic(
          deviceId: _deviceId,
          serviceId: Uuid.parse(BATTERY_SERVICE_UUID),
          characteristicId: Uuid.parse(BATTERY_LEVEL_CHARACTERISTIC_UUID),
        );

        final stepCharacteristic = QualifiedCharacteristic(
          deviceId: _deviceId,
          serviceId: Uuid.parse(STEP_SERVICE_UUID),
          characteristicId: Uuid.parse(STEP_COUNT_CHARACTERISTIC_UUID),
        );

        _readAndSendCharacteristics(batteryCharacteristic, stepCharacteristic,
                (batteryLevel) { _batteryLevel = batteryLevel; },
                (stepCount) { _stepCount = stepCount; },
                );
      }
    });
    }

  void disconnectFromDevice() {
    if (_deviceId.isNotEmpty) {
      flutterReactiveBle.deinitialize();
      _timer?.cancel();
      isConnected = false;
      _deviceId = '';
    }
  }

  void stopScan() {
    flutterReactiveBle.deinitialize();
  }

  void disconnect() {
    flutterReactiveBle.deinitialize();
    _timer?.cancel();
    isConnected = false;
  }

  void resetService() {
    disconnectFromDevice();
    _batteryLevel = 0;
    _stepCount = 0;
  }

  int _bytesToInt(List<int> bytes) {
    return ByteData.sublistView(Uint8List.fromList(bytes)).getInt32(0, Endian.little);
  }

}
