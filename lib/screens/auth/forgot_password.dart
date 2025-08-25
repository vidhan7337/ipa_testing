import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field_label.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Password reset link sent! Check your email.',
        AppColors.successColor,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.showSnackbar(
        context,
        e.message ?? "An error occurred.",
        AppColors.errorColor,
      );
    } catch (e) {
      AppSnackbar.showSnackbar(
        context,
        "Error: ${e.toString()}",
        AppColors.errorColor,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppAppBar(title: "Forgot Password"),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * 0.1),
                  Text(
                    "Enter your email to reset password",
                    style: AppTextStyles.bodyTitleText(AppColors.grey900Color),
                  ),
                  const SizedBox(height: 30),
                  CustomLLabelTextField(
                    controller: _emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator(color: AppColors.primaryColor)
                      : AppButton(
                        text: 'Send Reset Link',
                        onPressed: _resetPassword,
                      ),
                  SizedBox(height: size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
