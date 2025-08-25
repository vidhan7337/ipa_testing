// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class CustomLLabelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onIconPressed;
  final int maxLines;
  final bool? readOnly;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLength;
  final TextCapitalization? textCapitalization;

  const CustomLLabelTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onIconPressed,
    this.maxLines = 1,
    this.readOnly = false,
    this.initialValue,
    this.onChanged,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLength,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly ?? false,
      initialValue: initialValue,
      decoration: InputDecoration(
        suffixIcon:
            suffixIcon != null
                ? IconButton(
                  onPressed: onSuffixIconPressed,
                  icon: Icon(
                    suffixIcon,
                    size: 20,
                    color: AppColors.grey500Color,
                  ),
                )
                : null,
        prefixIcon:
            icon != null
                ? IconButton(
                  onPressed: onIconPressed,
                  icon: Icon(icon, size: 20, color: AppColors.grey500Color),
                )
                : null,
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
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
