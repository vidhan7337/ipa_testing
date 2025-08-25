import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class DropDownTextField extends StatelessWidget {
  final String hintText;
  final List<DropdownMenuItem<dynamic>>? Item;
  final dynamic value;
  final ValueChanged<dynamic>? onChanged;
  final FormFieldValidator<dynamic>? validator;
  const DropDownTextField({
    super.key,
    required this.hintText,
    required this.Item,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      isExpanded: true,
      decoration: InputDecoration(
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
      value: value,
      items: Item,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      style: AppTextStyles.bodyTitleText2(AppColors.grey900Color),
      validator: validator,
      onChanged: onChanged,
      menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
    );
  }
}
