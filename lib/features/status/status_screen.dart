import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../claim/verification_screen.dart';
import '../claim/widgets/claim_accepted_dialog.dart';
import '../claim/widgets/claim_rejected_dialog.dart';
import '../reward/reward_screen.dart';
import 'widgets/status_item_card.dart';
import '../../widgets/animated_gradient_bg.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isClaimedTabActive = false; // true = Claimed by me (LOST), false = Reported by me (FOUND)
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.uid;
  }

  // --- Logic for Reported Items (My Posts) ---
  
  // --- Logic for Reported Items (My Posts) ---
  
  void _handleReportedItemAction(ItemModel item) async {
    // 1. Fetch claims to determine state
    if (!mounted) return;
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final claims = await _firestoreService.getClaimsForItem(item.id).first;
      if (!mounted) return;
      Navigator.pop(context); // Close loader

      final acceptedClaim = claims.where((c) => c.status == 'ACCEPTED').firstOrNull;
      final pendingClaims = claims.where((c) => c.status == 'PENDING').toList();

      if (acceptedClaim != null && item.status != 'RESOLVED') {
        // Case: Handover Pending
        await _showCompletionDialog(item, acceptedClaim);
      } else if (pendingClaims.isNotEmpty) {
        // Case: Pending Verification
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              item: item,
              claim: pendingClaims.first, // Pass the first pending claim
            ),
          ),
        );
      } else {
        // Case: No claims or just viewing history
        if (item.status == 'RESOLVED') {
          UiUtils.showModernSnackBar(context, 'This item is resolved.');
        } else {
          UiUtils.showModernSnackBar(context, 'No pending requests to review.', isSuccess: true);
        }
      }
    } catch (e) {
      if (mounted) {
        // close loader if it was likely still open (simplified assumption)
        // But we already popped it.
        UiUtils.showModernSnackBar(context, 'Error loading claims: $e', isSuccess: false);
      }
    }
  }

  Future<void> _showCompletionDialog(ItemModel item, ClaimModel claim) async {
    return showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirm Return'),
          content: const Text('Has this item been successfully returned to the owner? This will mark the item as Resolved and award points.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                try {
                  // Complete transaction
                  final newBadges = await _firestoreService.completeReturnTransaction(
                    itemId: item.id,
                    claimId: claim.id,
                    finderId: _currentUserId!,
                  );
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RewardScreen(
                          pointsEarned: 100, // Standard reward
                          isOwner: false, // This is the Finder
                          newBadges: newBadges,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                   if (mounted) UiUtils.showModernSnackBar(context, 'Error: $e', isSuccess: false);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
  }

  // --- Logic for Claimed Items (Items I found/claimed) ---

  void _handleClaimedItemAction(ClaimModel claim, ItemModel item) async {
    if (claim.status == 'REJECTED') {
      showDialog(
        context: context,
        builder: (context) => ClaimRejectedDialog(reason: claim.rejectionReason),
      );
    } else if (claim.status == 'ACCEPTED') {
      showDialog(
        context: context,
        builder: (context) => ClaimAcceptedDialog(claim: claim, item: item),
      );
    } else if (claim.status == 'COMPLETED') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RewardScreen(
            isOwner: true,
            pointsEarned: 0, // Not relevant for owner
          ),
        ),
      );
    } else {
      UiUtils.showModernSnackBar(context, 'Waiting for finder to verify your claim...', isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Living Background
          const AnimatedGradientBg(),
          
          // 2. Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Glass Segmented Control
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glass effect
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isClaimedTabActive = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isClaimedTabActive 
                                  ? Colors.white 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isClaimedTabActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Reported Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isClaimedTabActive 
                                    ? AppColors.primaryBlue.withOpacity(0.6) 
                                    : AppColors.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isClaimedTabActive = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isClaimedTabActive 
                                  ? Colors.white 
                                  : Colors.transparent,
                                   borderRadius: BorderRadius.circular(12),
                              boxShadow: _isClaimedTabActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Claimed Items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isClaimedTabActive 
                                    ? AppColors.primaryBlue.withOpacity(0.6) 
                                    : AppColors.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
            
                // Item List via StreamBuilder
                Expanded(
                  child: _isClaimedTabActive
                      ? _buildClaimedList()
                      : _buildReportedList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportedList() {
    return StreamBuilder<List<ItemModel>>(
      stream: _firestoreService.getUserPosts(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
          ));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptyState('No reported items');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            
            // Wrap with StreamBuilder to check for pending claims
            return StreamBuilder<List<ClaimModel>>(
              stream: _firestoreService.getClaimsForItem(item.id),
              builder: (context, claimSnapshot) {
                int pendingCount = 0;
                int acceptedCount = 0;
                if (claimSnapshot.hasData) {
                  pendingCount = claimSnapshot.data!.where((c) => c.status == 'PENDING').length;
                  acceptedCount = claimSnapshot.data!.where((c) => c.status == 'ACCEPTED').length;
                }

                String displayStatus = item.status == 'RESOLVED' ? 'Done' : 'Active';
                String statusType = item.status == 'RESOLVED' ? 'done' : 'pending';
                
                // Override if claims exist
                String? customButtonLabel;
                Color? customStatusColor;
                
                if (item.status != 'RESOLVED') {
                  if (acceptedCount > 0) {
                     displayStatus = 'Handover Pending';
                     statusType = 'urgent'; 
                     customButtonLabel = 'Complete';
                     customStatusColor = AppColors.primaryBlue;
                  } else if (pendingCount > 0) {
                     displayStatus = '$pendingCount Request${pendingCount > 1 ? 's' : ''}';
                     statusType = 'urgent';
                     customButtonLabel = 'Review ($pendingCount)';
                     customStatusColor = AppColors.errorRed;
                  }
                }

                return StatusItemCard(
                  title: item.title,
                  imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/images/logo.png',
                  status: displayStatus,
                  statusType: statusType,
                  type: item.type,
                  isClaimedTab: false,
                  customButtonLabel: customButtonLabel,
                  customStatusColor: customStatusColor,
                  onActionPressed: () => _handleReportedItemAction(item),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildClaimedList() {
    return StreamBuilder<List<ClaimModel>>(
      stream: _firestoreService.getClaimsForUser(_currentUserId!),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("🚨 Firestore Error (Claimed List): ${snapshot.error}"); // Log for clickable link
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
          ));
        }

        final claims = snapshot.data ?? [];
        if (claims.isEmpty) {
          return _buildEmptyState('No claimed items');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final claim = claims[index];
            
            return FutureBuilder<ItemModel?>(
              future: _firestoreService.getItem(claim.itemId),
              builder: (context, itemSnapshot) {
                if (!itemSnapshot.hasData) return const SizedBox(); // Loading or null
                
                final item = itemSnapshot.data!;
                String displayStatus = '';
                String statusType = '';

                switch (claim.status) {
                  case 'PENDING':
                    displayStatus = 'Pending Verification';
                    statusType = 'pending';
                    break;
                  case 'ACCEPTED':
                     displayStatus = 'Status Accepted';
                     statusType = 'accepted';
                     break;
                  case 'COMPLETED':
                     displayStatus = 'Handover Complete';
                     statusType = 'done';
                     break;
                  case 'REJECTED':
                     displayStatus = 'Status Rejected';
                     statusType = 'rejected';
                     break;
                  default:
                     displayStatus = claim.status; // Show actual status if unknown
                     statusType = 'pending';
                }

                return StatusItemCard(
                  title: item.title,
                  imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/images/logo.png',
                  status: displayStatus,
                  statusType: statusType,
                  type: item.type,
                  isClaimedTab: true,
                  onActionPressed: () => _handleClaimedItemAction(claim, item),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
