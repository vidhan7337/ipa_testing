import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/auth/auth_screen.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'role': 'admin',
            'createdAt': DateTime.now(),
          });

      await userCredential.user!.sendEmailVerification();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentLibraryName', 'null');
      await prefs.setString('currentLibraryId', 'null');
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Registration successful! Please verify your email.',
        AppColors.successColor,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        e.message ?? 'Registration failed',
        AppColors.errorColor,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabelField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyText(AppColors.grey900Color)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabelField(
                label: "Name",
                field: CustomTextField(
                  controller: _nameController,
                  hintText: "Your Name",
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: validateName,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabelField(
                label: "Phone Number",
                field: CustomTextField(
                  controller: _phoneController,
                  hintText: "Your Phone Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: validatePhone,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabelField(
                label: "Email Address",
                field: CustomTextField(
                  controller: _emailController,
                  hintText: "your@email.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabelField(
                label: "Password",
                field: CustomTextField(
                  controller: _passwordController,
                  hintText: !_isPasswordVisible ? "********" : "your_password",
                  icon: !_isPasswordVisible ? Icons.lock : Icons.lock_open,
                  obscureText: !_isPasswordVisible,
                  onIconPressed:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                  textInputAction: TextInputAction.next,
                  validator: validatePassword,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabelField(
                label: "Confirm Password",
                field: CustomTextField(
                  controller: _confirmPasswordController,
                  hintText:
                      !_isConfirmPasswordVisible ? "********" : "your_password",
                  icon:
                      !_isConfirmPasswordVisible ? Icons.lock : Icons.lock_open,
                  obscureText: !_isConfirmPasswordVisible,
                  onIconPressed:
                      () => setState(
                        () =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                      ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                  : AppButton(text: 'Register', onPressed: _register),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
