<<<<<<< HEAD
# Respirit Device App

A Flutter application for monitoring and controlling the Respirit device, which uses an ESP32 Pico D4 development board.

## Features

- Connect to Respirit device via:
  - WiFi (direct or through public networks)
  - Bluetooth Low Energy (BLE)
  - Serial Port (USB)
- Real-time sensor data monitoring:
  - Temperature
  - Airflow
  - Heart Rate
  - Blood Oxygen
  - Sensor Confidence
- Device management:
  - Sensor calibration
  - Continuous monitoring
  - Device discovery
  - Connection management

## Backend Architecture

The backend is organized into several key components:

### 1. Device Connection Manager (`device_connection_manager.dart`)

Handles all connection-related operations:
- WiFi connection via WebSocket
- Bluetooth connection via BLE
- Serial port connection
- Connection state management
- Automatic reconnection
- Data streaming

### 2. Device Data Model (`device_data.dart`)

Defines the data structures for:
- Sensor readings
- Device status
- Connected devices

### 3. Device Discovery Service (`device_discovery_service.dart`)

Manages device discovery:
- WiFi network scanning
- Bluetooth device scanning
- Serial port detection
- Device information collection

### 4. Device Controller (`device_controller.dart`)

High-level device operations:
- Connection management
- Sensor calibration
- Monitoring control
- Command sending

## Setup

1. Add the required dependencies to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_blue_plus: ^1.31.15
  libserialport: ^0.4.0
  web_socket_channel: ^2.4.0
  network_info_plus: ^4.1.0
```

2. For Android, add the following permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

3. For iOS, add the following to `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth permission to connect to Respirit device</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need Bluetooth permission to connect to Respirit device</string>
<key>NSLocalNetworkUsageDescription</key>
<string>Need local network permission to discover Respirit devices</string>
```

## Usage

1. Initialize the device controller:
```dart
final deviceController = DeviceController();
```

2. Start device discovery:
```dart
final discoveryService = DeviceDiscoveryService();
discoveryService.startScanning();
discoveryService.discoveredDevices.listen((devices) {
  // Handle discovered devices
});
```

3. Connect to a device:
```dart
await deviceController.connectToDevice(deviceAddress, connectionType);
```

4. Listen for sensor data:
```dart
deviceController.dataStream.listen((data) {
  // Handle sensor data
  print('Temperature: ${data.temperature}°C');
  print('Airflow: ${data.airflow} L/s');
  print('Heart Rate: ${data.heartRate} BPM');
  print('Oxygen: ${data.oxygen}%');
  print('Confidence: ${data.confidence}%');
});
```

5. Control device operations:
```dart
// Start calibration
await deviceController.startCalibration();

// Start monitoring
await deviceController.startMonitoring();

// Stop monitoring
await deviceController.stopMonitoring();

// Disconnect
await deviceController.disconnect();
```

## Error Handling

The backend includes automatic error handling and reconnection:
- Connection errors trigger automatic reconnection attempts
- Data parsing errors are logged and handled gracefully
- Connection state changes are broadcast through streams

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
=======
# Respirit_Device
RespiritDeviceapp
>>>>>>> e178b2e4c249d6ae6effeab48c7e91e630722332
