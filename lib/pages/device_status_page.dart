import 'package:flutter/material.dart';

class DeviceStatusPage extends StatelessWidget {
  const DeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Status'),
        backgroundColor: const Color(0xFF6B4FA1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
                  child: Text(
          'Device status is not available in this build.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
