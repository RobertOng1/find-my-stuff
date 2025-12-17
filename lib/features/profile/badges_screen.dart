import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/models.dart';

class BadgesScreen extends StatelessWidget {
  final List<String> userBadges;

  const BadgesScreen({super.key, required this.userBadges});

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
          'My Badges',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Adjusted to prevent overflow
        ),
        itemCount: BadgeConstants.allBadges.length,
        itemBuilder: (context, index) {
          final badge = BadgeConstants.allBadges[index];
          final isUnlocked = userBadges.contains(badge.id);
          final color = isUnlocked ? Color(badge.colorValue) : Colors.grey;
          final bgStart = isUnlocked ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1);
          final bgEnd = isUnlocked ? color.withOpacity(0.05) : Colors.white;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgStart, bgEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnlocked ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    IconData(badge.iconCodePoint, fontFamily: 'MaterialIcons'),
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isUnlocked ? AppColors.textDark : Colors.grey,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'How to Unlock:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                 const SizedBox(height: 4),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked ? AppColors.textGrey : Colors.grey.withOpacity(0.7),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isUnlocked) ...[
                   const SizedBox(height: 8),
                   const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
