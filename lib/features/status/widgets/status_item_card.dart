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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
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
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onActionPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

