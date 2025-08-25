import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class AppTextSpan extends StatelessWidget {
  final String title;
  final String value;

  const AppTextSpan({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: AppTextStyles.bodySmallText(AppColors.grey700Color),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.bodySmallText(AppColors.grey900Color),
            ),
          ],
        ),
      ),
    );
  }
}
