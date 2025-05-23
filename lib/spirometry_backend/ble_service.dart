import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SensorData {
  double? temperature;
  int? heartRate;
  int? oxygen;
  int? confidence;
  double? differentialVoltage;
  double? airflowLPS;
  double? volumeL;

  SensorData({
    this.temperature,
    this.heartRate,
    this.oxygen,
    this.confidence,
    this.differentialVoltage,
    this.airflowLPS,
    this.volumeL,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['Temperature']?.toDouble(),
      heartRate: json['HeartRate'],
      oxygen: json['Oxygen'],
      confidence: json['Confidence'],
      differentialVoltage: json['DifferentialVoltage']?.toDouble(),
      airflowLPS: json['Airflow']?.toDouble(),
      volumeL: json['Volume']?.toDouble(),
    );
  }
}

class BLEService extends ChangeNotifier {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  SensorData? _sensorData;

  SensorData? get sensorData => _sensorData;

  BLEService() {
    _startScan();
  }

  void _startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'Respirit Device V0.1') {
          _connectToDevice(r.device);
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    _device = device;
    await _device?.connect();
    _discoverServices();
  }

  void _discoverServices() async {
    if (_device == null) return;
    List<BluetoothService> services = await _device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
          _characteristic = c;
          await c.setNotifyValue(true);
          c.value.listen((value) {
            final jsonString = utf8.decode(value);
            final data = json.decode(jsonString);
            _sensorData = SensorData.fromJson(data);
            notifyListeners();
          });
          break;
        }
      }
    }
  }

  void startTest() {
    _sendCommand('START');
  }

  void stopTest() {
    _sendCommand('STOP');
  }

  void _sendCommand(String command) async {
    if (_characteristic == null) return;
    await _characteristic!.write(utf8.encode(command));
  }
}
