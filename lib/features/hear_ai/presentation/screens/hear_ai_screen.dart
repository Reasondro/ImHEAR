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

class HearAiScreen extends StatelessWidget {
  const HearAiScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HearAiCubit, HearAiState>(
      listener: (context, state) {
        if (state is HearAIError) {
          context.customShowErrorSnackBar(state.message);
        }
        //? add listeners, e.g., trigger BLE command on HearAiSuccess
        if (state is HearAiSuccess) {
          print(
            "AI Success in UI: ${state.eventType} - ${state.transcription}",
          );
          // TODO: Based on state.eventType, send command to ESP32
          //? maybe like this:
          final CustomBluetoothService bleService =
              context.read<CustomBluetoothService>();
          if (bleService.isConnected.value) {
            if (state.eventType == "SOUND_ALARM") {
              bleService.sendCommand("VIB_ALARM");
            } else if (state.eventType == "SPEECH_URGENT_IMPORTANT") {
              bleService.sendCommand("VIB_URGENT");
            }
          } else {
            print("ImHEAR Band not connected");
          }
        }
      },
      builder: (context, state) {
        Widget content;
        VoidCallback tapAction;
        if (state is HearAiInitial) {
          // ? in initial, initialize might still be running, or permission needed
          //? button action will re-trigger permission check if needed via cubit
          tapAction = () => context.read<HearAiCubit>().startRecording();
          content = HearAiIdleUi(onTap: tapAction, permissionNeeded: false);
        } else if (state is HearAiPermissionNeeded) {
          String buttonText =
              state.isPermanentlyDenied ? "Open Settings" : "Grant Permission";
          tapAction =
              state.isPermanentlyDenied
                  ? () => openAppSettings()
                  : () =>
                      context.read<HearAiCubit>().requestMicrophonePermission();
          content = HearAiIdleUi(
            onTap: tapAction,
            permissionNeeded: true,
            buttonText: buttonText,
          );
        } else if (state is HearAiReadyToRecord) {
          tapAction = () => context.read<HearAiCubit>().startRecording();
          content = HearAiIdleUi(onTap: tapAction, permissionNeeded: false);
        } else if (state is HearAiRecording) {
          tapAction =
              () => context.read<HearAiCubit>().stopAndProcessRecording();
          content = HearAiRecordingUi(onTap: tapAction);
        } else if (state is HearAiProcessing) {
          content = const HearAiProcessingUi();
        } else if (state is HearAiSuccess) {
          tapAction =
              () =>
                  context
                      .read<HearAiCubit>()
                      .startRecording(); //? ready for new recording
          content = HearAiSuccessUi(
            transcription: state.transcription,
            eventType: state.eventType,
            details: state.details,
            onTap: tapAction,
          );
        } else if (state is HearAIError) {
          tapAction =
              () =>
                  context
                      .read<HearAiCubit>()
                      .initializeAndCheckPermission(); //? retry initialization if error
          content = HearAiErrorUi(message: state.message, onTap: tapAction);
        } else {
          content = const Text("Unknown State"); //? should not happen
        }

        return Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: ListView(
            children: <Widget>[
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.haiti,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                  children: [
                    TextSpan(text: "Hear"),
                    TextSpan(
                      text: "AI",
                      style: TextStyle(
                        color: AppColors.bittersweet,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              content,
            ],
          ),
        );
      },
    );
  }
}
