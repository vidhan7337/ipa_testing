import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class TabContainer extends StatelessWidget {
  final String title;
  final bool isSelected;
  const TabContainer({
    super.key,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyTitleText(
            isSelected ? AppColors.primaryColor : AppColors.grey600Color,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 2,
          color: isSelected ? AppColors.primaryColor : Color(0xFFe9e9e9),
        ),
      ],
    );
  }
}
