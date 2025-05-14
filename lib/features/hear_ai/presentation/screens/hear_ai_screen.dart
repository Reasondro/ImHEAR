import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:komunika/app/themes/app_colors.dart';
// import 'dart:io';
// import 'dart:typed_data';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:komunika/core/services/custom_bluetooth_service.dart';
import 'package:komunika/features/hear_ai/presentation/cubit/hear_ai_cubit.dart';
import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';

class HearAiScreen extends StatelessWidget {
  const HearAiScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HearAiCubit(),
      child: BlocConsumer<HearAiCubit, HearAiState>(
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
            final bleService = context.read<CustomBluetoothService>();
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
          Widget centerContent;
          String buttonText = "Start Listening";
          VoidCallback? tapAction =
              () => context.read<HearAiCubit>().startRecording();
          // Color buttonColor = AppColors.bittersweet;
          Color buttonColor = AppColors.haiti;
          // Color buttonColor = AppColors.deluge;
          bool showProcessButton = false;

          if (state is HearAiInitial) {
            centerContent = _buildIdleUI("Tap to start listening", tapAction);
            // ? in initial, initialize might still be running, or permission needed
            //? button action will re-trigger permission check if needed via cubit
          } else if (state is HearAiPermissionNeeded) {
            centerContent = _buildIdleUI(state.message, tapAction);
            buttonText =
                state.isPermanentlyDenied
                    ? "Open Settings"
                    : "Grant Permission";
            tapAction =
                state.isPermanentlyDenied
                    ? () => openAppSettings()
                    : () =>
                        context
                            .read<HearAiCubit>()
                            .requestMicrophonePermission();
            buttonColor = AppColors.rawSienna;
          } else if (state is HearAiReadyToRecord) {
            centerContent = _buildIdleUI("Tap to start recording", tapAction);
          } else if (state is HearAiRecording) {
            centerContent = _buildRecordingUI();
            buttonText = "Stop Recording";
            buttonColor = AppColors.paleCarmine;
            tapAction =
                () => context.read<HearAiCubit>().stopAndProcessRecording();
          } else if (state is HearAiProcessing) {
            centerContent = _buildProcessingUI();
            buttonText = "Processing AI...";
            tapAction = null; //? disable button
            showProcessButton = false; //? hide explicit process button
          } else if (state is HearAiSuccess) {
            centerContent = _buildSuccessUI(
              state.transcription,
              state.eventType,
              state.details,
              tapAction,
            );
            //? after success => ready to record again
            // ? if  want a explicit "Process Again" for the same audio, that's a different flow.
            // ?  assumes recording a new chunk.
            tapAction =
                () =>
                    context
                        .read<HearAiCubit>()
                        .startRecording(); //? ready for new recording
          } else if (state is HearAIError) {
            centerContent = _buildErrorUI(state.message);
            tapAction =
                () =>
                    context
                        .read<HearAiCubit>()
                        .initializeAndCheckPermission(); //? retry initialization if error
            buttonText = "Retry Permission/Init";
          } else {
            centerContent = const Text("Unknown State"); //? should not happen
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
                centerContent,
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  onPressed: tapAction,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      // color: AppColors.bittersweet,
                      // color: AppColors.lavender,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          // );
        },
      ),
    );
  }

  Widget _buildIdleUI(String message, void Function()? onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Lottie.asset(
            height: 250,
            "assets/images/ai_processing.json",
            errorBuilder: (ctx, err, st) => const CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecordingUI() {
    return Column(
      children: [
        Lottie.asset(
          height: 250,
          "assets/images/ai_processing-2.json",
          errorBuilder: (ctx, err, st) => const CircularProgressIndicator(),
        ),
        const SizedBox(height: 8),

        const Text(
          "Recording...",
          style: TextStyle(fontSize: 18, color: AppColors.bittersweet),
        ),
      ],
    );
  }

  Widget _buildProcessingUI() {
    return Column(
      children: [
        Lottie.asset(
          height: 250,
          "assets/images/ai_processing-2.json",
          errorBuilder: (ctx, err, st) => const CircularProgressIndicator(),
        ),
        const SizedBox(height: 8),
        const Text(
          "HearAI is thinking...",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.deluge,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessUI(
    String transcription,
    String eventType,
    String details,
    void Function()? onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Lottie.asset(
            height: 250,
            "assets/images/ai_processing.json",
            errorBuilder: (ctx, err, st) => const CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          // width: 200,
          child: Card(
            color: AppColors.haiti,
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "HearAI Analysis:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.bittersweet,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Transcription: $transcription",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lavender,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sound Category: $eventType",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lavender,

                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (details.isNotEmpty && details != "N/A")
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Details: $details",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.columbiaBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI(String message) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          color: AppColors.paleCarmine,
          size: 64.0,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(fontSize: 18, color: AppColors.paleCarmine),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
