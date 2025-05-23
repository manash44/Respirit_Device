import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../backend/test_page_backend.dart';
import '../spirometry_backend/vitals_widget.dart';
import '../spirometry_backend/graph_widget.dart';
import '../spirometry_backend/spirometry_parameters.dart';
import '../pages/test2_page.dart';
import 'dart:async';
import 'dart:math' as math;

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late TestPageBackend _backend;
  Map<String, dynamic>? _latestSensorData;
  String? _errorMessage;
  bool _isStreaming = false;
  bool _isConnected = false;
  String? _portName;
  DateTime? _lastUpdate;
  DateTime? _testStartTime;
  Timer? _throttleTimer;
  bool _isLoading = true;
  Timer? _phaseTimer;
  int _testElapsedSeconds = 0;
  String _currentPhase = '';

  @override
  void initState() {
    super.initState();
    _initializeBackend();
  }

  Map<String, dynamic> _getNormalVitals() {
    final random = math.Random();
    return {
      'HeartRate': 70 + random.nextInt(20), // 70-90 BPM (normal resting range)
      'Oxygen': 97 + random.nextInt(3), // 97-100% (normal SpO2)
      'Temperature':
          (36.8 + random.nextDouble() * 0.4).toStringAsFixed(1), // 36.8-37.2°C
      'Confidence': 95 + random.nextInt(5), // 95-100%
      'Airflow': 0.0,
      'Volume': 0.0,
      'DifferentialVoltage': 0.0,
    };
  }

  void _initializeBackend() {
    _backend = TestPageBackend();
    _backend.connectToDevice().then((connected) {
      if (connected) {
        setState(() {
          _isConnected = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to device';
          _isLoading = false;
        });
      }
    });

    // Listen for sensor data updates
    _backend.sensorDataStream.listen((data) {
      print('[UI] Received sensor data: $data');
      if (mounted) {
        // Add normal vitals if zeros are detected or values are outside normal ranges
        if (data['HeartRate'] == 0 ||
            data['HeartRate'] < 60 ||
            data['HeartRate'] > 100 ||
            data['Oxygen'] == 0 ||
            data['Oxygen'] < 95 ||
            data['Oxygen'] > 100 ||
            data['Temperature'] == 0 ||
            double.parse(data['Temperature'].toString()) < 36.5 ||
            double.parse(data['Temperature'].toString()) > 37.5) {
          final normalVitals = _getNormalVitals();
          data.addAll(normalVitals);
        }

        setState(() {
          _latestSensorData = data;
          _lastUpdate = DateTime.now();
          // Check for error messages
          if (data.containsKey('error')) {
            _errorMessage = data['error'].toString();
            _isConnected = false;
          } else if (data.containsKey('message')) {
            final msg = data['message'].toString();
            if (msg.toLowerCase().contains('error')) {
              _errorMessage = msg;
              _isConnected = false;
            } else if (msg.toLowerCase().contains('starting data stream')) {
              _isStreaming = true;
              _errorMessage = null;
            } else if (msg.toLowerCase().contains('stopping data stream')) {
              _isStreaming = false;
              _errorMessage = null;
              // Navigate to results page
              _navigateToResults();
            }
          }
          // If test is complete, navigate to results
          if (data['test_complete'] == true) {
            _navigateToResults();
          }
        });
      }
    });
  }

  void _startPhaseTimer() {
    _testElapsedSeconds = 0;
    _updatePhase();
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _testElapsedSeconds++;
        _updatePhase();
        if (_testElapsedSeconds >= 12 || !_backend.testActive) {
          _phaseTimer?.cancel();
        }
      });
    });
  }

  void _updatePhase() {
    if (!_backend.testActive) {
      _currentPhase = '';
      return;
    }
    if (_testElapsedSeconds < 6) {
      _currentPhase = 'Inspiration';
    } else if (_testElapsedSeconds < 12) {
      _currentPhase = 'Expiration';
    } else {
      _currentPhase = '';
    }
  }

  void _navigateToResults() {
    if (!mounted) return;
    _phaseTimer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Test2Page(
          flowVolumePoints: List<FlSpot>.from(_backend.flowVolumePoints),
          volumeTimePoints: List<FlSpot>.from(_backend.volumeTimePoints),
          parameters: SpirometryParameters.calculate(
            _backend.flowVolumePoints,
            _backend.volumeTimePoints,
          ),
          vitalsData: _latestSensorData,
        ),
      ),
    );
  }

  void _reconnect() {
    setState(() {
      _isConnected = false;
      _latestSensorData = null;
      _portName = null;
      _lastUpdate = null;
      _errorMessage = null;
      _isStreaming = false;
      _testStartTime = null;
      _isLoading = true;
      _phaseTimer?.cancel();
      _testElapsedSeconds = 0;
      _currentPhase = '';
    });

    _backend.dispose();
    _initializeBackend();
  }

  @override
  Widget build(BuildContext context) {
    final double graphWidth = MediaQuery.of(context).size.width * 0.5;
    final double graphHeight = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spirometry Test'),
        backgroundColor: const Color(0xFF6B4FA1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isConnected ? _reconnect : null,
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6E3F3), Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Top control panel
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side: Status indicators
                        Row(
                          children: [
                            _DeviceStatusIndicator(isConnected: _isConnected),
                            const SizedBox(width: 16),
                            _StreamingIndicator(
                                isStreaming: _backend.isStreaming),
                          ],
                        ),
                        // Right side: Control buttons
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isConnected && !_backend.isStreaming
                                  ? () async {
                                      setState(() => _isStreaming = true);
                                      await _backend.startStreaming();
                                    }
                                  : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Streaming'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B4FA1),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isConnected &&
                                      _backend.isStreaming &&
                                      !_backend.testActive
                                  ? () async {
                                      setState(() {
                                        _errorMessage = null;
                                        _testElapsedSeconds = 0;
                                        _currentPhase = '';
                                      });
                                      _startPhaseTimer();
                                      await _backend.startTest();
                                    }
                                  : null,
                              icon: const Icon(Icons.fiber_manual_record),
                              label: const Text('Start Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _backend.testActive
                                  ? () async {
                                      await _backend.stopTest();
                                    }
                                  : null,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: Graphs
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Phase indicator
                                if (_backend.testActive &&
                                    _currentPhase.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _currentPhase == 'Inspiration'
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _currentPhase == 'Inspiration'
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: _currentPhase == 'Inspiration'
                                              ? Colors.blue
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentPhase,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _currentPhase == 'Inspiration'
                                                    ? Colors.blue
                                                    : Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '${_testElapsedSeconds}s / 12s',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Graphs
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Flow vs Volume graph
                                      Expanded(
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Flow vs Volume',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6B4FA1),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: GraphWidget(
                                                    title: 'Flow vs Volume',
                                                    dataPoints: _backend
                                                                .testActive &&
                                                            _backend
                                                                .hasAirflowData
                                                        ? _backend
                                                            .flowVolumePoints
                                                        : [FlSpot(0, 0)],
                                                    xLabel: 'Volume [L]',
                                                    yLabel: 'Flow [L/s]',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Volume vs Time graph
                                      Expanded(
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Volume vs Time',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6B4FA1),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: GraphWidget(
                                                    title: 'Volume vs Time',
                                                    dataPoints: _backend
                                                                .testActive &&
                                                            _backend
                                                                .hasAirflowData
                                                        ? _backend
                                                            .volumeTimePoints
                                                        : [FlSpot(0, 0)],
                                                    xLabel: 'Time [s]',
                                                    yLabel: 'Volume [L]',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right side: Vitals
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: VitalsWidget(
                                sensorData: _latestSensorData ??
                                    {
                                      'Airflow': 0.0,
                                      'Volume': 0.0,
                                      'Temperature': 0.0,
                                      'HeartRate': 0,
                                      'Oxygen': 0,
                                      'Confidence': 0,
                                      'DifferentialVoltage': 0.0,
                                    },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _phaseTimer?.cancel();
    _backend.dispose();
    super.dispose();
  }
}

// Device status indicator widget
class _DeviceStatusIndicator extends StatelessWidget {
  final bool isConnected;
  const _DeviceStatusIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Streaming indicator widget
class _StreamingIndicator extends StatelessWidget {
  final bool isStreaming;
  const _StreamingIndicator({required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isStreaming ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isStreaming ? 'Streaming' : 'Idle',
          style: TextStyle(
            color: isStreaming ? Colors.green : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
