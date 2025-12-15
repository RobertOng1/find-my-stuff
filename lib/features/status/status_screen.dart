import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/models.dart';
import '../claim/verification_screen.dart';
import '../claim/widgets/claim_accepted_dialog.dart';
import '../claim/widgets/claim_rejected_dialog.dart';
import 'widgets/status_item_card.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item has been claimed successfully.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for finder to verify your claim...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _isClaimedTabActive ? _claimedItems : _reportedItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Toggle Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isClaimedTabActive = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isClaimedTabActive 
                                ? AppColors.primaryBlue 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reported Item',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_isClaimedTabActive 
                                  ? Colors.white 
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isClaimedTabActive = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isClaimedTabActive 
                                ? AppColors.primaryBlue 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Claimed Item',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isClaimedTabActive 
                                  ? Colors.white 
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
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
