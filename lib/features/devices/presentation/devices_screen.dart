import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late CustomBluetoothService _bluetoothService;
  BluetoothDevice? _pairedDevice;
  //? store the device user intends to use or last connected
  // ? mightneed to  load this from shared_preferences in production

  StreamSubscription<BluetoothConnectionState>? _connectionStateListener;
  StreamSubscription<bool>? _isScanningListener;

  @override
  void initState() {
    super.initState();
    //? access the service via context.
    //? it's better to do this in didChangeDependencies or build if context might not be ready,
    //? but for a top-level screen under MultiRepositoryProvider, initState is often okay.
    //? but,to be safe and allow ValueListenableBuilders to work immediately with the
    //? correct instance,assign it here.
    _bluetoothService = context.read<CustomBluetoothService>();

    //? initialize _pairedDevice if already connected from the service
    if (_bluetoothService.isConnected.value &&
        _bluetoothService.connectedDevice != null) {
      _pairedDevice = _bluetoothService.connectedDevice;
    }

    //? listen to connection changes from the service to update UI/pairedDevice
    //? using ValueListenableBuilder is preferred for UI, but if we need to update _pairedDevice:
    _bluetoothService.isConnected.addListener(_handleConnectionChange);
  }

  void _handleConnectionChange() {
    if (mounted) {
      setState(() {
        if (_bluetoothService.isConnected.value &&
            _bluetoothService.connectedDevice != null) {
          _pairedDevice = _bluetoothService.connectedDevice;
        } else if (!_bluetoothService.isConnected.value &&
            _pairedDevice != null &&
            _pairedDevice?.remoteId ==
                _bluetoothService.connectedDevice?.remoteId) {
          //? it was our paired device that disconnected
          //? _pairedDevice could be kept to allow quick reconnect, or cleared:
          //? _pairedDevice = null; // to force re-scan/select
        }
      });
    }
  }

  @override
  void dispose() {
    _connectionStateListener?.cancel();
    _isScanningListener?.cancel();
    _bluetoothService.isConnected.removeListener(_handleConnectionChange);
    // ! try to underestand this ==> Don't dispose the service here if it's a singleton provided by RepositoryProvider
    super.dispose();
  }

  Future<void> _requestAndStartScan() async {
    // ? request permissions --> simplified, add more robust handling than from the proto ble test screen
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse, //? needed for older Android
        ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted) {
      //?   show scas  results in a Modal
      if (mounted) {
        _showDeviceScanModal(context);
      }
    } else {
      if (mounted) {
        context.customShowSnackBar(
          "Bluetooth permissions are required to scan for devices.",
        );
      }
      print("Permissions not granted");
    }
  }

  void _showDeviceScanModal(BuildContext parentContext) {
    //? Use parentContext to access providers if needed within the modal
    _bluetoothService.startScan(); //? start scan when modal opens

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true, //? allows modal to take more height
      builder: (modalContext) {
        return Container(
          height:
              MediaQuery.of(parentContext).size.height *
              0.4, //? take 40% of screen height
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Searching for Devices...",
                    style: Theme.of(parentContext).textTheme.titleLarge,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _bluetoothService.isScanning,
                    builder:
                        (_, isScanning, __) =>
                            isScanning
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                                : IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _bluetoothService.startScan,
                                ), // ? rescan
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder<List<ScanResult>>(
                  valueListenable: _bluetoothService.scanResults,
                  builder: (_, results, __) {
                    if (!_bluetoothService.isScanning.value &&
                        results.isEmpty) {
                      return const Center(
                        child: Text(
                          "No devices found. Ensure your wristband is on and discoverable.",
                        ),
                      );
                    }
                    if (results.isEmpty && _bluetoothService.isScanning.value) {
                      return const Center(child: Text("Scanning..."));
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, index) {
                        final result = results[index];
                        return ListTile(
                          title: Text(
                            result.device.platformName.isNotEmpty
                                ? result.device.platformName
                                : "Unknown Device",
                          ),
                          subtitle: Text(result.device.remoteId.toString()),
                          onTap: () async {
                            _bluetoothService.stopScan(); //? stop scan
                            setState(() {
                              _pairedDevice =
                                  result
                                      .device; //? set as the device to connect to
                            });
                            Navigator.pop(modalContext); //? close modal
                            await _bluetoothService.connectToDevice(
                              _pairedDevice!,
                            ); //? Attempt connection
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _bluetoothService.stopScan();
                    Navigator.pop(modalContext);
                  },
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        );
        // );
      },
    ).whenComplete(() {
      print("when complete block");
      _bluetoothService
          .stopScan(); //? ensure scan stops when modal is dismissed
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.haiti,
                fontWeight: FontWeight.w600,
              ),
              children: const [
                TextSpan(text: "My "),
                TextSpan(
                  text: "Device",
                  style: TextStyle(
                    color: AppColors.bittersweet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          //? device Image
          Image.asset(
            'assets/images/smartwatch_placeholder.png',
            height: 200,
            errorBuilder:
                (ctx, err, st) => const Icon(
                  Icons.watch,
                  size: 150,
                  color: AppColors.lavender,
                ),
          ),
          const SizedBox(height: 20),

          //? device Name
          Text(
            _pairedDevice?.platformName.isNotEmpty == true
                ? _pairedDevice!.platformName
                : "ImHEAR Band", //? show actual name if paired/connected
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.haiti,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          //? connection status text
          ValueListenableBuilder<bool>(
            valueListenable: _bluetoothService.isConnected,
            builder: (context, isConnectedValue, child) {
              return Text(
                isConnectedValue ? "Connected" : "Not Connected",
                style: textTheme.titleMedium?.copyWith(
                  color:
                      isConnectedValue
                          ? Colors.greenAccent
                          : AppColors.paleCarmine,
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          //? action buttons
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<bool>(
              valueListenable: _bluetoothService.isConnected,
              builder: (context, isConnectedValue, child) {
                return ElevatedButton(
                  onPressed: () async {
                    if (isConnectedValue) {
                      await _bluetoothService.disconnect();
                      //? optionally clear _pairedDevice or keep for quick reconnect
                      // setState(() => _pairedDevice = null);
                    } else {
                      if (_pairedDevice != null) {
                        await _bluetoothService.connectToDevice(_pairedDevice!);
                      } else {
                        //? no paired device, prompt to scan via "Switch Devices"
                        context.customShowSnackBar(
                          "No device selected. Please use 'Switch Devices' to scan.",
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isConnectedValue
                            ? AppColors.deluge.withAlpha(179)
                            : AppColors.bittersweet,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isConnectedValue
                        ? "Disconnect"
                        : (_pairedDevice != null
                            ? "Connect to ${_pairedDevice!.platformName}"
                            : "Connect"),
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _requestAndStartScan, //? triggers the modal &  scan
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.deluge,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Switch Devices",
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.lavender,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
