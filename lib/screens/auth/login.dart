import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/auth/email_verify.dart';
import 'package:lib_app/screens/auth/forgot_password.dart';
import 'package:lib_app/screens/home/home_screen.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field.dart';
import 'package:lib_app/Functions/validators.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (!user.emailVerified) {
        AppSnackbar.showSnackbar(
          context,
          'Please verify your email before proceeding.',
          AppColors.warningColor,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerify(email: user.email!),
          ),
        );
      } else {
        AppSnackbar.showSnackbar(
          context,
          'Login successful',
          AppColors.successColor,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      AppSnackbar.showSnackbar(
        context,
        e.message ?? 'Login failed',
        AppColors.errorColor,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Email Address"),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: "your@email.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 20),
            _buildLabel("Password"),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              hintText: !isPasswordVisible ? "********" : "your_password",
              icon: !isPasswordVisible ? Icons.lock : Icons.lock_open,
              obscureText: !isPasswordVisible,
              onIconPressed:
                  () => setState(() => isPasswordVisible = !isPasswordVisible),
              validator: validatePassword,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage(),
                      ),
                    ),
                child: Text(
                  "Forgot Password?",
                  style: AppTextStyles.bodyText(AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
                : AppButton(text: 'Login', onPressed: _login),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: AppTextStyles.bodyText(AppColors.grey900Color));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
