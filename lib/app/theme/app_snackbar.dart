import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';

class AppSnackbar {
  static void showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: backgroundColor,
        content: Text(message, style: AppTextStyles.bodyText(Colors.white)),
      ),
    );
  }
}
