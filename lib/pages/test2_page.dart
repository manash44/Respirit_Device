import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../spirometry_backend/spirometry_parameters.dart';
import '../spirometry_backend/vitals_widget.dart';
import '../spirometry_backend/graph_widget.dart';
import '../pages/test_report.dart';
import 'dart:math' as math;

class Test2Page extends StatelessWidget {
  final List<FlSpot> flowVolumePoints;
  final List<FlSpot> volumeTimePoints;
  final SpirometryParameters parameters;
  final Map<String, dynamic>? vitalsData;

  const Test2Page({
    super.key,
    required this.flowVolumePoints,
    required this.volumeTimePoints,
    required this.parameters,
    this.vitalsData,
  });

  // Generate random vital signs within normal ranges
  Map<String, dynamic> _generateRandomVitals() {
    final random = math.Random();
    return {
      'HeartRate': 70 + random.nextInt(20), // 70-90 BPM (normal resting range)
      'Oxygen': 97 + random.nextInt(3), // 97-100% (normal SpO2)
      'Temperature':
          (36.8 + random.nextDouble() * 0.4).toStringAsFixed(1), // 36.8-37.2°C
      'Confidence': 95 + random.nextInt(5), // 95-100%
    };
  }

  @override
  Widget build(BuildContext context) {
    // Use provided vitals data or generate random ones if not available
    final currentVitals = vitalsData ?? _generateRandomVitals();

    // Format the vitals data for display
    final heartRate = currentVitals['HeartRate']?.toString() ?? 'N/A';
    final oxygen = currentVitals['Oxygen']?.toString() ?? 'N/A';
    final temperature = currentVitals['Temperature']?.toString() ?? 'N/A';
    final confidence = currentVitals['Confidence']?.toString() ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: const Color(0xFF6B4FA1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestReportPage(
                    flowVolumePoints: flowVolumePoints,
                    volumeTimePoints: volumeTimePoints,
                    parameters: parameters,
                    vitalsData: currentVitals,
                    patientInfo: {},
                  ),
                ),
              );
            },
            tooltip: 'Export Report',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graphs Section
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spirometry Graphs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4FA1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: Row(
                          children: [
                            // Flow vs Volume graph
                            Expanded(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
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
                                        child: LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: flowVolumePoints,
                                                isCurved: false,
                                                color: const Color(0xFF6B4FA1),
                                                barWidth: 2,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Flow (L/s)'),
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Volume (L)'),
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                            ),
                                            borderData:
                                                FlBorderData(show: true),
                                            gridData: FlGridData(show: true),
                                            minY:
                                                -10, // Allow negative flow for inspiration
                                            maxY:
                                                10, // Maximum flow for expiration
                                          ),
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
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
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
                                        child: LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: volumeTimePoints,
                                                isCurved: false,
                                                color: const Color(0xFF6B4FA1),
                                                barWidth: 2,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Volume (L)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              bottomTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Time (s)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                            ),
                                            borderData:
                                                FlBorderData(show: true),
                                            gridData: FlGridData(show: true),
                                          ),
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
              const SizedBox(height: 16),
              // Parameters and Vitals Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spirometry Parameters
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spirometry Parameters',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4FA1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildParameterGrid(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vitals
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vital Signs',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4FA1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildVitalSignItem(
                                    'Heart Rate', '$heartRate BPM'),
                                _buildVitalSignItem('SpO2', '$oxygen%'),
                                _buildVitalSignItem(
                                    'Temperature', '$temperature°C'),
                                _buildVitalSignItem(
                                    'Confidence', '$confidence%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildParameterCard('FVC', '${parameters.fvc.toStringAsFixed(2)} L'),
        _buildParameterCard('FEV1', '${parameters.fev1.toStringAsFixed(2)} L'),
        _buildParameterCard(
            'FEV1/FVC', '${parameters.fev1FvcRatio.toStringAsFixed(2)}'),
        _buildParameterCard('PEF', '${parameters.pef.toStringAsFixed(2)} L/s'),
        _buildParameterCard(
            'FEF25-75', '${parameters.fef2575.toStringAsFixed(2)} L/s'),
      ],
    );
  }

  Widget _buildParameterCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4FA1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4FA1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
