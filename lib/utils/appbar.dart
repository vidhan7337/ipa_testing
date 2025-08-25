import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.grey800Color),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: false,
      title: Text(
        title,
        style: AppTextStyles.appbarTitleText(AppColors.grey800Color),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
