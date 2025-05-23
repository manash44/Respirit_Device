import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

const String apiKey = "respirit001device2025";
const int serialBaudRate = 115200;
const List<String> preferredPorts = ["COM5", "COM6"];

class Esp32SerialCommunicator {
  final String _serialPortName;
  final int _baudRate;
  final String apiKey;
  SerialPort? _serialPort;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _readerSub;
  StreamController<String> _responseStreamController =
      StreamController.broadcast();
  bool _apiKeyVerifiedForSession = false;
  bool _isDisposed = false;
  bool _sessionAuthenticated = false;
  String? _lastCommand;

  Stream<String> get responseStream => _responseStreamController.stream;

  Esp32SerialCommunicator(this._serialPortName, this._baudRate,
      {required this.apiKey});

  Future<bool> connect() async {
    try {
      if (_isDisposed) return false;
      print('[Serial] Attempting to open port: $_serialPortName');
      _serialPort = SerialPort(_serialPortName);
      if (!_serialPort!.openReadWrite()) {
        print('[Serial] Failed to open serial port: $_serialPortName');
        return false;
      }
      _serialPort!.config.baudRate = _baudRate;
      print('[Serial] Port $_serialPortName opened at $_baudRate baud.');
      _startSerialListener();
      _apiKeyVerifiedForSession = false;
      _sessionAuthenticated = false;
      return true;
    } catch (e) {
      print('[Serial] Error connecting to serial port: $e');
      await _cleanup();
      return false;
    }
  }

  void _startSerialListener() {
    if (_isDisposed || _serialPort == null || !_serialPort!.isOpen) return;
    try {
      _reader = SerialPortReader(_serialPort!);
      _readerSub = _reader!.stream.listen(
        (data) {
          if (_isDisposed) return;
          final line = String.fromCharCodes(data).trim();
          print('[Serial] RAW: $line');
          if (line.isNotEmpty) {
            _responseStreamController.add(line);
          }
        },
        onError: (error) {
          if (!_isDisposed) {
            print('[Serial] Serial port read error: $error');
            _responseStreamController.addError(error);
          }
        },
      );
    } catch (e) {
      print('[Serial] Error starting serial listener: $e');
      _responseStreamController.addError(e);
    }
  }

  Future<void> sendCommand(String command) async {
    if (_isDisposed || _serialPort == null || !_serialPort!.isOpen) {
      print('[Serial] sendCommand: serial port not open or disposed');
      return;
    }
    try {
      String commandToSend = '$apiKey,$command';
      print('[Serial] Sending command: $commandToSend');
      _lastCommand = command;
      _serialPort!.write(Uint8List.fromList(utf8.encode('$commandToSend\n')));
    } catch (e) {
      if (!_isDisposed) {
        print('[Serial] Error sending command: $e');
        _responseStreamController.addError(e);
      }
    }
  }

  Future<void> _cleanup() async {
    try {
      _readerSub?.cancel();
      _readerSub = null;
      _reader = null;
      if (_serialPort != null) {
        if (_serialPort!.isOpen) {
          _serialPort!.close();
        }
        _serialPort = null;
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  Future<void> disconnect() async {
    _isDisposed = true;
    await _cleanup();
    if (!_responseStreamController.isClosed) {
      _responseStreamController.close();
    }
    _apiKeyVerifiedForSession = false;
  }
}

class TestPageBackend {
  final StreamController<Map<String, dynamic>> _sensorDataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get sensorDataStream =>
      _sensorDataStreamController.stream;

  bool _isStreaming = false;
  bool _isDisposed = false;
  Timer? _testTimer;
  int _testPhase = 0;
  String _jsonBuffer = '';
  Esp32SerialCommunicator? _communicator;
  final List<FlSpot> _flowVolumePoints = [];
  final List<FlSpot> _volumeTimePoints = [];
  DateTime? _startTime;
  bool _testActive = false;
  bool _hasAirflowData = false;

  TestPageBackend();

  Future<bool> connectToDevice(
      {List<String>? apiKeys, List<String>? preferredPorts}) async {
    final ports = SerialPort.availablePorts;
    if (ports.isEmpty) {
      print('[Backend] No serial ports found!');
    }
    final tryPorts = preferredPorts ?? ports;
    final keys = apiKeys ?? ["respirit001device2025", "respirit002device2025"];
    print('[Backend] Detected available ports: $ports');
    print('[Backend] Trying ports: $tryPorts');
    for (final portName in tryPorts) {
      for (final apiKey in keys) {
        final communicator =
            Esp32SerialCommunicator(portName, serialBaudRate, apiKey: apiKey);
        final connected = await communicator.connect();
        if (!connected) continue;

        // Handshake: send HELLO and wait for valid response
        bool handshakeOk = false;
        final handshakeCompleter = Completer<bool>();
        late StreamSubscription sub;
        sub = communicator.responseStream.listen((line) {
          print('[Backend] Handshake response: $line');
          if (line.contains('{') && line.contains('}')) {
            if (!handshakeCompleter.isCompleted)
              handshakeCompleter.complete(true);
          } else if (line.contains('ESP32') ||
              line.contains('Pico D4') ||
              line.contains('API') ||
              line.contains('connected') ||
              line.contains('key') ||
              line.contains('OK') ||
              line.contains('wired_connected') ||
              line.contains('Bio Sensor Hub') ||
              line.contains('authenticated')) {
            if (!handshakeCompleter.isCompleted)
              handshakeCompleter.complete(true);
          }
        });
        await communicator.sendCommand('HELLO');
        handshakeOk = await handshakeCompleter.future
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        await sub.cancel();

        if (handshakeOk) {
          _communicator = communicator;
          _startTime = DateTime.now();
          // Set up streaming listener (keep port open)
          _jsonBuffer = '';
          _communicator!.responseStream.listen((line) {
            print('[Backend] Streaming: $line');
            try {
              _jsonBuffer += line;
              // Try to extract complete JSON objects
              while (_jsonBuffer.contains('{') && _jsonBuffer.contains('}')) {
                final jsonStart = _jsonBuffer.indexOf('{');
                final jsonEnd = _jsonBuffer.indexOf('}', jsonStart);
                if (jsonEnd == -1) break;
                final jsonString =
                    _jsonBuffer.substring(jsonStart, jsonEnd + 1);
                _jsonBuffer = _jsonBuffer.substring(jsonEnd + 1);
                try {
                  final data = json.decode(jsonString);
                  if (data is Map<String, dynamic>) {
                    print('[Backend] Forwarding to UI: $data');
                    _processSensorData(data);
                    _safeAddToStream(data);
                    if (data.containsKey('Airflow') && data['Airflow'] != 0.0) {
                      _hasAirflowData = true;
                    }
                  }
                } catch (e) {
                  print('[Backend] Error parsing sensor data: $e');
                }
              }
            } catch (e) {
              print('[Backend] Error in streaming buffer logic: $e');
            }
          });
          return true;
        } else {
          await communicator.disconnect();
        }
      }
    }
    return false;
  }

  Future<void> sendCommand(String command) async {
    await _communicator?.sendCommand(command);
  }

  Future<void> startStreaming() async {
    if (_isStreaming || _isDisposed) return;
    _isStreaming = true;
    await sendCommand('START_DATA');
  }

  Future<void> stopStreaming() async {
    if (!_isStreaming || _isDisposed) return;
    _isStreaming = false;
    await sendCommand('STOP_DATA');
  }

  Future<void> startTest() async {
    if (_testActive || _isDisposed) return;
    _testActive = true;
    _hasAirflowData = false;
    _flowVolumePoints.clear();
    _volumeTimePoints.clear();
    _startTime = DateTime.now();
    // Zero the graphs until airflow data is received
    _safeAddToStream({
      'Airflow': 0.0,
      'Volume': 0.0,
      'Temperature': 0.0,
      'HeartRate': 0,
      'Oxygen': 0,
      'Confidence': 0,
      'DifferentialVoltage': 0.0,
    });
    // Start streaming if not already
    if (!_isStreaming) await startStreaming();
    // Start 12s timer (6s inspiration, 6s expiration)
    _testTimer?.cancel();
    _testTimer = Timer(const Duration(seconds: 12), () async {
      await stopTest();
    });
  }

  Future<void> stopTest() async {
    if (!_testActive || _isDisposed) return;
    _testActive = false;
    _testTimer?.cancel();
    await stopStreaming();
    // Notify UI to navigate to results (UI should listen for _testActive=false)
    _safeAddToStream({'test_complete': true});
  }

  void _processSensorData(Map<String, dynamic> sensorData) {
    if (sensorData.containsKey('Airflow') && sensorData.containsKey('Volume')) {
      final flow = sensorData['Airflow'] != null
          ? (sensorData['Airflow'] as num).toDouble()
          : 0.0;
      final volume = sensorData['Volume'] != null
          ? (sensorData['Volume'] as num).toDouble()
          : 0.0;
      final time = DateTime.now()
              .difference(_startTime ?? DateTime.now())
              .inMilliseconds /
          1000.0;
      if (!flow.isNaN && !volume.isNaN && _testActive) {
        _flowVolumePoints.add(FlSpot(volume, flow));
        _volumeTimePoints.add(FlSpot(time, volume));
        if (_flowVolumePoints.length > 1000) _flowVolumePoints.removeAt(0);
        if (_volumeTimePoints.length > 1000) _volumeTimePoints.removeAt(0);
      }
    }
  }

  void _safeAddToStream(Map<String, dynamic> data) {
    if (!_sensorDataStreamController.isClosed) {
      _sensorDataStreamController.add(data);
    }
  }

  void dispose() {
    _isDisposed = true;
    _testTimer?.cancel();
    _communicator?.disconnect();
    if (!_sensorDataStreamController.isClosed) {
      _sensorDataStreamController.close();
    }
  }

  List<FlSpot> get flowVolumePoints => _flowVolumePoints;
  List<FlSpot> get volumeTimePoints => _volumeTimePoints;
  bool get isStreaming => _isStreaming;
  bool get testActive => _testActive;
  bool get hasAirflowData => _hasAirflowData;
}
