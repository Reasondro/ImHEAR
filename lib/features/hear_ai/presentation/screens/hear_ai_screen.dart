import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
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

  // This function figures out the main action button's text and callback
  // based on the current Cubit state AND the _isContinuousModeEnabled toggle.
  Map<String, dynamic> _getActionButtonConfig(
    BuildContext context,
    HearAiState state,
  ) {
    String buttonText = "Start Listening";
    VoidCallback? onPressed =
        () => context.read<HearAiCubit>().startRecording(); //? mode default
    Color buttonColor = Theme.of(context).primaryColor;
    bool showButton = true;

    if (_isContinuousModeEnabled) {
      if (state is HearAiRecording || state is HearAiProcessing) {
        buttonText = "Stop Continuous Listening";
        onPressed = () => context.read<HearAiCubit>().stopContinuousListening();
        buttonColor = Colors.orangeAccent;
      } else {
        // Initial, Ready, Success, Error in continuous mode
        buttonText = "Start Continuous Listening";
        onPressed =
            () => context.read<HearAiCubit>().startContinuousListening();
        buttonColor =
            AppColors.deluge; // A color to indicate continuous mode is ready
      }
    } else {
      // Manual Mode
      if (state is HearAiPermissionNeeded) {
        buttonText =
            state.isPermanentlyDenied ? "Open Settings" : "Grant Permission";
        onPressed =
            state.isPermanentlyDenied
                ? () => openAppSettings()
                : () =>
                    context.read<HearAiCubit>().requestMicrophonePermission();
        buttonColor = Colors.orangeAccent;
      } else if (state is HearAiReadyToRecord ||
          state is HearAiInitial ||
          state is HearAiSuccess ||
          state is HearAiError) {
        buttonText = "Start Manual Recording";
        onPressed = () => context.read<HearAiCubit>().startRecording();
      } else if (state is HearAiRecording) {
        buttonText = "Stop Manual Recording";
        onPressed = () => context.read<HearAiCubit>().stopAndProcessRecording();
        buttonColor = Colors.redAccent;
      } else if (state is HearAiProcessing) {
        buttonText = "Processing...";
        onPressed = null; // Disable while processing
        showButton = false; // Hide button, show processing UI instead
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
          // Avoid showing snackbar if it's a permission needed state, as UI handles it
          if (state is! HearAiPermissionNeeded) {
            // Check if it's not a permission state
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
        Widget centerContent;
        final actionButtonConfig = _getActionButtonConfig(context, state);

        if (state is HearAiInitial || state is HearAiReadyToRecord) {
          centerContent = HearAiIdleUi(
            onTap:
                _isContinuousModeEnabled
                    ? () =>
                        context.read<HearAiCubit>().startContinuousListening()
                    : () => context.read<HearAiCubit>().startRecording(),
            permissionNeeded: false,
          );
        } else if (state is HearAiPermissionNeeded) {
          centerContent = HearAiIdleUi(
            onTap: actionButtonConfig["action"],
            permissionNeeded: true,
            buttonText:
                actionButtonConfig["text"], // Will show "Grant Permission" or "Open Settings"
          );
        } else if (state is HearAiRecording) {
          centerContent = HearAiRecordingUi(
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
          centerContent = const HearAiProcessingUi();
        } else if (state is HearAiSuccess) {
          // Display list of results in continuous mode, or latest if manual & history has 1
          centerContent = HearAiSuccessUi(
            resultsHistory: state.resultsHistory,
            onStartNextRecording:
                () => context.read<HearAiCubit>().startRecording(),
            isContinuousMode: _isContinuousModeEnabled,
          );
        } else if (state is HearAiError) {
          centerContent = HearAiErrorUi(
            message: state.message,
            onTap:
                actionButtonConfig["action"], // Will be "Retry Permission/Init"
          );
        } else {
          centerContent = const Text("Unknown State");
        }

        return Padding(
          padding: const EdgeInsets.only(
            top: 64.0,
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

              // Dynamic content area
              // Expanded(
              //   child: Center(
              //     child: SingleChildScrollView(child: centerContent),
              //   ),
              // ), // Make content scrollable if it overflows
              centerContent,
              // Main Action Button (conditionally shown)
              if (actionButtonConfig["show"] &&
                  !(state is HearAiPermissionNeeded &&
                      _isContinuousModeEnabled) && // Don't show main button if continuous but needs permission
                  !(state is HearAiSuccess &&
                      _isContinuousModeEnabled &&
                      state
                          .resultsHistory
                          .isNotEmpty) // Don't show if continuous and showing results list
                  )
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

              const SizedBox(height: 10), // Bottom padding
            ],
          ),
        );
        // );
      },
    );
  }
}

// class HearAiScreen extends StatelessWidget {
//   const HearAiScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<HearAiCubit, HearAiState>(
//       listener: (context, state) {
//         if (state is HearAiError) {
//           context.customShowErrorSnackBar(state.message);
//         }
//         //? add listeners, e.g., trigger BLE command on HearAiSuccess
//         if (state is HearAiSuccess) {
//           print(
//             "AI Success in UI: ${state.latestResult.eventType} - ${state.latestResult.transcription}",
//           );
//           // TODO: Based on state.latestResult.eventType, send command to ESP32
//           //? maybe like this:
//           final CustomBluetoothService bleService =
//               context.read<CustomBluetoothService>();
//           if (bleService.isConnected.value) {
//             if (state.latestResult.eventType == "SOUND_ALARM") {
//               bleService.sendCommand("VIB_ALARM");
//             } else if (state.latestResult.eventType ==
//                 "SPEECH_URGENT_IMPORTANT") {
//               bleService.sendCommand("VIB_URGENT");
//             }
//           } else {
//             print("ImHEAR Band not connected");
//           }
//         }
//       },
//       builder: (context, state) {
//         Widget content;
//         VoidCallback tapAction;
//         if (state is HearAiInitial) {
//           // ? in initial, initialize might still be running, or permission needed
//           //? button action will re-trigger permission check if needed via cubit
//           tapAction = () => context.read<HearAiCubit>().startRecording();
//           content = HearAiIdleUi(onTap: tapAction, permissionNeeded: false);
//         } else if (state is HearAiPermissionNeeded) {
//           String buttonText =
//               state.isPermanentlyDenied ? "Open Settings" : "Grant Permission";
//           tapAction =
//               state.isPermanentlyDenied
//                   ? () => openAppSettings()
//                   : () =>
//                       context.read<HearAiCubit>().requestMicrophonePermission();
//           content = HearAiIdleUi(
//             onTap: tapAction,
//             permissionNeeded: true,
//             buttonText: buttonText,
//           );
//         } else if (state is HearAiReadyToRecord) {
//           tapAction = () => context.read<HearAiCubit>().startRecording();
//           content = HearAiIdleUi(onTap: tapAction, permissionNeeded: false);
//         } else if (state is HearAiRecording) {
//           tapAction =
//               () => context.read<HearAiCubit>().stopAndProcessRecording();
//           content = HearAiRecordingUi(onTap: tapAction);
//         } else if (state is HearAiProcessing) {
//           content = const HearAiProcessingUi();
//         } else if (state is HearAiSuccess) {
//           tapAction =
//               () =>
//                   context
//                       .read<HearAiCubit>()
//                       .startRecording(); //? ready for new recording
//           content = HearAiSuccessUi(
//             transcription: state.latestResult.transcription,
//             eventType: state.latestResult.eventType,
//             details: state.latestResult.details,
//             onTap: tapAction,
//           );
//         } else if (state is HearAiError) {
//           tapAction =
//               () =>
//                   context
//                       .read<HearAiCubit>()
//                       .initializeAndCheckPermission(); //? retry initialization if error
//           content = HearAiErrorUi(message: state.message, onTap: tapAction);
//         } else {
//           content = const Text("Unknown State"); //? should not happen
//         }

//         return Padding(
//           padding: const EdgeInsets.only(
//             top: 24.0,
//             bottom: 8.0,
//             left: 24.0,
//             right: 24.0,
//           ),
//           child: ListView(
//             children: <Widget>[
//               RichText(
//                 textAlign: TextAlign.center,
//                 text: const TextSpan(
//                   style: TextStyle(
//                     color: AppColors.haiti,
//                     fontSize: 48,
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.normal,
//                   ),
//                   children: [
//                     TextSpan(text: "Hear"),
//                     TextSpan(
//                       text: "AI",
//                       style: TextStyle(
//                         color: AppColors.bittersweet,
//                         fontWeight: FontWeight.bold,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 50),
//               content,
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
