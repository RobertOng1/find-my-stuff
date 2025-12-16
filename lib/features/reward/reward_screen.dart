import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/main_screen.dart';

class RewardScreen extends StatelessWidget {
  final int pointsEarned;
  /// If true, the current user is the owner who lost the item.
  /// If false, the current user is the finder who returned the item.
  final bool isOwner;

  const RewardScreen({super.key, this.pointsEarned = 50, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    // Different messages for owner vs finder
    final String title = isOwner ? 'Great News!' : 'Outstanding!';
    final String subtitle = isOwner
        ? 'Your item has been found and verified! You can now arrange to pick it up.'
        : 'You successfully returned the item to its owner. Great job!';
    final String rewardLabel = isOwner ? 'ITEM RECOVERED' : 'REWARD EARNED';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Deep indigo
              Color(0xFF3949AB), // Indigo
              Color(0xFF1976D2), // Blue
            ],
          ),
        ),
        child: Stack(
          children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon / Illustration
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isOwner ? Icons.celebration_rounded : Icons.emoji_events_rounded,
                        size: 80,
                        color: Colors.amberAccent,
                      ),
                    ).animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .shimmer(delay: 1000.ms, duration: 1500.ms),

                    const SizedBox(height: 48),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 48),

                    // Points Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            rewardLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOwner ? 'Success!' : '+$pointsEarned Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms).scale(curve: Curves.elasticOut),

                    const Spacer(),

                    // Home Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to MainScreen and remove all previous routes
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black26,
                        ),
                        child: const Text(
                          'Return to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
