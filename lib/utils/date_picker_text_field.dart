import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class DatePickerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  const DatePickerTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        suffixIcon: Icon(
          Icons.calendar_today,
          size: 20,
          color: AppColors.grey500Color,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xffe2e2e2), width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xffe2e2e2), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
        ),
        labelText: hintText,
        labelStyle: AppTextStyles.bodyText(AppColors.grey400Color),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
