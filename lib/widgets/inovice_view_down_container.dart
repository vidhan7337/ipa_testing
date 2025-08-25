import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class InoviceViewDownContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const InoviceViewDownContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0x0D000000), width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.grey800Color, size: 20),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: AppTextStyles.bodySmallSemiBoldText(
                    AppColors.grey800Color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
