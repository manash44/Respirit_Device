import 'package:flutter/material.dart' hide ConnectionState;
import 'patients_page.dart';
import 'test_page.dart';
import 'wifi_connection_page.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../widgets/hover_button.dart';
import '../widgets/device_status_banner.dart';
import 'device_status_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E3F3),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Logo and Company Name at the very top
          Column(
            children: [
              Image.asset(
                'assets/images/respirit.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                'Respirit Healthcare Pvt Ltd',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4FA1),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Centered Menu Buttons
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuItem(
                    context: context,
                    title: 'Patients',
                    icon: Icons.people,
                    onTap: () => Navigator.pushNamed(context, '/patients'),
                    color: const Color(0xFF6B4FA1),
                  ),
                  const SizedBox(width: 24.0),
                  _buildMenuItem(
                    context: context,
                    title: 'Test',
                    icon: Icons.medical_services,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestPage(),
                      ),
                    ),
                    color: const Color(0xFF6B4FA1),
                  ),
                  const SizedBox(width: 24.0),
                  _buildMenuItem(
                    context: context,
                    title: 'History',
                    icon: Icons.folder,
                    onTap: () {},
                    color: const Color(0xFF6B4FA1),
                  ),
                  const SizedBox(width: 24.0),
                  _buildMenuItem(
                    context: context,
                    title: 'Utilities',
                    icon: Icons.build,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WifiConnectionPage(),
                      ),
                    ),
                    color: const Color(0xFF6B4FA1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36.0, color: color),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
