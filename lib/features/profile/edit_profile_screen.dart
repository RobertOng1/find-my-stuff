import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/image_picker_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isLoading = false;
  XFile? _pickedImage;
  
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerHelper.pickImage(context);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      UiUtils.showModernSnackBar(context, 'Name cannot be empty', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String photoUrl = widget.user.photoUrl;

      // 1. Upload new image if picked
      if (_pickedImage != null) {
        photoUrl = await _storageService.uploadImage(_pickedImage!, 'profiles');
      }

      // 2. Update Firebase Auth Display Name & Photo (for consistency)
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
         if (_nameController.text.trim() != currentUser.displayName) {
           await currentUser.updateDisplayName(_nameController.text.trim());
         }
         if (photoUrl != widget.user.photoUrl) {
           await currentUser.updatePhotoURL(photoUrl);
         }
      }

      // 3. Update Firestore
      final updatedUser = UserModel(
        uid: widget.user.uid,
        email: widget.user.email,
        displayName: _nameController.text.trim(),
        photoUrl: photoUrl,
        phoneNumber: _phoneController.text.trim(),
        trustScore: widget.user.trustScore,
        points: widget.user.points,
        badges: widget.user.badges,
      );

      await _firestoreService.updateUserProfile(updatedUser);

      if (mounted) {
        UiUtils.showModernSnackBar(context, 'Profile updated successfully!');
        Navigator.pop(context, true); // Return true to request refresh
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showModernSnackBar(context, 'Failed to update profile: $e', isSuccess: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider _getProfileImage() {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_pickedImage!.path);
      } else {
        return FileImage(File(_pickedImage!.path));
      }
    } else if (widget.user.photoUrl.isNotEmpty) {
      return NetworkImage(widget.user.photoUrl);
    } else {
      return const AssetImage('assets/images/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                           decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 2),
                           ),
                           child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _getProfileImage(),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    hintText: 'Full Name',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    // ReadOnly usually preferred for Email as it's the ID
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
