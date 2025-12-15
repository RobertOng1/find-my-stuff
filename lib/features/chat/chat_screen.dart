import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../claim/proof_form_screen.dart';
import '../claim/claim_accepted_screen.dart';
import '../claim/widgets/claim_rejected_dialog.dart';
import '../../core/models/models.dart';
import 'dart:ui';
import '../../widgets/animated_gradient_bg.dart';

class ChatScreen extends StatefulWidget {
  final String itemName;

  const ChatScreen({super.key, required this.itemName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I believe this might be my backpack. Can we verify?',
      'isMe': true,
      'time': '10:23 AM',
    },
    {
      'text': 'Sure! Please submit proof of ownership through the claim form.',
      'isMe': false,
      'time': '10:24 AM',
    },
  ];

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
            Text(
              widget.itemName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onSelected: (value) {
              if (value == 'accepted') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClaimAcceptedScreen()),
                );
              } else if (value == 'rejected') {
                showDialog(
                  context: context,
                  builder: (context) => const ClaimRejectedDialog(),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'accepted',
                child: Text('Simulate: Claim Accepted'),
              ),
              const PopupMenuItem<String>(
                value: 'rejected',
                child: Text('Simulate: Claim Rejected'),
              ),
            ],
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(
                        message['text'],
                        message['isMe'],
                        message['time'],
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
                          onTap: () {
                            if (_messageController.text.isNotEmpty) {
                              setState(() {
                                _messages.add({
                                  'text': _messageController.text,
                                  'isMe': true,
                                  'time': 'Now',
                                });
                                _messageController.clear();
                              });
                            }
                          },
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
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/logo.png'),
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
                      if (!isMe && text.contains('submit proof')) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProofFormScreen(
                                  item: ItemModel(
                                    id: 'dummy_id',
                                    userId: 'dummy_finder',
                                    title: widget.itemName,
                                    description: 'Unknown description',
                                    location: 'Unknown location',
                                    imageUrl: 'assets/images/logo.png',
                                    type: 'LOST',
                                    category: 'General',
                                    date: DateTime.now(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.assignment_outlined, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Fill Claim Form',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
