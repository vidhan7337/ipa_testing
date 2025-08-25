import 'package:flutter/widgets.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle mainHeading(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    color: color,
    fontWeight: FontWeight.w700,
  );
  static TextStyle subHeading(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: color,
    fontWeight: FontWeight.w500,
  );
  static TextStyle bodyTitleText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: color,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodyTitleText2(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: color,
    fontWeight: FontWeight.w500,
  );
  static TextStyle bodyText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: color,
    fontWeight: FontWeight.w500,
  );
  static TextStyle subBodyText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: color,
    fontWeight: FontWeight.w600,
  );
  static TextStyle appbarTitleText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: color,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodySmallSemiBoldText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: color,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodySmallText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: color,
    fontWeight: FontWeight.w500,
  );
  static TextStyle smallText(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: color,
    fontWeight: FontWeight.w600,
  );
}
