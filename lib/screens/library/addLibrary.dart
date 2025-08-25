import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/library_model.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';

class AddLibrary extends StatefulWidget {
  const AddLibrary({super.key});

  @override
  State<AddLibrary> createState() => _AddLibraryState();
}

class _AddLibraryState extends State<AddLibrary> {
  File? _image;
  bool _isUploading = false;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'images/$fileName',
      );
      final taskSnapshot = await storageRef.putFile(imageFile);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      AppSnackbar.showSnackbar(
        context,
        'Upload Error: $e',
        AppColors.errorColor,
      );
      return null;
    }
  }

  Future<void> _addLibraryData() async {
    if (_image == null) {
      AppSnackbar.showSnackbar(
        context,
        'Please select an image',
        AppColors.errorColor,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final imageUrl = await _uploadImage(_image!);
    if (imageUrl != null) {
      final lib = LibraryModel(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        logoUrl: imageUrl,
      );
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || !mounted) return;
      await Provider.of<LibraryProvider>(
        context,
        listen: false,
      ).addlibrary(uid, lib);
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Library added successfully',
        AppColors.successColor,
      );
      Navigator.pop(context);
    } else {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'Failed to upload image',
          AppColors.errorColor,
        );
      }
    }
    if (mounted) setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(title: 'Add Library'),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                _image != null
                                    ? FileImage(_image!)
                                    : const AssetImage(
                                          'assets/images/editImage.png',
                                        )
                                        as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xffdfdfdf),
                            width: 3,
                          ),
                        ),
                      ),
                      if (_isUploading)
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomLLabelTextField(
                        controller: _nameController,
                        hintText: 'Library Name',
                        icon: Icons.library_books,
                        validator: validateName,
                      ),
                      const SizedBox(height: 10),
                      CustomLLabelTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 10),
                      CustomLLabelTextField(
                        controller: _phoneController,
                        hintText: 'Phone Number',
                        icon: Icons.phone,
                        validator: validatePhone,
                      ),
                      const SizedBox(height: 10),
                      CustomLLabelTextField(
                        controller: _addressController,
                        hintText: 'Address',
                        icon: Icons.location_on,
                        maxLines: 4,
                        validator: validateStringField,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _isUploading
                    ? const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    )
                    : AppButton(
                      text: 'Add Library',
                      onPressed: _addLibraryData,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
