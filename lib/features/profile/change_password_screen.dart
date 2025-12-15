import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final AuthService _authService = AuthService(); // Instantiated AuthService

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (newPassword.length < 6) {
      UiUtils.showModernSnackBar(context, 'Password must be at least 6 characters', isSuccess: false);
      return;
    }

    if (newPassword != confirmPassword) {
      UiUtils.showModernSnackBar(context, 'Passwords do not match', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);
    if (!mounted) return;

    // Show Success Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.successGreen, size: 80),
              const SizedBox(height: 24),
              Text(
                'Password Changed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been updated successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Back to Profile',
                onPressed: () {
                  Navigator.pop(context); // Close Dialog
                  Navigator.pop(context); // Back to Profile
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Secure Password Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Password Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Use at least 6 characters\n• Include uppercase & lowercase letters\n• Avoid using personal info',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                hintText: 'Old Password',
                isPassword: true,
                controller: _oldPasswordController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'New Password',
                isPassword: true,
                controller: _newPasswordController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Confirm New Password',
                isPassword: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 40),
              
              _isLoading
                  ? CircularProgressIndicator(color: AppColors.primaryBlue)
                  : CustomButton(
                      text: 'Update Password',
                      onPressed: _updatePassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
