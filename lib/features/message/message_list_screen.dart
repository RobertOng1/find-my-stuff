import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../chat/chat_screen.dart';
import 'widgets/chat_list_tile.dart';
import '../../widgets/animated_gradient_bg.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  // Mock Data - Recent Chats
  static const List<Map<String, dynamic>> _recentChats = [
    {
      'id': '1',
      'userName': 'Rezeki danan',
      'avatarUrl': 'assets/images/logo.png',
      'lastMessage': 'Sure! Please submit proof of ownership ...',
      'time': '10.23',
      'unreadCount': 1,
      'isOnline': true,
      'itemName': 'Blue Backpack',
    },
    {
      'id': '2',
      'userName': 'Robert Siahaan',
      'avatarUrl': 'assets/images/logo.png',
      'lastMessage': 'Sure! Please submit proof of ownership ...',
      'time': '10.23',
      'unreadCount': 0,
      'isOnline': true,
      'itemName': 'iPhone 13 Pro',
    },
    {
      'id': '3',
      'userName': 'Lee Williamson',
      'avatarUrl': 'assets/images/logo.png',
      'lastMessage': 'Sure! Please submit proof of ownership ...',
      'time': '10.23',
      'unreadCount': 0,
      'isOnline': true,
      'itemName': 'Wallet',
    },
    {
      'id': '4',
      'userName': 'Ronald Mccoy',
      'avatarUrl': 'assets/images/logo.png',
      'lastMessage': 'Sure! Please submit proof of ownership ...',
      'time': '10.23',
      'unreadCount': 0,
      'isOnline': false,
      'itemName': 'Keys',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                      fontSize: 28, // Larger
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Chat List
                Expanded(
                  child: _recentChats.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recentChats.length,
                          itemBuilder: (context, index) {
                            final chat = _recentChats[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85), // Glassy list items
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
                                userName: chat['userName'],
                                avatarUrl: chat['avatarUrl'],
                                lastMessage: chat['lastMessage'],
                                time: chat['time'],
                                unreadCount: chat['unreadCount'],
                                isOnline: chat['isOnline'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        itemName: chat['itemName'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ).animate().fade(duration: 400.ms, delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
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
