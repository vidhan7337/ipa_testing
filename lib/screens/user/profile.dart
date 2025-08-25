import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      } else {
        debugPrint('No such user!');
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'name': _nameController.text,
            'phone': _phoneController.text,
          });
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Profile updated successfully',
        AppColors.successColor,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Failed to update profile: $e',
        AppColors.errorColor,
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppAppBar(title: 'Profile'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/editImage.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xffdfdfdf),
                          width: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Name"),
                            CustomTextField(
                              controller: _nameController,
                              hintText: "Your Name",
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              validator: validateName,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel("Phone Number"),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: "Your Phone Number",
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: validatePhone,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel("Email Address"),
                            CustomTextField(
                              readOnly: true,
                              controller: _emailController,
                              hintText: "your@email.com",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              text: "Save Changes",
                              onPressed: _saveChanges,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: AppTextStyles.bodyText(AppColors.grey900Color));
}
