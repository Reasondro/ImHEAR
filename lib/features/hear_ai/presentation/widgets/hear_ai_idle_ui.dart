import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class HearAiIdleUi extends StatelessWidget {
  const HearAiIdleUi({
    required this.onTap,
    required this.permissionNeeded,
    this.buttonText,
    super.key,
  });

  final void Function() onTap;
  final bool permissionNeeded;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Lottie.asset(
            height: 250,
            "assets/images/ai_idle.json",
            errorBuilder: (ctx, err, st) => const CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 8),
        if (!permissionNeeded)
          // ? if permission not needed than these below are the widgets
          const Text(
            "Tap to start listening",
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        if (permissionNeeded) ...[
          // ? if permission needed than these below are the widgets
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: AppColors.rawSienna,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
