import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'verify_proof_screen.dart';
import 'widgets/claim_rejected_dialog.dart';
import '../../core/models/models.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

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
          'Verify Claimant',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Item Header
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'), // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blue Backpack',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            Text(
                              'Found in University Library',
                              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Claimant Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage('assets/images/logo.png'), // Placeholder
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Farras Prasetya',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Verified',
                                            style: TextStyle(fontSize: 10, color: AppColors.primaryBlue),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '@farrasonly',
                                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Stats
                          Row(
                            children: [
                              _buildStatBadge(Icons.star, '4.8', 'Rating', const Color(0xFFE3F2FD), const Color(0xFF64B5F6)),
                              const SizedBox(width: 8),
                              _buildStatBadge(Icons.check_circle, '39', 'Returns', const Color(0xFFE8F5E9), const Color(0xFF81C784)),
                              const SizedBox(width: 8),
                              _buildStatBadge(Icons.emoji_events, 'Level 2', 'Member', const Color(0xFFFFF3E0), const Color(0xFFFFB74D)),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          _buildVerificationRow(Icons.email_outlined, 'Email Verified', true),
                          const SizedBox(height: 8),
                          _buildVerificationRow(Icons.phone_outlined, 'Phone Verified', true),
                          const SizedBox(height: 8),
                          _buildVerificationRow(Icons.badge_outlined, 'ID Verified', true),
                          
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user, color: AppColors.successGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'High Trust Score\nThis user has a verified account with excellent history.',
                                    style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Claim Details Card
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Claim Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Item Name', 'Blue Backpack', 'Blue Backpack'),
                          const Divider(height: 24),
                          _buildDetailRow('Location', 'Library', 'University Library'),
                          const Divider(height: 24),
                          _buildDetailRow('Date Lost', '11/21/2025', '11/21/2025'),
                          const Divider(height: 24),
                          const Text(
                            'Distinguishing Features',
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Navy blue with red zipper pulls. Has a small tear on the bottom left pocket...',
                            style: TextStyle(fontSize: 14, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Proof Photos
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Proof Photos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
                        childAspectRatio: 1,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'), // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ClaimRejectedDialog(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reject Claimant'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyProofScreen(
                              item: ItemModel(
                                id: '1',
                                userId: 'finder_123',
                                title: 'Blue Backpack',
                                description: 'Old, slightly dirty polo beach backpack',
                                location: 'University Library',
                                imageUrl: 'assets/images/logo.png',
                                type: 'LOST',
                                category: 'Bags',
                                date: DateTime.now(),
                              ),
                              claim: ClaimModel(
                                id: '1',
                                itemId: '1',
                                claimantId: 'claimant_456',
                                finderId: 'finder_123',
                                claimantName: 'Farras Prasetya',
                                claimantAvatar: 'assets/images/logo.png',
                                status: 'PENDING',
                                proofDescription: 'Navy blue with red zipper pulls. Has a small tear on the bottom left pocket. Contains a physics textbook and a water bottle with a green lid.',
                                proofImages: [
                                  'assets/images/logo.png',
                                  'assets/images/logo.png',
                                  'assets/images/logo.png',
                                  'assets/images/logo.png',
                                ],
                                timestamp: DateTime.now(),
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Accept Claim'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label, Color bgColor, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow(IconData icon, String label, bool isVerified) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          ),
        ),
        if (isVerified)
          const Icon(Icons.check_circle, size: 16, color: AppColors.successGreen),
      ],
    );
  }

  Widget _buildDetailRow(String label, String claimedValue, String actualValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                claimedValue,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark),
              ),
            ],
          ),
        ),
        // Optional: Show comparison if needed, for now just showing the claimed value
      ],
    );
  }
}
