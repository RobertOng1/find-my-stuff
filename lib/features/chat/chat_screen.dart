import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/auth_service.dart';
import '../claim/submit_proof_screen.dart';
import '../claim/claim_accepted_screen.dart';
import '../claim/widgets/claim_rejected_dialog.dart';
import '../claim/verification_screen.dart'; // VerifyClaimantScreen
import '../../core/models/models.dart';
import '../../core/services/firestore_service.dart';
import 'dart:ui';
import '../../widgets/animated_gradient_bg.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String itemId; // Added itemId
  final String itemName;
  final String otherUserName; // Fallback
  final String otherUserId;

  const ChatScreen({
    super.key, 
    required this.chatId,
    required this.itemId, // Required
    required this.itemName,
    this.otherUserName = 'User',
    this.otherUserId = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  late String currentUserId;
  String? otherUserAvatar;
  String? otherUserName;
  ClaimModel? _pendingClaim;

  @override
  void initState() {
    super.initState();
    currentUserId = _authService.currentUser?.uid ?? '';
    otherUserName = widget.otherUserName;
    if (widget.otherUserId.isNotEmpty) {
      _fetchOtherUserProfile();
    }
    _checkForPendingClaims();
  }

  Future<void> _fetchOtherUserProfile() async {
    final user = await _firestoreService.getUser(widget.otherUserId);
    if (user != null && mounted) {
      setState(() {
        otherUserAvatar = user.photoUrl;
        otherUserName = user.displayName;
      });
    }
  }

  void _checkForPendingClaims() {
    // Listen for claims related to this item
    _firestoreService.getClaimsForItem(widget.itemId).listen((claims) {
      if (!mounted) return;
      
      // Find a pending claim where I am the finder (the one verifying)
      try {
        final claim = claims.firstWhere((c) => 
          c.status == 'PENDING' && c.finderId == currentUserId
        );
        setState(() {
          _pendingClaim = claim;
        });
      } catch (e) {
        setState(() {
          _pendingClaim = null;
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      text: _messageController.text.trim(),
    );
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Glass feel
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8), // Semi-transparent glass header
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (otherUserName != null && otherUserName != 'User')
                  Text(
                    otherUserName!,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
            if (_pendingClaim != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                   // Show loading indicator
                   showDialog(
                     context: context,
                     barrierDismissible: false,
                     builder: (context) => const Center(child: CircularProgressIndicator()),
                   );

                   final item = await _firestoreService.getItem(widget.itemId);
                   
                   if (context.mounted) {
                     Navigator.pop(context); // Dismiss loading
                     
                     if (item != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(
                              claim: _pendingClaim!,
                              item: item,
                            ),
                          ),
                        );
                     } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Error loading item details')),
                       );
                     }
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: const Text('Review Claim'),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedGradientBg(), // The new global gradient
          SafeArea(
            child: Column(
              children: [
                // Chat List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getMessages(widget.chatId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final isMe = data['senderId'] == currentUserId;
                          
                          // Convert timestamp to readable time (simplistic)
                          // Ideally use intl package for formatting
                          final Timestamp? timestamp = data['timestamp'];
                          String timeStr = '';
                          if (timestamp != null) {
                             final dt = timestamp.toDate();
                             timeStr = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                          }

                          return _buildMessageBubble(
                            data['text'] ?? '',
                            isMe,
                            timeStr,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Glassy input area
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F3F8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.8), fontSize: 15),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.attach_file_rounded, color: AppColors.textGrey, size: 20),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primaryBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: otherUserAvatar != null && otherUserAvatar!.isNotEmpty 
                        ? NetworkImage(otherUserAvatar!) 
                        : const AssetImage('assets/images/logo.png') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe 
                            ? AppColors.primaryBlue.withOpacity(0.2)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textDark,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 44,
              right: isMe ? 4 : 0,
            ),
            child: Text(
              time,
              style: TextStyle(
                color: AppColors.textGrey.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
