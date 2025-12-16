import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../claim/verification_screen.dart';
import '../claim/widgets/claim_accepted_dialog.dart';
import '../claim/widgets/claim_rejected_dialog.dart';
import 'widgets/status_item_card.dart';
import '../../widgets/animated_gradient_bg.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isClaimedTabActive = true; // true = Claimed by me (LOST), false = Reported by me (FOUND)
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.uid;
  }

  // --- Logic for Reported Items (My Posts) ---
  
  void _handleReportedItemAction(ItemModel item) {
    // Check if there are any PENDING claims for this item
    // We navigate to a specific logic or show snackbar
    // For V1, let's assume if status is 'OPEN' but has pending claims -> Go Verify
    // If status is 'RESOLVED' -> Show Done
    
    // We need to know if there are pending claims. Ideally this is passed or fetched.
    // For now, let's fetch claims for this item on demand
    
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    _firestoreService.getClaimsForItem(item.id).first.then((claims) {
        if (!mounted) return;
        Navigator.pop(context); // Close loader
        
        // Find pending claim
        final pendingClaims = claims.where((c) => c.status == 'PENDING').toList();
        
        if (pendingClaims.isNotEmpty) {
           // Go to verification for the first pending claim
           // In real app, might show list of claimants if multiple
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                claim: pendingClaims.first,
                item: item,
              ),
            ),
          );
        } else {
           if (item.status == 'RESOLVED') {
             UiUtils.showModernSnackBar(context, 'Item marked as resolved.');
           } else {
             UiUtils.showModernSnackBar(context, 'No pending claims yet.', isSuccess: true);
           }
        }
    });
  }

  // --- Logic for Claimed Items (Items I found/claimed) ---

  void _handleClaimedItemAction(ClaimModel claim) async {
    if (claim.status == 'REJECTED') {
      showDialog(
        context: context,
        builder: (context) => const ClaimRejectedDialog(),
      );
    } else if (claim.status == 'ACCEPTED') {
      showDialog(
        context: context,
        builder: (context) => const ClaimAcceptedDialog(),
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
          print("🚨 Firestore Error (Reported List): ${snapshot.error}"); // Log for clickable link
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
            
            String displayStatus = item.status == 'RESOLVED' ? 'Done' : 'Active';
            String statusType = item.status == 'RESOLVED' ? 'done' : 'pending';
            
            return StatusItemCard(
              title: item.title,
              imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/images/logo.png',
              status: displayStatus,
              statusType: statusType,
              type: item.type,
              isClaimedTab: false,
              onActionPressed: () => _handleReportedItemAction(item),
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
                  case 'REJECTED':
                     displayStatus = 'Status Rejected';
                     statusType = 'rejected';
                     break;
                  default:
                     displayStatus = 'Unknown';
                     statusType = 'pending';
                }

                return StatusItemCard(
                  title: item.title,
                  imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/images/logo.png',
                  status: displayStatus,
                  statusType: statusType,
                  type: item.type,
                  isClaimedTab: true,
                  onActionPressed: () => _handleClaimedItemAction(claim),
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
