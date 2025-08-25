import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoContainer extends StatelessWidget {
  final double size;
  final Color boxColor;
  final Color logoColor;

  const LogoContainer({
    Key? key,
    required this.size,
    required this.boxColor,
    required this.logoColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(size * 0.17),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SvgPicture.asset('assets/images/logo.svg', color: logoColor),
    );
  }
}
