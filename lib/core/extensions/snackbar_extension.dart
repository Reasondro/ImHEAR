import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void customShowSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(this).colorScheme.onPrimary,
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
        backgroundColor: Theme.of(this).colorScheme.primary,
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
          style: TextStyle(
            color: Theme.of(this).colorScheme.onError,
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
        backgroundColor: Theme.of(this).colorScheme.error,
        dismissDirection: DismissDirection.horizontal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }
}
