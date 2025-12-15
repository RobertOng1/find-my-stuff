import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:find_my_stuff/features/auth/login_screen.dart';
import 'package:find_my_stuff/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
            .animate()
            .fade(duration: 800.ms)
            .scale(duration: 800.ms, curve: Curves.easeOutBack)
            .shimmer(delay: 800.ms, duration: 1200.ms, color: const Color(0xFFC5A059)), // Gold shimmer

            const SizedBox(height: 24),

            // Text Animation
            Text(
              'FindMyStuff',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    letterSpacing: 1.5,
                  ),
            )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .moveY(begin: 20, end: 0, delay: 1000.ms, duration: 600.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
