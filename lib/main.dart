import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
// import 'services/platform_service.dart';
import 'pages/splash_screen.dart';
import 'pages/patients_page.dart';
import 'pages/AddPatientPage.dart';
import 'pages/EditPatientPage.dart';
import 'pages/test_page.dart';
import 'pages/main_menu.dart';
import 'pages/device_status_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove macOS permission checks and PlatformService usage
  runApp(const RespiritApp());
}

class RespiritApp extends StatelessWidget {
  const RespiritApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Respirit Device App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/main-menu': (context) => const MainMenu(),
        '/patients': (context) => const PatientsPage(),
        '/add-patient': (context) => const AddPatientPage(patientId: 'new'),
        '/edit-patient': (context) => EditPatientPage(
              patientId: '',
              initialData: const {},
            ),
      },
    );
  }
}
