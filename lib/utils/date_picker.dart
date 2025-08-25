import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/colors.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(now.year - 100),
    lastDate: lastDate ?? DateTime(now.year + 100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor, // header background color
            onPrimary: Colors.white, // header text color
            onSurface: AppColors.grey900Color, // body text color
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor, // button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
