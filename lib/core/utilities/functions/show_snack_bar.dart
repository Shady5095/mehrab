import 'package:flutter/material.dart';

bool _isSnackBarActive = false;

void showCustomSnackBar(BuildContext context, String text) {
  if (_isSnackBarActive) return;

  _isSnackBarActive = true;

  final scaffoldMessenger = ScaffoldMessenger.of(context);

  scaffoldMessenger
      .showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      )
      .closed
      .then((_) {
        _isSnackBarActive = false; // Reset flag when snackbar disappears
      });
}
