import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';

class BleTestScreen extends StatefulWidget {
  const BleTestScreen({super.key});
  @override
  State<BleTestScreen> createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  // Assume BluetoothService is provided via Provider, GetIt, or is a Singleton
  // For simplicity, create instance here (NOT recommended for real app)
  final CustomBluetoothService _bluetoothService = CustomBluetoothService();
  BluetoothDevice?
  _selectedDevice; // To store the device user wants to connect to

  final TextEditingController _commandController = TextEditingController();

  @override
  void dispose() {
    _bluetoothService.dispose(); // Clean up service
    _commandController.dispose(); // Dispose the controller
    super.dispose();
  }

  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status
            ValueListenableBuilder<bool>(
              valueListenable: _bluetoothService.isConnected,
              builder: (context, isConnected, child) {
                return Text(
                  isConnected ? "Status: CONNECTED" : "Status: DISCONNECTED",
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Scan Button & Status
            ValueListenableBuilder<bool>(
              valueListenable: _bluetoothService.isScanning,
              builder: (context, isScanning, child) {
                return ElevatedButton.icon(
                  icon:
                      isScanning
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.search),
                  label: Text(isScanning ? "Scanning..." : "Start Scan"),
                  onPressed:
                      isScanning
                          ? null
                          : () async {
                            final currentContext = context;
                            bool scanStarted =
                                await _bluetoothService.startScan();
                            if (!scanStarted && currentContext.mounted) {
                              currentContext.customShowErrorSnackBar(
                                "Could not start scan. Please ensure Bluetooth & Location permissions are granted and Bluetooth & Location are on.",
                              );
                            }
                          },
                );
              },
            ),
            const SizedBox(height: 10),
            // Scan Results List
            Text(
              "Scan Results:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: ValueListenableBuilder<List<ScanResult>>(
                valueListenable: _bluetoothService.scanResults,
                builder: (context, results, child) {
                  if (results.isEmpty) {
                    return const Text(
                      "No devices found (ensure BLE & Location are on).",
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return ListTile(
                        title: Text(
                          result.device.platformName.isNotEmpty
                              ? result.device.platformName
                              : "Unknown Device",
                        ),
                        subtitle: Text(result.device.remoteId.toString()),
                        trailing: ElevatedButton(
                          // Connect only if disconnected
                          onPressed:
                              _bluetoothService.isConnected.value
                                  ? null
                                  : () async {
                                    _selectedDevice =
                                        result.device; // Store selected device
                                    bool success = await _bluetoothService
                                        .connectToDevice(_selectedDevice!);
                                    if (success) {
                                      print("Connection attempt successful");
                                    } else {
                                      print("Connection attempt failed");
                                    }
                                  },
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Text("Result: $result"),

            // Action Buttons (only enabled if connected)
            ValueListenableBuilder<bool>(
              valueListenable: _bluetoothService.isConnected,
              builder: (context, isConnected, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commandController,
                            decoration: const InputDecoration(
                              hintText: "Enter command",
                              border: OutlineInputBorder(),
                            ),
                            enabled: isConnected,
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed:
                              isConnected
                                  ? () async {
                                    if (_commandController.text.isNotEmpty) {
                                      String commandToSend =
                                          _commandController.text;
                                      String commandResult =
                                          await _bluetoothService.sendCommand(
                                            commandToSend,
                                          );
                                      setState(() {
                                        result = commandResult;
                                      });
                                      _commandController.clear();
                                    }
                                  }
                                  : null,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Disconnect Button (moved here for better grouping)
                    ElevatedButton(
                      onPressed:
                          isConnected ? _bluetoothService.disconnect : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Disconnect"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
