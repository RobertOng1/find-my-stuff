import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget? child;
  const AnimatedGradientBg({super.key, this.child});

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // Ultra-slow, breathing animation (20 seconds)
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Subtle shift from "Paper White" to "Soft Blue"
    // Increased saturation to ensure white glass cards pop against it.
    _colorAnimation = ColorTween(
      begin: const Color(0xFFFFFFFF), 
      end: AppColors.primaryLight.withOpacity(0.15),   // Deeper cool blue
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Vertical gradient is natural (like sky/light)
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF), // Always white at top for status bar clarity
                _colorAnimation.value ?? AppColors.primaryLight.withOpacity(0.15), // Deeper breathing bottom
              ],
              stops: const [0.2, 1.0], // Reduced white area to let blue creep up slightly
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
