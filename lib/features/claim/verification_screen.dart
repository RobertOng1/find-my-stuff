import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'verify_proof_screen.dart';
import 'widgets/claim_rejected_dialog.dart';
import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';

class VerificationScreen extends StatefulWidget { // Renamed logically to VerifyClaimantScreen but keeping file name
  final ClaimModel claim;
  final ItemModel item;

  const VerificationScreen({
    super.key,
    required this.claim,
    required this.item,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _claimant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClaimantData();
  }

  Future<void> _fetchClaimantData() async {
    final user = await _firestoreService.getUser(widget.claim.claimantId);
    if (mounted) {
      setState(() {
        _claimant = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    // Fallback if user load fails
    final displayName = _claimant?.displayName ?? 'Unknown User';
    final email = _claimant?.email ?? 'No email';
    final photoUrl = _claimant?.photoUrl ?? '';
    final trustScore = ((_claimant?.trustScore ?? 0) * 100).toInt();

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
                            image: widget.item.imageUrl.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(widget.item.imageUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: widget.item.imageUrl.isEmpty 
                              ? const Icon(Icons.image, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Found in ${widget.item.location}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                               CircleAvatar(
                                radius: 24,
                                backgroundImage: photoUrl.isNotEmpty 
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage('assets/images/logo.png') as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                                    Text(
                                      email,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                      overflow: TextOverflow.ellipsis,
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
                              _buildStatBadge(Icons.shield_outlined, '$trustScore%', 'Trust Score', const Color(0xFFE3F2FD), const Color(0xFF64B5F6)),
                              const SizedBox(width: 8),
                              _buildStatBadge(Icons.check_circle_outline, '${_claimant?.points ?? 0}', 'Points', const Color(0xFFE8F5E9), const Color(0xFF81C784)),
                              const SizedBox(width: 8),
                              _buildStatBadge(Icons.emoji_events_outlined, '${_claimant?.badges.length ?? 0}', 'Badges', const Color(0xFFFFF3E0), const Color(0xFFFFB74D)),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          _buildVerificationRow(Icons.email_outlined, 'Email Verified', true), // Mock for now
                          const SizedBox(height: 8),
                          _buildVerificationRow(Icons.phone_outlined, 'Phone Verified', false), // Mock
                          
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
                                    'Safe to interact\nUser has a good reputation history.',
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
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to PROOF
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyProofScreen(
                              item: widget.item,
                              claim: widget.claim,
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
                      child: const Text('View Proof'),
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
        Icon(
          isVerified ? Icons.check_circle : Icons.cancel, 
          size: 16, 
          color: isVerified ? AppColors.successGreen : Colors.grey.shade400
        ),
      ],
    );
  }
}
