import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';

class Seattabcontainers extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;
  final String text;
  final VoidCallback? onTap;

  const Seattabcontainers({
    super.key,
    required this.textColor,
    required this.backgroundColor,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0x0D000000), width: 1),
          ),
          child: Center(
            child: Text(text, style: AppTextStyles.bodyTitleText(textColor)),
          ),
        ),
      ),
    );
  }
}
