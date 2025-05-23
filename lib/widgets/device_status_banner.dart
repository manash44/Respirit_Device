import 'package:flutter/material.dart';

class DeviceStatusBanner extends StatelessWidget {
  const DeviceStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey,
      child: const Row(
        children: [
          Icon(Icons.device_unknown, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Device status not available in this build.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
