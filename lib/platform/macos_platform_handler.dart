import 'package:flutter/services.dart';

class MacOSPlatformHandler {
  static const MethodChannel _channel =
      MethodChannel('com.respirit.device/macos');

  static Future<bool> checkBluetoothPermission() async {
    try {
      final bool result =
          await _channel.invokeMethod('checkBluetoothPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking Bluetooth permission: ${e.message}');
      return false;
    }
  }

  static Future<bool> requestBluetoothPermission() async {
    try {
      final bool result =
          await _channel.invokeMethod('requestBluetoothPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting Bluetooth permission: ${e.message}');
      return false;
    }
  }

  static Future<bool> checkNetworkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkNetworkPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error checking network permission: ${e.message}');
      return false;
    }
  }

  static Future<bool> requestNetworkPermission() async {
    try {
      final bool result =
          await _channel.invokeMethod('requestNetworkPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error requesting network permission: ${e.message}');
      return false;
    }
  }

  static Future<void> showNativeAlert({
    required String title,
    required String message,
    String? positiveButton,
    String? negativeButton,
  }) async {
    try {
      await _channel.invokeMethod('showAlert', {
        'title': title,
        'message': message,
        'positiveButton': positiveButton,
        'negativeButton': negativeButton,
      });
    } on PlatformException catch (e) {
      print('Error showing native alert: ${e.message}');
    }
  }

  static Future<void> saveFile({
    required String fileName,
    required List<int> data,
  }) async {
    try {
      await _channel.invokeMethod('saveFile', {
        'fileName': fileName,
        'data': data,
      });
    } on PlatformException catch (e) {
      print('Error saving file: ${e.message}');
    }
  }
}
