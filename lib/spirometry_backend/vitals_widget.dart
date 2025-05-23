import 'package:flutter/material.dart';

class VitalsWidget extends StatelessWidget {
  final Map<String, dynamic>? sensorData;

  const VitalsWidget({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vital Signs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildVitalRow(
                'Temperature', '${sensorData?['Temperature'] ?? 'N/A'} °C'),
            _buildVitalRow(
                'Heart Rate', '${sensorData?['HeartRate'] ?? 'N/A'} BPM'),
            _buildVitalRow('Oxygen', '${sensorData?['Oxygen'] ?? 'N/A'} %'),
            _buildVitalRow(
                'Confidence', '${sensorData?['Confidence'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text(
              'Flow Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildVitalRow('Differential Voltage',
                '${sensorData?['DifferentialVoltage'] ?? 'N/A'} V'),
            _buildVitalRow('Airflow', '${sensorData?['Airflow'] ?? 'N/A'} L/s'),
            _buildVitalRow('Volume', '${sensorData?['Volume'] ?? 'N/A'} L'),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
