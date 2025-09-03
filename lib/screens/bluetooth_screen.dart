// lib/screens/bluetooth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothProvider>().scanDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return IconButton(
                icon: bluetoothProvider.isScanning
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.refresh),
                onPressed: bluetoothProvider.isScanning
                    ? null
                    : () => bluetoothProvider.scanDevices(),
              );
            },
          ),
        ],
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          if (bluetoothProvider.isScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for devices...'),
                ],
              ),
            );
          }

          if (bluetoothProvider.devices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No devices found'),
                  SizedBox(height: 8),
                  Text('Make sure Bluetooth is enabled and devices are nearby'),
                  SizedBox(height: 16),
                  Text('Pull down to refresh'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bluetoothProvider.scanDevices(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bluetoothProvider.devices.length,
              itemBuilder: (context, index) {
                final device = bluetoothProvider.devices[index];
                final deviceName = device.platformName.isNotEmpty
                    ? device.platformName
                    : 'Unknown Device';

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bluetooth, color: Colors.blue),
                    title: Text(deviceName),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: bluetoothProvider.isConnecting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () => _connectToDevice(device, bluetoothProvider),
                      child: const Text('Connect'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _connectToDevice(device, BluetoothProvider bluetoothProvider) async {
    final success = await bluetoothProvider.connectToDevice(device);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connected successfully!' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }
}