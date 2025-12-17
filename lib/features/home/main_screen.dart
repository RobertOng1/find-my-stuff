import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/in_app_notification.dart';
import 'home_screen.dart';
import '../profile/profile_screen.dart';
import '../status/status_screen.dart';
import '../message/message_list_screen.dart';
import '../chat/chat_screen.dart';
import 'create_report_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  StreamSubscription? _chatSubscription; // NEW: Listen for msgs
  StreamSubscription? _myClaimSubscription; // NEW: Listen for status updates
  StreamSubscription? _claimSubscription; 
  final Set<String> _notifiedClaimIds = {}; 

  // Badge State
  bool _hasUnreadMessages = false;
  bool _hasUnreadStatus = false; 

  final List<Widget> _screens = [
    const HomeScreen(),        // Dashboard
    const StatusScreen(),      // Status
    const SizedBox.shrink(),   // Placeholder for FAB
    const MessageListScreen(), // Message
    const ProfileScreen(),     // Profile
  ];

  @override
  void initState() {
    super.initState();
    _setupClaimListener();    // Existing (Owner)
    _setupChatListener();     // NEW: Chat
    _setupMyClaimListener();  // NEW: Claimant (Accepted/Rejected)
  }

  @override
  void dispose() {
    _claimSubscription?.cancel();
    _chatSubscription?.cancel();
    _myClaimSubscription?.cancel();
    super.dispose();
  }

  /// Listen for new claims on user's items
  void _setupClaimListener() {
    final user = AuthService().currentUser;
    if (user == null) return;

    // Listen to claims where current user is the finder (item owner)
    _claimSubscription = FirebaseFirestore.instance
        .collection('claims')
        .where('finderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final claimId = change.doc.id;
          final data = change.doc.data();
          if (data == null) continue;

          // Prevent spam on app start: Check if claim is old
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp != null) {
            final now = DateTime.now();
            final claimTime = timestamp.toDate();
            // If claim is older than 5 minutes, assume it's "existing data" and don't notify
            // Unless we want to be stricter, but 5 mins covers "just happened" vs "old".
            if (now.difference(claimTime).inMinutes > 5) continue;
          }

          // Only notify for claims we haven't seen yet
          if (!_notifiedClaimIds.contains(claimId)) {
            _notifiedClaimIds.add(claimId);
             
            if (mounted) setState(() {
               if (_selectedIndex != 1) _hasUnreadStatus = true;
            });

            _showClaimNotification(data);
          }
        }
      }
    });
  }

  /// NEW: Listen for new messages in chats I'm part of
  void _setupChatListener() {
    final user = AuthService().currentUser;
    if (user == null) return;

    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .limit(1) // Only watch the most active chat to save reads? Or watch all? Watch logic is complex.
        // Actually, typical chat apps watch the collection query.
        // For efficiency in this demo, let's watch the query. 
        .snapshots() 
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        // We only care about MODIFIED (new msg) or ADDED (new chat)
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final lastSenderId = data['lastSenderId'];
          final lastMessageTime = data['lastMessageTime'] as Timestamp?;
          
          // 1. Don't notify if I sent it
          if (lastSenderId == user.uid) continue;

          // 2. Don't notify if message is old (stale data on init)
          // Simple check: if message is older than 30 seconds, ignore.
          if (lastMessageTime != null) {
            final now = DateTime.now();
            final msgTime = lastMessageTime.toDate();
            if (now.difference(msgTime).inSeconds > 30) continue;
          }

          // 3. Show Notification
          // Determine other user ID for navigation
          final participants = List<String>.from(data['participants'] ?? []);
          final otherUserId = participants.firstWhere((id) => id != user.uid, orElse: () => '');
          
          final senderName = data['lastSenderName'] ?? 'Someone';
          final senderAvatar = data['lastSenderAvatar'] as String?;

          if (mounted) {
             setState(() {
               if (_selectedIndex != 3) {
                 _hasUnreadMessages = true;
               }
             });
             
             InAppNotification.show(
              context,
              title: senderName, // Show dynamic name
              message: data['lastMessage'] ?? 'Sent a message',
              avatarUrl: senderAvatar, // Show dynamic avatar
              icon: Icons.chat_bubble_rounded, // Fallback icon
              iconColor: AppColors.successGreen,
              actionLabel: 'Reply',
              onActionTap: () {
                // Navigate DIRECTLY to the chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: data['id'],
                      itemId: data['itemId'] ?? '',
                      itemName: data['itemName'] ?? 'Item',
                      otherUserId: otherUserId,
                      otherUserName: senderName, // Use the name we have
                    ),
                  ),
                );
              },
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: data['id'],
                      itemId: data['itemId'] ?? '',
                      itemName: data['itemName'] ?? 'Item',
                      otherUserId: otherUserId,
                      otherUserName: senderName,
                    ),
                  ),
                );
              },
            );
          }
        }
      }
    });
  }

  /// NEW: Listen for updates to claims *I made*
  void _setupMyClaimListener() {
    final user = AuthService().currentUser;
    if (user == null) return;

    _myClaimSubscription = FirebaseFirestore.instance
        .collection('claims')
        .where('claimantId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;

          final status = data['status'];
          if (status == 'ACCEPTED') {
            if (mounted) setState(() {
               if (_selectedIndex != 1) _hasUnreadStatus = true;
            });
            _showMyClaimUpdateNotification(
              title: 'Claim Accepted! 🎉', 
              body: 'The owner verified your claim. Tap to coordinate handover.',
              isPositive: true
            );
          } else if (status == 'REJECTED') {
            if (mounted) setState(() {
               if (_selectedIndex != 1) _hasUnreadStatus = true;
            });
            _showMyClaimUpdateNotification(
              title: 'Claim Rejected',
              body: 'Reason: ${data['rejectionReason'] ?? 'Details not provided'}',
              isPositive: false
            );
          }
        }
      }
    });
  }

  void _showMyClaimUpdateNotification({required String title, required String body, required bool isPositive}) {
    if (!mounted) return;
    InAppNotification.show(
      context,
      title: title,
      message: body,
      icon: isPositive ? Icons.check_circle : Icons.cancel,
      iconColor: isPositive ? AppColors.successGreen : AppColors.errorRed,
      actionLabel: 'View',
      onActionTap: () => setState(() => _selectedIndex = 1), // Go to Status
      onTap: () => setState(() => _selectedIndex = 1),
    );
  }

  /// Show notification for new claim (OWNER SIDE)
  void _showClaimNotification(Map<String, dynamic> claimData) {
    final claimantName = claimData['claimantName'] ?? 'Someone';
    final claimantAvatar = claimData['claimantAvatar'] as String?;
    
    // Show beautiful in-app notification (top slide-in)
    if (mounted) {
      InAppNotification.show(
        context,
        title: '🔔 New Claim Request!',
        message: '$claimantName wants to claim your item',
        avatarUrl: claimantAvatar,
        icon: Icons.assignment_turned_in,
        iconColor: AppColors.primaryBlue,
        actionLabel: 'View',
        onActionTap: () {
          // Navigate to Status screen
          setState(() => _selectedIndex = 1);
        },
        onTap: () {
          // Navigate to Status screen
          setState(() => _selectedIndex = 1);
        },
      );
    }
  }

  void _onItemTapped(int index) {
    // Ignore tap on center FAB placeholder (index 2)
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
      // Clear badges on tap
      if (index == 1) _hasUnreadStatus = false;
      if (index == 3) _hasUnreadMessages = false;
    });
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What do you want to report?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    'I Lost an Item',
                    Icons.search,
                    AppColors.errorRed,
                    'LOST',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    'I Found an Item',
                    Icons.check_circle_outline,
                    AppColors.successGreen,
                    'FOUND',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReportScreen(reportType: type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Main Content
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          
          // 2. Navigation Bar (Bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  height: 70, // Height for the visual nav bar
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard', 0),
                      _buildNavItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Status', 1),
                      const SizedBox(width: 56), // Space for FAB center
                      _buildNavItem(Icons.message_outlined, Icons.message_rounded, 'Message', 3),
                      _buildNavItem(Icons.person_outline, Icons.person_rounded, 'Profile', 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 3. FAB (Centered and Elevated)
          Positioned(
            bottom: 30, // Positioned to overlap nicely
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showReportOptions(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    bool showBadge = false;
    if (index == 1 && _hasUnreadStatus) showBadge = true;
    if (index == 3 && _hasUnreadMessages) showBadge = true;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox( // Fixed size container
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 10 : 0), // Slightly adjusted padding
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16), // Softer radius
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                    size: 24,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            // Explicit transparent spacer to keep alignment if needed, or remove
          ],
        ),
      ),
    );
  }
}
