import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';

extension ContextExtension on BuildContext {
  void customShowSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            // color: Theme.of(this).colorScheme.onPrimary,
            color: AppColors.white,
            fontSize: 15,
          ),
          textAlign: TextAlign.left,
        ),
        padding: const EdgeInsets.only(
          bottom: 14,
          top: 14,
          right: 14,
          left: 14,
        ),
        margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
        behavior: SnackBarBehavior.floating,
        // backgroundColor: Theme.of(this).colorScheme.primary,
        backgroundColor: AppColors.haiti,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }

  void customShowErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            // color: Theme.of(this).colorScheme.onError,
            color: AppColors.white,
            fontSize: 15,
          ),
          textAlign: TextAlign.left,
        ),
        padding: const EdgeInsets.only(
          bottom: 14,
          top: 14,
          right: 14,
          left: 14,
        ),
        margin: const EdgeInsets.only(bottom: 10, left: 14, right: 14),
        behavior: SnackBarBehavior.floating,
        // backgroundColor: Theme.of(this).colorScheme.error,
        backgroundColor: AppColors.paleCarmine,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }
}
