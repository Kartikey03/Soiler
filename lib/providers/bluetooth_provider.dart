// lib/providers/bluetooth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class BluetoothProvider extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];
  List<ScanResult> _scanResults = [];

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get devices => _devices;
  List<ScanResult> get scanResults => _scanResults;

  Future<void> requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();
  }

  Future<void> scanDevices() async {
    try {
      await requestPermissions();

      // Check if Bluetooth is available and turned on
      bool isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        print('Bluetooth not available');
        return;
      }

      BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print('Bluetooth is not turned on');
        return;
      }

      _isScanning = true;
      _scanResults.clear();
      _devices.clear();
      notifyListeners();

      // Get system devices (bonded/paired devices) - FIXED: properly await the Future
      List<BluetoothDevice> systemDevices = await FlutterBluePlus.systemDevices([]);
      _devices.addAll(systemDevices);

      // Start scanning for new devices
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        // Add unique devices from scan results
        for (ScanResult result in results) {
          if (!_devices.any((device) => device.remoteId == result.device.remoteId)) {
            _devices.add(result.device);
          }
        }
        notifyListeners();
      });

      // Wait for scan to complete
      await Future.delayed(Duration(seconds: 4));
      await FlutterBluePlus.stopScan();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print('Error scanning devices: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _isConnecting = true;
      notifyListeners();

      await device.connect();
      _connectedDevice = device;
      _isConnected = true;

      // Listen for disconnection
      device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  // Mock data generation for testing without hardware
  Map<String, double> getMockReading() {
    final random = Random();
    return {
      'temperature': 18.0 + (random.nextDouble() * 12), // 18-30°C
      'moisture': 30.0 + (random.nextDouble() * 40), // 30-70%
    };
  }

  Future<Map<String, double>?> getReading() async {
    if (_isConnected && _connectedDevice != null) {
      // TODO: Implement real Bluetooth communication
      // This would involve discovering services and characteristics
      // and reading data from the appropriate characteristic

      try {
        // Discover services (uncomment when implementing real communication)
        List<BluetoothService> services = await _connectedDevice!.discoverServices();
        // Find your specific service and characteristic
        // Read from characteristic and parse the data

        // For now, simulate delay and return mock data
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Error reading from device: $e');
      }
    }

    return getMockReading();
  }
}