import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/models/models.dart';
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
  bool _isClaimedTabActive = true; // true = Claimed Item, false = Reported Item

  // Mock Data - Reported Items (items I posted as FOUND, waiting for claimants)
  final List<Map<String, dynamic>> _reportedItems = [
    {
      'id': '1',
      'title': 'iPhone 13 Pro',
      'imageUrl': 'assets/images/logo.png',
      'status': 'Pending Review',
      'statusType': 'pending', // pending = has claimant to review
    },
    {
      'id': '2',
      'title': 'Blue Wallet',
      'imageUrl': 'assets/images/logo.png',
      'status': 'Claimed',
      'statusType': 'done', // done = already claimed by someone
    },
  ];

  // Mock Data - Claimed Items (items I claimed as LOST, waiting for finder approval)
  final List<Map<String, dynamic>> _claimedItems = [
    {
      'id': '1',
      'title': 'Blue Blackpack',
      'imageUrl': 'assets/images/logo.png',
      'status': 'Status Rejected',
      'statusType': 'rejected', // rejected, accepted, pending
    },
    {
      'id': '2',
      'title': 'Fruits',
      'imageUrl': 'assets/images/logo.png',
      'status': 'Status Accepted',
      'statusType': 'accepted',
    },
    {
      'id': '3',
      'title': 'Wallet',
      'imageUrl': 'assets/images/logo.png',
      'status': 'Pending Verification',
      'statusType': 'pending',
    },
  ];

  void _handleReportedItemAction(Map<String, dynamic> item) {
    if (item['statusType'] == 'pending') {
      // Navigate to VerificationScreen to verify claimant first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificationScreen(),
        ),
      );
    } else {
      // Already claimed - show info
      UiUtils.showModernSnackBar(context, 'This item has been claimed successfully.');
    }
  }

  void _handleClaimedItemAction(Map<String, dynamic> item) {
    if (item['statusType'] == 'rejected') {
      // Show rejection dialog
      showDialog(
        context: context,
        builder: (context) => const ClaimRejectedDialog(),
      );
    } else if (item['statusType'] == 'accepted') {
      // Show accepted dialog
      showDialog(
        context: context,
        builder: (context) => const ClaimAcceptedDialog(),
      );
    } else {
      // Pending - show info
      UiUtils.showModernSnackBar(context, 'Waiting for finder to verify your claim...', isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of items to display
    final items = _isClaimedTabActive ? _claimedItems : _reportedItems;

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
                                    ? AppColors.textDark 
                                    : AppColors.primaryBlue.withOpacity(0.6), // Changed from white to blue for contrast
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
                                    ? AppColors.textDark 
                                    : AppColors.primaryBlue.withOpacity(0.6), // Changed from white to blue for contrast
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
            
            const SizedBox(height: 24),
            
            // Item List
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return StatusItemCard(
                          title: item['title'],
                          imageUrl: item['imageUrl'],
                          status: item['status'],
                          statusType: item['statusType'],
                          isClaimedTab: _isClaimedTabActive,
                          onActionPressed: () {
                            if (_isClaimedTabActive) {
                              _handleClaimedItemAction(item);
                            } else {
                              _handleReportedItemAction(item);
                            }
                          },
                        );
                      },
                    ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            _isClaimedTabActive ? 'No claimed items' : 'No reported items',
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
