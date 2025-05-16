import 'package:flutter/material.dart';
import 'package:komunika/app/themes/app_colors.dart';

// * extends  BuildContext class to provide convenient methods for showing custom SnackBars.
extension ContextExtension on BuildContext {
  //? displays a custom general-purpose SnackBar.
  void customShowSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
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
        backgroundColor: AppColors.haiti,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }

  //? displays a custom error-purpose SnackBar.
  void customShowErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
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
        backgroundColor: AppColors.paleCarmine,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }
}
