import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final Color? color;
  final VoidCallback onPressed;
  final String? text;

  const SocialLoginButton({
    super.key,
    this.icon,
    this.imagePath,
    this.color,
    required this.onPressed,
    this.text,
  }) : assert(icon != null || imagePath != null, 'Either icon or imagePath must be provided');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: text != null ? double.infinity : 80,
        height: 56,
        padding: text != null ? const EdgeInsets.symmetric(horizontal: 24) : null,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: text != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imagePath != null)
                    Image.asset(imagePath!, height: 24, width: 24)
                  else
                    Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    text!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              )
            : Center(
                child: imagePath != null
                    ? Image.asset(imagePath!, height: 32, width: 32)
                    : Icon(icon, color: color, size: 32),
              ),
      ),
    );
  }
}
