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

class EditLibrary extends StatefulWidget {
  final LibraryModel? libraryModel;
  const EditLibrary({super.key, required this.libraryModel});

  @override
  State<EditLibrary> createState() => _EditLibraryState();
}

class _EditLibraryState extends State<EditLibrary> {
  File? _image;
  bool _isUploading = false;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final model = widget.libraryModel!;
    _nameController.text = model.name ?? '';
    _addressController.text = model.address ?? '';
    _phoneController.text = model.phone ?? '';
    _emailController.text = model.email ?? '';

    if (model.logoUrl != null && model.logoUrl!.isNotEmpty) {
      setState(() => _isUploading = true);
      NetworkImage(model.logoUrl!)
          .resolve(const ImageConfiguration())
          .addListener(
            ImageStreamListener(
              (image, synchronousCall) {
                if (mounted) setState(() => _isUploading = false);
              },
              onError: (exception, stackTrace) {
                if (mounted) setState(() => _isUploading = false);
              },
            ),
          );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child(
        "images/$fileName.jpg",
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

  Future<void> editLibrary() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    String? imageUrl = widget.libraryModel!.logoUrl;
    if (_image != null) {
      imageUrl = await uploadImage(_image!);
      if (imageUrl == null) {
        setState(() => _isUploading = false);
        if (mounted) {
          AppSnackbar.showSnackbar(
            context,
            'Failed to upload image',
            AppColors.errorColor,
          );
        }
        return;
      }
    }

    final lib = LibraryModel(
      id: widget.libraryModel!.id,
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      logoUrl: imageUrl,
    );
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await Provider.of<LibraryProvider>(
      context,
      listen: false,
    ).updatelibrary(uid, lib);
    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Library updated successfully!',
      AppColors.successColor,
    );
    Navigator.pop(context);

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.libraryModel!;
    ImageProvider imageProvider;
    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (model.logoUrl != null && model.logoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(model.logoUrl!);
    } else {
      imageProvider = const AssetImage('assets/images/editImage.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(title: 'Edit Library'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: SingleChildScrollView(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
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
                      const SizedBox(height: 24),
                      _isUploading
                          ? const CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          )
                          : AppButton(
                            text: 'Update Library',
                            onPressed: editLibrary,
                          ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
