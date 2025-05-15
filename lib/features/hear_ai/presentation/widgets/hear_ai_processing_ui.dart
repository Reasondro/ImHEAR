import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class HearAiProcessingUi extends StatelessWidget {
  const HearAiProcessingUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          height: 250,
          "assets/images/ai_processing.json",
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
}
