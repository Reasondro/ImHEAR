import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'package:lottie/lottie.dart';

class HearAiErrorUi extends StatelessWidget {
  final String message;
  final void Function() onTap;

  const HearAiErrorUi({required this.message, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.paleCarmine,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, color: AppColors.white),
          ),
          onPressed: onTap,
          child: const Text(
            "Retry Permission/Init",
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
