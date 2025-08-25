import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';

class HomeListTile extends StatefulWidget {
  final Color? backgroundColor;
  final Color? surfaceColor;
  final Color? mainColor;
  final String? title;
  final IconData? icon;
  final String? value;
  final VoidCallback? onTap;

  const HomeListTile({
    super.key,
    this.backgroundColor,
    this.surfaceColor,
    this.mainColor,
    this.title,
    this.icon,
    this.value,
    this.onTap,
  });

  @override
  State<HomeListTile> createState() => _HomeListTileState();
}

class _HomeListTileState extends State<HomeListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0x0d000000), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.surfaceColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Icon(
                      size: 15,
                      widget.icon,
                      color: AppColors.grey800Color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title ?? '',
                  style: AppTextStyles.bodyText(AppColors.grey800Color),
                ),
              ],
            ),
            Text(
              widget.value ?? "",
              style: AppTextStyles.bodyTitleText(
                widget.mainColor ?? AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
