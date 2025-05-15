import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class HearAiRecordingUi extends StatelessWidget {
  final void Function() onTap;
  const HearAiRecordingUi({required this.onTap, super.key});

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
          "Tap to stop listening",
          style: TextStyle(fontSize: 18, color: AppColors.bittersweet),
        ),
        const SizedBox(height: 8),

        const Text(
          "Listening...",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }
}
