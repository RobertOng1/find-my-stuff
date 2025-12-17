import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../reward/reward_screen.dart';
import 'widgets/claim_rejected_dialog.dart';

import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/ui_utils.dart';

class VerifyProofScreen extends StatefulWidget {
  final ClaimModel claim;
  final ItemModel item;

  const VerifyProofScreen({
    super.key,
    required this.claim,
    required this.item,
  });

  @override
  State<VerifyProofScreen> createState() => _VerifyProofScreenState();
}

class _VerifyProofScreenState extends State<VerifyProofScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _updateStatus(String status, {String? reason}) async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.updateClaimStatus(widget.claim.id, status, reason: reason);
      
      if (status == 'ACCEPTED') {
        // Also resolve the item
        await _firestoreService.resolveItem(widget.item.id);
      }

      if (mounted) {
        UiUtils.showModernSnackBar(
          context,
          'Claim ${status == 'ACCEPTED' ? 'Accepted' : 'Rejected'}!',
          isSuccess: status == 'ACCEPTED',
        );
        
        if (status == 'ACCEPTED') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RewardScreen(isOwner: true)),
          );
        } else {
          Navigator.pop(context); // Pop VerifyProofScreen
          Navigator.pop(context); // Pop VerificationScreen
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showModernSnackBar(
          context,
          'Error: $e',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRejectionDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection so the claimant can understand what went wrong.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason (e.g., Photos blurry, Incorrect details)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                 UiUtils.showModernSnackBar(context, 'Please enter a reason', isSuccess: false);
                 return;
              }
              Navigator.pop(context); // Close dialog
              _updateStatus('REJECTED', reason: reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Proof',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(widget.item.imageUrl, width: 60, height: 60),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.textGrey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.item.location,
                                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Verifying',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Claimant Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: _getImageProvider(widget.claim.claimantAvatar),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.claim.claimantName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Text(
                            'Claimant • 4.8★',
                            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryBlue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Claim Details Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Claim Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailField('Item Name', widget.item.title),
                      _buildDetailField('Lost Location', widget.item.location), // Assuming match
                      _buildDetailField('Date Lost', '11/21/2025'), // Mock date
                      _buildDetailField('Distinguishing Features', widget.claim.proofDescription),
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: widget.claim.proofImages.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                              child: _buildImage(
                                widget.claim.proofImages[index],
                                fit: BoxFit.cover,
                              ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _showRejectionDialog, // Updated to show dialog
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isLoading ? 'Processing...' : 'Reject Claim'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _updateStatus('ACCEPTED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(_isLoading ? 'Processing...' : 'Accept Claim'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(url, width: width, height: height, fit: fit, errorBuilder: (context, error, stackTrace) {
          return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey));
      });
    }
    return Image.asset(url, width: width, height: height, fit: fit, errorBuilder: (context, error, stackTrace) {
           return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey));
    });
  }

  ImageProvider _getImageProvider(String url) {
    if (url.isEmpty) return const AssetImage('assets/images/logo.png');
    if (url.startsWith('http')) return NetworkImage(url);
    return AssetImage(url);
  }
}
