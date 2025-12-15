import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final String statusType; // 'pending', 'done', 'rejected', 'accepted'
  final bool isClaimedTab;
  final VoidCallback onActionPressed;

  const StatusItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.statusType,
    required this.isClaimedTab,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors and labels based on tab and status
    Color statusColor;
    String buttonLabel;
    Color buttonColor;

    if (isClaimedTab) {
      // Claimed Item tab - user is claimant
      switch (statusType) {
        case 'rejected':
          statusColor = AppColors.errorRed;
          buttonLabel = 'Rejected';
          buttonColor = AppColors.errorRed;
          break;
        case 'accepted':
          statusColor = AppColors.successGreen;
          buttonLabel = 'Claimed';
          buttonColor = AppColors.primaryBlue;
          break;
        case 'pending':
        default:
          statusColor = Colors.orange;
          buttonLabel = 'Pending';
          buttonColor = Colors.orange;
          break;
      }
    } else {
      // Reported Item tab - user is finder
      switch (statusType) {
        case 'pending':
          statusColor = Colors.orange;
          buttonLabel = 'Review';
          buttonColor = Colors.orange;
          break;
        case 'done':
        default:
          statusColor = AppColors.successGreen;
          buttonLabel = 'Claimed';
          buttonColor = AppColors.primaryBlue;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Circular Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

