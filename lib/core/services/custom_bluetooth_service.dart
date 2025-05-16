// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:convert'; //? for utf8.encode
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ? defining our ESP32's specific UUIDs
const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
const String TARGET_DEVICE_NAME =
    "ESP32-C3-BLE"; // ? the name from the ESP32 sketch code code
const int DATE_SYNC_COMMAND_PREFIX = 0x01;

class CustomBluetoothService {
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  BluetoothDevice? get connectedDevice => _targetDevice;

  // ? ValueNotifier for simple state exposure to UI
  ValueNotifier<bool> isConnected = ValueNotifier(false);
  ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  ValueNotifier<bool> isScanning = ValueNotifier(false);

  // ? Permission handler

  Future<bool> _requestBlePermissions() async {
    List<Permission> permissionsToRequest = [
      //? primarily for Android 12+ but permission_handler
      //? should handle them gracefully on iOS.
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];
    bool isLocationPermissionRequired = false;

    if (Platform.isAndroid) {
      permissionsToRequest.add(Permission.locationWhenInUse);
      isLocationPermissionRequired = true;
    } else if (Platform.isIOS) {
      permissionsToRequest.add(Permission.bluetooth);
      permissionsToRequest.add(Permission.locationWhenInUse);
      isLocationPermissionRequired = true;
    }

    Map<Permission, PermissionStatus> statuses =
        await permissionsToRequest.request();

    PermissionStatus? scanStatus = statuses[Permission.bluetoothScan];
    PermissionStatus? connectStatus = statuses[Permission.bluetoothConnect];
    PermissionStatus? locationStatus =
        statuses[Permission
            .locationWhenInUse]; //?  will be null if not requested
    PermissionStatus? iosBluetoothStatus =
        statuses[Permission.bluetooth]; //? will be null if not iOS

    if (Platform.isAndroid) {
      if (scanStatus != PermissionStatus.granted) {
        // print("Android: Bluetooth Scan permission denied");
        //? handle denial, currently just return
        return false;
      }
      if (connectStatus != PermissionStatus.granted) {
        // print("Android: Bluetooth Connect permission denied");
        //? handle denial, currently just return
        return false;
      }
      if (locationStatus != PermissionStatus.granted) {
        // print(
        //   "Android: Location permission denied. BLE scanning might not work as expected or at all.",
        // );
        //? handle denial, currently just return
        return false;
      }
      if (isLocationPermissionRequired) {
        ServiceStatus locationServiceStatus =
            await Permission.locationWhenInUse.serviceStatus;
        if (!locationServiceStatus.isEnabled) {
          // print(
          //   "Android: Location permission is granted, but Location Services are disabled. Please enable them.",
          // );
          //?  optionally can try to open settings // await openAppSettings();
          return false; //? Critical for scanning
        }
      }
    } else if (Platform.isIOS) {
      if (iosBluetoothStatus != PermissionStatus.granted) {
        // print("iOS: Bluetooth permission denied");
        return false;
      }
      if (isLocationPermissionRequired &&
          locationStatus != PermissionStatus.granted) {
        // print("iOS: Location permission denied.");
        return false;
      }
      //? after permission --> check if Location Service is enabled
      if (isLocationPermissionRequired &&
          locationStatus == PermissionStatus.granted) {
        ServiceStatus locationServiceStatus =
            await Permission.locationWhenInUse.serviceStatus;
        if (!locationServiceStatus.isEnabled) {
          // print(
          //   "iOS: Location permission is granted, but Location Services are disabled. Please enable them.",
          // );
          //?  optionally can try to open settings // await openAppSettings();
          return false;
        }
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      //?  check if Bluetooth adapter is already on
      bool isBluetoothOn =
          await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isBluetoothOn) {
        // print("Android: Bluetooth is off, attempting to turn it on.");
        await FlutterBluePlus.turnOn();
        // ? re-check after attempting to turn on
        isBluetoothOn =
            await FlutterBluePlus.adapterState.first ==
            BluetoothAdapterState.on;
        if (!isBluetoothOn) {
          // print("Android: Failed to turn on Bluetooth or user denied.");
          return false; //? A MUST --> Bluetooth is critical
        }
      }
    }
    // print("Required BLE permissions seem to be granted or handled.");
    return true;
  }

  // --- Scanning ---
  Future<bool> startScan() async {
    bool permissionGranted = await _requestBlePermissions();

    if (!permissionGranted) {
      // print("Permissions not granted. Aborting scan.");
      isScanning.value = false; //? ensure scanning state is resett
      // ? or notify the ui or user here
      return false;
    }

    if (FlutterBluePlus.isScanningNow) {
      // print("Already scanning");
      return true;
    }
    // print("Starting BLE Scan...");
    isScanning.value = true;
    scanResults.value = []; //? clear previous results

    try {
      await FlutterBluePlus.startScan(
        // withServices: [Guid(SERVICE_UUID)], // ? optional, Filter by service UUID - more reliable
        timeout: const Duration(seconds: 10), //? scan duration
        androidUsesFineLocation: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          // ? filter results - look for specific device name OR service UUID
          // TODO: Using name is easier initially but less robust than UUID
          final List<ScanResult> filteredResults =
              results
                  .where(
                    (r) =>
                        r.device.platformName == TARGET_DEVICE_NAME ||
                        r.advertisementData.serviceUuids.contains(
                          Guid(SERVICE_UUID),
                        ),
                  )
                  .toList();
          scanResults.value = filteredResults; //? update notifier
          // print(
          //   "Scan results: ${scanResults.value.length} devices found potentially matching.",
          // );
        },
        onError: (e) {
          // print("Scan Error: $e");
          stopScan();
        },
        onDone: () {
          // print("Scan results stream is done.");
          //? ensure our state is updated if it still thinks it's scanning
          if (isScanning.value) {
            // print(
            //   "Stream done, explicitly calling stopScan to update UI state.",
            // );
            stopScan();
          }
        },
      );
      //?  stop scan after timeout automatically by FlutterBluePlus usually,
      // ? but ensure it stops if startScan is called again or on error.
      await Future.delayed(const Duration(seconds: 11));
      stopScan(); //? ensure stop
      return true;
    } catch (e) {
      // print("Error starting scan: $e");
      isScanning.value = false;
      return false;
    }
  }

  void stopScan() {
    if (!FlutterBluePlus.isScanningNow && !isScanning.value) {
      //? avoid redundant calls or messages if already stopped
      return;
    }
    // print("Stopping BLE Scan...");
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning.value = false;
  }

  // ?  Connection
  Future<bool> connectToDevice(BluetoothDevice device) async {
    stopScan(); //? stop scanning before connecting
    // print("Connecting to ${device.platformName} (${device.remoteId})");

    if (isConnected.value && _targetDevice?.remoteId == device.remoteId) {
      // print("Already connected to this device.");
      return true;
    }

    // ? listen to connection state changes
    _connectionStateSubscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) async {
      // print("Connection State: $state");
      isConnected.value = (state == BluetoothConnectionState.connected);
      if (isConnected.value) {
        _targetDevice = device;
        await _discoverServices(); //?  discover services once connected
      } else {
        _targetDevice = null;
        _targetCharacteristic = null;
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15));
      //? connection state listener above handles success/failure implicitly
      return isConnected.value; //? return current status after attempt
    } catch (e) {
      // print("Error connecting to device: $e");
      await disconnect(); //? ensure cleanup on error
      return false;
    }
  }

  Future<void> disconnect() async {
    // print("Disconnecting...");
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    try {
      await _targetDevice?.disconnect();
    } catch (e) {
      // print("Error during disconnect: $e");
    } finally {
      isConnected.value = false;
      _targetDevice = null;
      _targetCharacteristic = null;
    }
  }

  //?  Services & Characteristics
  Future<void> _discoverServices() async {
    if (_targetDevice == null) return;
    // print("Discovering services...");
    try {
      List<BluetoothService> services = await _targetDevice!.discoverServices();
      // print("Found ${services.length} services");
      for (BluetoothService service in services) {
        // print(" Service UUID: ${service.uuid.toString()}");
        if (service.uuid == Guid(SERVICE_UUID)) {
          // print("Found target service!");
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            // print("  Characteristic UUID: ${characteristic.uuid.toString()}");
            if (characteristic.uuid == Guid(CHARACTERISTIC_UUID)) {
              // print("Found target characteristic!");
              _targetCharacteristic = characteristic;
              //? send date sync command after characteristic is found
              await _sendDateTimeSyncCommand();
              //? optional: Subscribe to notifications if needed later
              // await _subscribeToNotifications();
              return; // ? found what we need
            }
          }
        }
      }
      // print("Target characteristic not found!");
    } catch (e) {
      // print("Error discovering services: $e");
    }
  }

  // ?  Writing Data

  // ? this function currently returning String only for testing the UI
  // ? in reality, it is not needed, returning to void is the corerct way
  Future<String> sendCommand(String command) async {
    String result;
    if (_targetCharacteristic == null || !isConnected.value) {
      // print("Not connected or characteristic not found.");
      result = "Not connected or characteristic not found.";
      return result;
    }

    if (!_targetCharacteristic!.properties.write) {
      // print("Characteristic does not support writing.");
      result = "Characteristic does not support writing.";
      return result;
    }

    try {
      //! IMPORTANT: ESP32 code expects a string. Encode string to bytes (UTF-8).
      List<int> bytesToSend = utf8.encode(command);
      // print("Sending command: '$command' as bytes: $bytesToSend");
      result = "Sending command: '$command' as bytes: $bytesToSend";
      // Use write without response for simple commands, or false for acknowledged write
      await _targetCharacteristic!.write(bytesToSend, withoutResponse: false);
      // print("Command sent successfully.");
      result = "Command sent successfully.";
      return result;
    } catch (e) {
      // print("Error writing command: $e");

      result = "Error writing command: $e";
      return result;
    }
  }

  // ? this function currently returning String only for testing the UI
  // ? in reality, it is not needed, returning to void is the corerct way
  Future<String> sendCommandBytes(List<int> bytesToSend) async {
    String result; //? for debugging

    if (_targetCharacteristic == null || !isConnected.value) {
      // print("sendCommandBytes: Not connected or characteristic not found.");
      result = "Not connected or characteristic not found.";
      return result;
    }

    if (!_targetCharacteristic!.properties.write) {
      // print("sendCommandBytes: Characteristic does not support writing.");
      result = "Characteristic does not support writing.";
      return result;
    }

    try {
      // print("sendCommandBytes: Sending raw bytes: $bytesToSend");
      result = "Sending raw bytes: $bytesToSend";

      await _targetCharacteristic!.write(bytesToSend, withoutResponse: false);
      // print("sendCommandBytes: Bytes sent sucesfully");
      result = "Bytes sent sucesfully";
      return result;
    } catch (e) {
      // print("Error writing command: $e");

      result = "Error writing command: $e";
      return result;
    }
  }

  Future<void> _sendDateTimeSyncCommand() async {
    if (_targetCharacteristic == null || !isConnected.value) {
      // print("Date Sync: Not connected or characteristic not found.");
      return;
    }

    if (!_targetCharacteristic!.properties.write) {
      // print("Date Sync: Characteristic does not support writing.");
      return;
    }

    try {
      // Get current Unix timestamp (seconds since epoch)
      // int epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // ? milisecondds
      //       // Get current Unix timestamp (milliseconds since epoch)
      int epochMilliseconds = DateTime.now().millisecondsSinceEpoch;

      // Create a ByteData buffer.
      // 1 byte for prefix, 4 bytes for the epochSeconds (int32).
      // Adjust size and type (e.g., setUint64 for milliseconds) if your ESP32 expects something different.
      // ByteData byteData = ByteData(5);
      // byteData.setUint8(0, DATE_SYNC_COMMAND_PREFIX); // Set the prefix byte

      // ? milisecondds
      ByteData byteData = ByteData(
        9,
      ); // 1 (prefix) + 8 (milliseconds) = 9 bytes
      byteData.setUint8(0, DATE_SYNC_COMMAND_PREFIX); // Set the prefix byte

      // Set the epoch time. Assuming ESP32 expects Little Endian.
      // Change to Endian.big if your ESP32 expects Big Endian.
      // byteData.setUint32(1, epochSeconds, Endian.little);

      // ? milisecondds
      // Set the epoch time in milliseconds. Assuming ESP32 expects Little Endian.
      // Change to Endian.big if your ESP32 expects Big Endian.
      byteData.setUint64(1, epochMilliseconds, Endian.little);

      List<int> bytesToSend = byteData.buffer.asUint8List();

      // print(
      //   "Date Sync: Sending epoch $epochSeconds as bytes: $bytesToSend (Prefix: $DATE_SYNC_COMMAND_PREFIX)",
      // );

      // ? milisecondds
      // print(
      //   "Date Sync: Sending epoch milliseconds $epochMilliseconds as bytes: $bytesToSend (Prefix: $DATE_SYNC_COMMAND_PREFIX)",
      // );
      // Use write without response for simple commands, or false for acknowledged write
      await _targetCharacteristic!.write(bytesToSend, withoutResponse: false);
      // print("Date Sync: Command sent successfully.");
    } catch (e) {
      // print("Date Sync: Error writing command: $e");
    }
  }

  //? Notifications
  Future<void> _subscribeToNotifications() async {
    if (_targetCharacteristic != null &&
        _targetCharacteristic!.properties.notify) {
      await _targetCharacteristic!.setNotifyValue(true);
      _targetCharacteristic!.onValueReceived.listen((value) {
        //? ESP32 sends string "Value: X" -> bytes
        String receivedString = utf8.decode(
          value,
        ); //? decode bytes back to string
        // print("Notification Received: $receivedString");
        // TODO: Handle received notification data
      });
      // print("Subscribed to notifications");
    }
  }

  //? dispose method (call when service is no longer needed, e.g. in main app dispose)
  void dispose() {
    stopScan();
    disconnect();
    scanResults.dispose();
    isConnected.dispose();
    isScanning.dispose();
  }
}
