import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final String statusType; // 'pending', 'done', 'rejected', 'accepted'
  final String type; // 'LOST' or 'FOUND'
  final bool isClaimedTab;
  final VoidCallback onActionPressed;
  final String? customButtonLabel;
  final Color? customStatusColor;

  const StatusItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.statusType,
    required this.type,
    required this.isClaimedTab,
    required this.onActionPressed,
    this.customButtonLabel,
    this.customStatusColor,
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
        case 'urgent':
          statusColor = customStatusColor ?? AppColors.errorRed;
          buttonLabel = customButtonLabel ?? 'Review';
          buttonColor = AppColors.errorRed;
          break;
        case 'pending':
          statusColor = Colors.orange;
          buttonLabel = 'Review';
          buttonColor = Colors.orange;
          break;
        case 'done':
        default:
          statusColor = AppColors.successGreen;
          buttonLabel = 'Done'; // Changed from 'Claimed' to 'Done' for clarity
          buttonColor = AppColors.primaryBlue;
          break;
      }
    }
    
    // Final override checks
    if (customButtonLabel != null) buttonLabel = customButtonLabel!;
    if (customStatusColor != null) statusColor = customStatusColor!;

    final isLostType = type == 'LOST';
    final typeColor = isLostType ? const Color(0xFFFFA000) : AppColors.successGreen;
    final typeLabel = isLostType ? 'LOST' : 'FOUND';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Glass-like opacity
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08), // Subtle blue shadow
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)),
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
                image: imageUrl.startsWith('http') || imageUrl.startsWith('assets') 
                    ? (imageUrl.startsWith('http') ? NetworkImage(imageUrl) : AssetImage(imageUrl)) as ImageProvider
                    : const AssetImage('assets/images/logo.png'),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: typeColor),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: typeColor
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
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
                  gradient: LinearGradient( // Gradient button
                    colors: [buttonColor, buttonColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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

