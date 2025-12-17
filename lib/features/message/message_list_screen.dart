import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../chat/chat_screen.dart';
import 'widgets/chat_list_tile.dart';
import '../../widgets/animated_gradient_bg.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/models.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _authService.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please login to view chats')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AnimatedGradientBg(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Recent Chats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Chat List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getUserChats(currentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final chatData = docs[index].data() as Map<String, dynamic>;
                          return _ChatListItem(
                            chatData: chatData, 
                            currentUserId: currentUserId,
                            index: index,
                          );
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
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
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

class _ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chatData;
  final String currentUserId;
  final int index;

  const _ChatListItem({
    required this.chatData,
    required this.currentUserId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the other user's ID
    final List<dynamic> participants = chatData['participants'] ?? [];
    final String otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(otherUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Loading state placeholder
          return Container(
             margin: const EdgeInsets.only(bottom: 12),
             height: 80,
             decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
             ),
          );
        }

        final otherUser = snapshot.data!;
        
        // Format time
        final Timestamp? lastMessageTime = chatData['lastMessageTime'];
        String timeStr = '';
        if (lastMessageTime != null) {
          final dt = lastMessageTime.toDate();
          timeStr = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        }

        // Calculate Unread Status
        int unreadCount = 0;
        final String lastSenderId = chatData['lastSenderId'] ?? '';
        
        // Use the explicit counter if available (New logic)
        final Map<String, dynamic> unreadCounts = Map<String, dynamic>.from(chatData['unreadCounts'] ?? {});
        unreadCount = (unreadCounts[currentUserId] ?? 0) as int;

        // Fallback for legacy chats (timestamp check)
        // If counter is 0 but timestamp says unread, show as 1 unread
        if (unreadCount == 0) {
            final Map<String, dynamic> lastReadMap = Map<String, dynamic>.from(chatData['lastRead'] ?? {});
            final Timestamp? myLastRead = lastReadMap[currentUserId] as Timestamp?;
            
            if (lastSenderId != currentUserId && lastMessageTime != null) {
              if (myLastRead == null) {
                unreadCount = 1; // Never read
              } else {
                 final msgTime = lastMessageTime.toDate();
                 final readTime = myLastRead.toDate();
                 if (msgTime.isAfter(readTime)) {
                   unreadCount = 1; // Unread by timestamp
                 }
              }
            }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ChatListTile(
            userName: otherUser.displayName,
            avatarUrl: otherUser.photoUrl.isNotEmpty ? otherUser.photoUrl : 'assets/images/logo.png',
            lastMessage: chatData['lastMessage'] ?? '',
            time: timeStr,
            unreadCount: unreadCount, 
            isOnline: false, 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatData['id'],
                    itemId: chatData['itemId'] ?? '',
                    itemName: chatData['itemName'] ?? 'Item',
                    otherUserName: otherUser.displayName,
                    otherUserId: otherUser.uid,
                  ),
                ),
              );
            },
          ),
        ).animate().fade(duration: 400.ms, delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
}
