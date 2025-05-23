import 'dart:async';
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialDataService {
  final String portName;
  SerialPort? _port;
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _readTimer;

  SerialDataService(this.portName);

  Stream<Map<String, dynamic>> getSerialData() {
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _openPort();
    return _controller!.stream;
  }

  void _openPort() {
    try {
      _port = SerialPort(portName);
      _port!.openReadWrite();
      _port!.config.baudRate = 115200;
      _startReading();
    } catch (e) {
      _controller?.addError('Failed to open port: $e');
      dispose();
    }
  }

  void _startReading() {
    _readTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_port == null || !_port!.isOpen) {
        timer.cancel();
        return;
      }

      try {
        if (_port!.bytesAvailable > 0) {
          final data = _port!.read(_port!.bytesAvailable);
          if (data != null && data.isNotEmpty) {
            final String rawData = utf8.decode(data);
            try {
              final Map<String, dynamic> jsonData = json.decode(rawData);
              _controller?.add(jsonData);
            } catch (e) {
              print('Error parsing JSON: $e');
            }
          }
        }
      } catch (e) {
        print('Error reading from serial port: $e');
        timer.cancel();
        _controller?.addError('Error reading from port: $e');
        dispose();
      }
    });
  }

  void dispose() {
    _readTimer?.cancel();
    _port?.close();
    _port = null;
    _controller?.close();
    _controller = null;
  }
}
