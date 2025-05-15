import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:komunika/features/hear_ai/domain/entities/hear_ai_result.dart';
import 'package:komunika/features/hear_ai/presentation/cubit/hear_ai_cubit.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_error_ui.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_idle_ui.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_processing_ui.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_recording_ui.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_success_ui.dart';
import 'package:permission_handler/permission_handler.dart';

class HearAiScreen extends StatefulWidget {
  const HearAiScreen({super.key});

  @override
  State<HearAiScreen> createState() => _HearAiScreenState();
}

class _HearAiScreenState extends State<HearAiScreen> {
  bool _isContinuousModeEnabled = false;

  // ? function figures out the main action button's text and callback
  Map<String, dynamic> _getActionButtonConfig(
    BuildContext context,
    HearAiState state,
  ) {
    String buttonText;
    VoidCallback? onPressed;
    Color buttonColor = AppColors.haiti;
    bool showButton = true;

    // Handle permission-related states
    if (state is HearAiPermissionNeeded) {
      buttonText =
          state.isPermanentlyDenied ? "Open Settings" : "Grant Permission";
      onPressed =
          state.isPermanentlyDenied
              ? () => openAppSettings()
              : () => context.read<HearAiCubit>().requestMicrophonePermission();
      buttonColor = Colors.orangeAccent;
      showButton = false; // Hide main button, handled by HearAiIdleUi
    } else if (state is HearAiProcessing) {
      buttonText = "Processing...";
      onPressed = null; // Disable button while processing
      showButton = false; // Hide button, show processing UI instead
    } else {
      // Handle recording and ready states
      if (_isContinuousModeEnabled) {
        if (state is HearAiRecording) {
          buttonText = "Stop Continuous Listening";
          onPressed =
              () => context.read<HearAiCubit>().stopContinuousListening();
          buttonColor = Colors.orangeAccent;
        } else {
          buttonText = "Start Continuous Listening";
          onPressed =
              () => context.read<HearAiCubit>().startContinuousListening();
          buttonColor = AppColors.deluge;
        }
      } else {
        if (state is HearAiRecording) {
          buttonText = "Stop Manual Recording";
          onPressed =
              () => context.read<HearAiCubit>().stopAndProcessRecording();
          buttonColor = Colors.redAccent;
        } else {
          buttonText = "Start Manual Recording";
          onPressed = () => context.read<HearAiCubit>().startRecording();
        }
      }
    }

    return {
      "text": buttonText,
      "action": onPressed,
      "color": buttonColor,
      "show": showButton,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HearAiCubit, HearAiState>(
      listener: (context, state) {
        if (state is HearAiError) {
          if (state is! HearAiPermissionNeeded) {
            context.customShowErrorSnackBar(state.message);
          }
        }
        if (state is HearAiSuccess) {
          print(
            "AI Success in UI: ${state.latestResult.eventType} - ${state.latestResult.transcription}",
          );
          final CustomBluetoothService bleService =
              context.read<CustomBluetoothService>();
          if (bleService.isConnected.value) {
            // Example: Customize command based on eventType
            String command = "VIB_NEUTRAL"; // Default command
            if (state.latestResult.eventType == "SOUND_ALARM")
              command = "VIB_ALARM";
            else if (state.latestResult.eventType == "SPEECH_URGENT_IMPORTANT")
              command = "VIB_URGENT";
            else if (state.latestResult.eventType == "SOUND_VEHICLE_HORN")
              command = "VIB_CAR_HORN";
            // Add more mappings here
            bleService.sendCommand(command);
          } else {
            print("ImHEAR Band not connected, can't send vibration.");
          }
        }
      },
      builder: (context, state) {
        final List<HearAiResult> history =
            context.watch<HearAiCubit>().resultsHistory;

        Widget content;
        final actionButtonConfig = _getActionButtonConfig(context, state);

        if (state is HearAiInitial || state is HearAiReadyToRecord) {
          content = HearAiIdleUi(
            onTap:
                _isContinuousModeEnabled
                    ? () =>
                        context.read<HearAiCubit>().startContinuousListening()
                    : () => context.read<HearAiCubit>().startRecording(),
            permissionNeeded: false,
          );
        } else if (state is HearAiPermissionNeeded) {
          content = HearAiIdleUi(
            onTap: actionButtonConfig["action"],
            permissionNeeded: true,
            buttonText: actionButtonConfig["text"],
          );
        } else if (state is HearAiRecording) {
          content = HearAiRecordingUi(
            onTap:
                _isContinuousModeEnabled
                    ? () =>
                        context
                            .read<HearAiCubit>()
                            .stopContinuousListening() // In continuous, stop fully
                    : () =>
                        context
                            .read<HearAiCubit>()
                            .stopAndProcessRecording(), // In manual, stop & process
          );
        } else if (state is HearAiProcessing) {
          content = const HearAiProcessingUi();
        } else if (state is HearAiSuccess) {
          // Display list of results in continuous mode, or latest if manual & history has 1
          content = HearAiSuccessUi(
            resultsHistory: state.resultsHistory,
            onStartNextRecording:
                () => context.read<HearAiCubit>().startRecording(),
            isContinuousMode: _isContinuousModeEnabled,
          );
        } else if (state is HearAiError) {
          content = HearAiErrorUi(
            message: state.message,
            onTap:
                actionButtonConfig["action"], // Will be "Retry Permission/Init"
          );
        } else {
          content = const Text("Unknown State");
        }

        return Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: Column(
            children: <Widget>[
              // Mode Toggle Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Continuous Mode",
                    style: TextStyle(color: AppColors.haiti),
                  ),
                  Switch(
                    value: _isContinuousModeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isContinuousModeEnabled = value;
                      });
                    },
                    activeColor: AppColors.bittersweet,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              content,

              if (actionButtonConfig["show"] &&
                  state
                      is! HearAiPermissionNeeded) // Hide button if permission is needed
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionButtonConfig["color"],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: actionButtonConfig["action"],
                      child: Text(
                        actionButtonConfig["text"],
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
