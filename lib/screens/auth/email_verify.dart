import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/auth/auth_screen.dart';
import 'package:lib_app/utils/button.dart';

class EmailVerify extends StatefulWidget {
  final String email;
  const EmailVerify({super.key, required this.email});

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  bool _isResending = false;

  Future<void> _resendVerification(BuildContext context) async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(seconds: 2));
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'Verification link sent again',
          AppColors.infoColor,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'Failed to resend verification link',
          AppColors.errorColor,
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _verifyAndContinue(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlueColor,
        title: Text(
          'Verify Your Email',
          style: AppTextStyles.appbarTitleText(AppColors.grey900Color),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: size.height * 0.01),
            padding: const EdgeInsets.all(25.0),
            width: size.width * 0.86,
            decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: const Color(0x0D000000)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.height * 0.1),
                Text(
                  "We've sent a verification link to",
                  style: AppTextStyles.subBodyText(AppColors.grey600Color),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.email,
                  style: AppTextStyles.subBodyText(AppColors.grey900Color),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.05),
                GestureDetector(
                  onTap:
                      _isResending ? null : () => _resendVerification(context),
                  child: Container(
                    width: size.width * 0.4,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: AppColors.grey400Color,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child:
                          _isResending
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send,
                                    color: AppColors.grey400Color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Resend Link",
                                    style: AppTextStyles.subBodyText(
                                      AppColors.grey400Color,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.1),
                AppButton(
                  text: 'Verify And Continue',
                  onPressed: () => _verifyAndContinue(context),
                ),
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
