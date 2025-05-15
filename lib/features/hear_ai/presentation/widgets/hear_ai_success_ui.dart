import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class HearAiSuccessUi extends StatelessWidget {
  final String transcription;
  final String eventType;
  final String details;

  final void Function() onTap;

  const HearAiSuccessUi({
    required this.transcription,
    required this.eventType,
    required this.details,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        const Text(
          "Tap again to start listening",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
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
}
