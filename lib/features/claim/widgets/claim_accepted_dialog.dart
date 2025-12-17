import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/models/models.dart';
import '../../../core/services/firestore_service.dart';
import '../../chat/chat_screen.dart';
import 'digital_receipt_dialog.dart';

class ClaimAcceptedDialog extends StatelessWidget {
  final ClaimModel claim;
  final ItemModel item;

  const ClaimAcceptedDialog({
    super.key,
    required this.claim,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF27AE60), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Claim Accepted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Great news! Your ownership has been verified. You can now arrange pickup with the finder.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            // Pickup Instructions Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem('Location: ${item.location}'),
                  _buildInstructionItem('Contact finder for specific time'),
                  _buildInstructionItem('Bring digital pass below for verification'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Send Pickup Details Button (Chat)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final firestoreService = FirestoreService();
                  
                  // Show loading
                  UiUtils.showModernSnackBar(context, 'Connecting to finder...');
                  
                  try {
                    // Create or get existing chat
                    final chatId = await firestoreService.createChat(
                      itemId: item.id,
                      itemName: item.title,
                      claimantId: claim.claimantId,
                      finderId: claim.finderId,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      
                      // Navigate to Chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            itemId: item.id,
                            itemName: item.title,
                            otherUserId: claim.finderId, // Chatting with Finder
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                     if (context.mounted) {
                        UiUtils.showModernSnackBar(context, 'Error starting chat: $e', isSuccess: false);
                     }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Chat with Finder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // View Digital Pass Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                   Navigator.pop(context); // Close this dialog
                   showDialog(
                     context: context,
                     builder: (context) => DigitalReceiptDialog(claim: claim, item: item),
                   );
                },
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: const Text('View Digital Pass'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
