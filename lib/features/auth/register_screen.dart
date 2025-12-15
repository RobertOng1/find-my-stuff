import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_login_button.dart';
import '../../widgets/auth_background_painters.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Waves
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.3,
            child: CustomPaint(
              painter: TopWavePainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.2,
            child: CustomPaint(
              painter: BottomWavePainter(),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryBlue),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Title
                    Text(
                      'Hello! Register to get\nstarted',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Form
                    const CustomTextField(
                      hintText: 'Username',
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      hintText: 'Confirm password',
                      isPassword: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Register Button
                    CustomButton(
                      text: 'Register',
                      onPressed: () {},
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Or Register with
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE8ECF4))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or Register with',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE8ECF4))),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.facebook,
                            color: const Color(0xFF1877F2),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            color: const Color(0xFFDB4437),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: AppColors.textDark),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login Now',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
