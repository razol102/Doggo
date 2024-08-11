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
  static const DISTANCE_SERVICE_UUID = '0000181A-0000-1000-8000-00805f9b34fb';
  static const DISTANCE_CHARACTERISTIC_UUID = '00002A76-0000-1000-8000-00805f9b34fb';

  Timer? _timer;
  int _batteryLevel = 0;
  int _stepCount = 0;
  double _distance = 0.0;
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

  void connectToDevice(String deviceId, Function(int) onBatteryLevelRead, Function(int) onStepCountRead, Function(double) onDistanceRead) {
    _deviceId = deviceId;
    flutterReactiveBle.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 5),
    ).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Connected, discovering services...');
        isConnected = true;
        flutterReactiveBle.discoverServices(deviceId).then((_) {
          print('Services discovered');
          _onConnected(deviceId, onBatteryLevelRead, onStepCountRead, onDistanceRead);
          _startPeriodicUpdates();
        }).catchError((error) {
          print('Error discovering services: $error');
          isConnected = false;
        });
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        isConnected = false;
        _timer?.cancel();
      }
    }, onError: (error) {
      print('Connection error: $error');
      isConnected = false;
    });
  }

  void _onConnected(String deviceId, Function(int) updateBatteryLevel, Function(int) updateStepCount, Function(double) updateDistance) {
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

    final distanceCharacteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: Uuid.parse(DISTANCE_SERVICE_UUID),
      characteristicId: Uuid.parse(DISTANCE_CHARACTERISTIC_UUID),
    );


    _readAndSendCharacteristics(batteryCharacteristic, stepCharacteristic, distanceCharacteristic
        ,updateBatteryLevel, updateStepCount, updateDistance);
  }

  Future<void> _readAndSendCharacteristics(
      QualifiedCharacteristic batteryCharacteristic,
      QualifiedCharacteristic stepCharacteristic,
      QualifiedCharacteristic distanceCharacteristic,
      Function(int) updateBatteryLevel,
      Function(int) updateStepCount,
      Function(double) updateDistance,

      ) async {

    int? _dogId = await PreferencesService.getDogId();

    flutterReactiveBle.readCharacteristic(batteryCharacteristic).then((value) {
      print('Battery value: $value');
      _batteryLevel = value[0];
      updateBatteryLevel(_batteryLevel);
      //HttpService.sendBatteryLevelToBackend(_deviceId, _batteryLevel);
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

    flutterReactiveBle.readCharacteristic(distanceCharacteristic).then((value) {
      print('Distance value: $value');
      _distance = _bytesToFloat(value);
      updateDistance(_distance);
      print(_distance);
      HttpService.sendDistanceToBackend(_dogId!.toString(), _distance);
    }).catchError((error) {
      print('Error reading distance characteristic: $error');
    });
  }

  void _startPeriodicUpdates() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) { // TODO: Change the duration if needed
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

        final distanceCharacteristic = QualifiedCharacteristic(
          deviceId: _deviceId,
          serviceId: Uuid.parse(DISTANCE_SERVICE_UUID),
          characteristicId: Uuid.parse(DISTANCE_CHARACTERISTIC_UUID),
        );

        _readAndSendCharacteristics(batteryCharacteristic, stepCharacteristic, distanceCharacteristic,
                (batteryLevel) { _batteryLevel = batteryLevel;},
                (stepCount) { _stepCount = stepCount;},
                (distance) {_distance = distance;});
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

  void resetService() {
    disconnectFromDevice();
    _batteryLevel = 0;
    _stepCount = 0;
  }

  int _bytesToInt(List<int> bytes) {
    return ByteData.sublistView(Uint8List.fromList(bytes)).getInt32(0, Endian.little);
  }

  double _bytesToFloat(List<int> bytes) {
    var buffer = Uint8List.fromList(bytes).buffer;
    return ByteData.view(buffer).getFloat32(0, Endian.little);
  }
}
