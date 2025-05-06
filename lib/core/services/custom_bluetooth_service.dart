// lib/core/services/bluetooth_service.dart
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert'; // For utf8.encode
import 'package:flutter/material.dart'; // For ValueNotifier
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Define your ESP32's specific UUIDs here
const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
const String TARGET_DEVICE_NAME =
    "ESP32-C3-BLE"; // Use the name from your ESP32 code

class CustomBluetoothService {
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // Use ValueNotifier for simple state exposure to UI
  ValueNotifier<bool> isConnected = ValueNotifier(false);
  ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  ValueNotifier<bool> isScanning = ValueNotifier(false);

  // --- Scanning ---
  Future<void> startScan() async {
    // TODO: Request Bluetooth/Location permissions first using permission_handler

    if (FlutterBluePlus.isScanningNow) {
      print("Already scanning");
      return;
    }
    print("Starting BLE Scan...");
    isScanning.value = true;
    scanResults.value = []; // Clear previous results

    try {
      await FlutterBluePlus.startScan(
        // withServices: [Guid(SERVICE_UUID)], // Filter by service UUID - more reliable
        timeout: const Duration(seconds: 10), // Scan duration
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          // Filter results - look for your specific device name OR service UUID
          // Using name is easier initially but less robust than UUID
          final filteredResults =
              results
                  .where(
                    (r) =>
                        r.device.platformName == TARGET_DEVICE_NAME ||
                        r.advertisementData.serviceUuids.contains(
                          Guid(SERVICE_UUID),
                        ),
                  )
                  .toList();
          scanResults.value = filteredResults; // Update notifier
          print(
            "Scan results: ${scanResults.value.length} devices found potentially matching.",
          );
        },
        onError: (e) {
          print("Scan Error: $e");
          stopScan();
        },
      );

      // Stop scan after timeout automatically by FlutterBluePlus usually,
      // but ensure it stops if startScan is called again or on error.
      await Future.delayed(
        Duration(seconds: 11),
      ); // Wait a bit longer than timeout
      stopScan(); // Ensure stop
    } catch (e) {
      print("Error starting scan: $e");
      isScanning.value = false;
    }
  }

  void stopScan() {
    if (isScanning.value) {
      print("Stopping scan");
      FlutterBluePlus.stopScan();
      isScanning.value = false;
      _scanSubscription?.cancel();
      _scanSubscription = null;
    }
  }

  // --- Connection ---
  Future<bool> connectToDevice(BluetoothDevice device) async {
    stopScan(); // Stop scanning before connecting
    print("Connecting to ${device.platformName} (${device.remoteId})");

    if (isConnected.value && _targetDevice?.remoteId == device.remoteId) {
      print("Already connected to this device.");
      return true;
    }

    // Listen to connection state changes
    _connectionStateSubscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) async {
      print("Connection State: $state");
      isConnected.value = (state == BluetoothConnectionState.connected);
      if (isConnected.value) {
        _targetDevice = device;
        await _discoverServices(); // Discover services once connected
      } else {
        _targetDevice = null;
        _targetCharacteristic = null;
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15));
      // Connection state listener above handles success/failure implicitly
      return isConnected.value; // Return current status after attempt
    } catch (e) {
      print("Error connecting to device: $e");
      await disconnect(); // Ensure cleanup on error
      return false;
    }
  }

  Future<void> disconnect() async {
    print("Disconnecting...");
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    try {
      await _targetDevice?.disconnect();
    } catch (e) {
      print("Error during disconnect: $e");
    } finally {
      isConnected.value = false;
      _targetDevice = null;
      _targetCharacteristic = null;
    }
  }

  // --- Services & Characteristics ---
  Future<void> _discoverServices() async {
    if (_targetDevice == null) return;
    print("Discovering services...");
    try {
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      print("Found ${services.length} services");
      for (BluetoothService service in services) {
        print(" Service UUID: ${service.uuid.toString()}");
        if (service.uuid == Guid(SERVICE_UUID)) {
          print("Found target service!");
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            print("  Characteristic UUID: ${characteristic.uuid.toString()}");
            if (characteristic.uuid == Guid(CHARACTERISTIC_UUID)) {
              print("Found target characteristic!");
              _targetCharacteristic = characteristic;
              // Optional: Subscribe to notifications if needed later
              // await _subscribeToNotifications();
              return; // Found what we need
            }
          }
        }
      }
      print("Target characteristic not found!");
    } catch (e) {
      print("Error discovering services: $e");
    }
  }

  // --- Writing Data ---
  Future<void> sendCommand(String command) async {
    if (_targetCharacteristic == null || !isConnected.value) {
      print("Not connected or characteristic not found.");
      return;
    }

    if (!_targetCharacteristic!.properties.write) {
      print("Characteristic does not support writing.");
      return;
    }

    try {
      // IMPORTANT: ESP32 code expects a string. Encode string to bytes (UTF-8).
      List<int> bytesToSend = utf8.encode(command);
      print("Sending command: '$command' as bytes: $bytesToSend");

      // Use write without response for simple commands, or false for acknowledged write
      await _targetCharacteristic!.write(bytesToSend, withoutResponse: true);
      print("Command sent successfully.");
    } catch (e) {
      print("Error writing command: $e");
    }
  }

  // --- Notifications (Optional Example) ---
  Future<void> _subscribeToNotifications() async {
    if (_targetCharacteristic != null &&
        _targetCharacteristic!.properties.notify) {
      await _targetCharacteristic!.setNotifyValue(true);
      _targetCharacteristic!.onValueReceived.listen((value) {
        // ESP32 sends string "Value: X" -> bytes
        String receivedString = utf8.decode(
          value,
        ); // Decode bytes back to string
        print("Notification Received: $receivedString");
        // TODO: Handle received notification data
      });
      print("Subscribed to notifications");
    }
  }

  // Dispose method (call when service is no longer needed, e.g. in main app dispose)
  void dispose() {
    stopScan();
    disconnect();
    scanResults.dispose();
    isConnected.dispose();
    isScanning.dispose();
  }
}
