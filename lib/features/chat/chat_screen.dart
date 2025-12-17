import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Source;
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
import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  
  // Voice Note State
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _recordTimer;
  int _recordDurationSeconds = 0;
  bool _showMic = true;
  bool _isCanceling = false;
  bool _isLocked = false;
  bool _isPaused = false;

  late String currentUserId;
  String? otherUserAvatar;
  String? otherUserName;
  ClaimModel? _pendingClaim;
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    currentUserId = _authService.currentUser?.uid ?? '';
    otherUserName = widget.otherUserName;

    // Listen to text changes for Mic toggle
    _messageController.addListener(() {
      setState(() {
        _showMic = _messageController.text.trim().isEmpty;
      });
    });

    if (widget.otherUserId.isNotEmpty) {
      _fetchOtherUserProfile();
    }
    _checkForPendingClaims();
    _messagesStream = _chatService.getMessages(widget.chatId);
    
    // Mark as read immediately
    _chatService.markChatAsRead(widget.chatId, currentUserId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    super.dispose();
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

  // Voice Note Logic
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Ensure clean state
        _recordTimer?.cancel();
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        
        if (mounted) {
          setState(() {
            _isRecording = true;
            _isLocked = false; 
            _isPaused = false;
            _recordDurationSeconds = 0;
            _isCanceling = false;
          });
          _startTimer();
        }
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start recording: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _recordDurationSeconds++;
        });
      }
    });
  }

  Future<void> _stopRecording({bool isSendButton = false}) async {
    // If locked, ONLY the Send button can stop it. Release gesture should do nothing.
    if (_isLocked && !isSendButton) return;
    
    // Prevent double stopping
    if (!_isRecording && !_isCanceling) return;

    _recordTimer?.cancel();
    
    // Optimistic UI update to prevent flicker
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isLocked = false;
        _isPaused = false;
      });
    }

    try {
      final path = await _audioRecorder.stop();
      print('DEBUG: Stopped. Path: $path, Cancel: $_isCanceling');

      if (!_isCanceling && path != null) {
        await _uploadAndSendAudio(path);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    
    // Mark as canceling FIRST so _stopRecording logic knows
    if (mounted) {
      setState(() {
        _isCanceling = true;
        _isRecording = false;
        _isLocked = false;
        _isPaused = false;
        _recordDurationSeconds = 0; // Reset timer on cancel
      });
    }

    try {
      await _audioRecorder.stop();
    } catch (e) {
      print('Error cleaning up recording: $e');
    }
  }

  void _lockRecording() {
    if (!_isRecording) return;
    if (mounted) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  Future<void> _togglePauseRecording() async {
    try {
      if (_isPaused) {
        await _audioRecorder.resume();
        _startTimer();
      } else {
        await _audioRecorder.pause();
        _recordTimer?.cancel();
      }
      if (mounted) {
        setState(() {
          _isPaused = !_isPaused;
        });
      }
    } catch (e) {
      print('Error toggling pause: $e');
    }
  }

  Future<void> _uploadAndSendAudio(String path) async {
    try {
       final file = File(path);
       if (!await file.exists()) {
         print('Error: File does not exist at path: $path');
         return;
       }
       
       final length = await file.length();
       print('DEBUG: Audio File Size: $length bytes');
       
       if (length < 500) { // arbitrary small size check (header only?)
         print('Warning: Audio file too small ($length bytes), might be empty.');
         // return; // Let's try sending anyway, but log it.
       }

       final audioUrl = await _chatService.uploadAudio(file, widget.chatId);
       final durationStr = _formatDuration(_recordDurationSeconds);

       await _chatService.sendMessage(
         chatId: widget.chatId, 
         senderId: currentUserId, 
         receiverId: widget.otherUserId, // Add missing parameter
         senderName: _authService.currentUser?.displayName ?? 'User',
         senderAvatar: _authService.currentUser?.photoURL ?? '',
         audioUrl: audioUrl,
         duration: durationStr
       );
    } catch (e) {
       print('Upload Error: $e');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send voice note: $e')));
       }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remSeconds = seconds % 60;
    return '$minutes:${remSeconds.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      receiverId: widget.otherUserId, // Pass receiver ID 
      senderName: _authService.currentUser?.displayName ?? 'User',
      senderAvatar: _authService.currentUser?.photoURL ?? '',
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
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        reverse: true, // Start from bottom
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
                            audioUrl: data['audioUrl'],
                            duration: data['duration'],
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
                    color: Colors.white.withOpacity(0.9), 
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
                    child: _isLocked
                        ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                                onPressed: _cancelRecording,
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(_recordDurationSeconds),
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: AppColors.textDark
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Animated/Fake Waveform
                              Row(
                                children: List.generate(8, (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 4,
                                  height: 12.0 + (i % 3) * 8.0,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.red, size: 32),
                                onPressed: _togglePauseRecording,
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _stopRecording(isSendButton: true),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF25D366), // WhatsApp Green
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: _isRecording ? 12 : 0),
                                  decoration: BoxDecoration(
                                    color: _isRecording ? Colors.red.withOpacity(0.05) : const Color(0xFFF0F3F8),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: _isRecording 
                                      ? Row(
                                          children: [
                                            const Icon(Icons.mic, color: Colors.red, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDuration(_recordDurationSeconds),
                                              style: const TextStyle(
                                                color: Colors.red, 
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Text(
                                              'Start Lock ⬆️  Cancel ⬅️',
                                              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                                            ),
                                          ],
                                        )
                                      : TextField(
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
                              
                              // Send or Record Button
                              GestureDetector(
                                onTap: _showMic ? () async {
                                   await _startRecording();
                                   _lockRecording();
                                } : _sendMessage, 
                                onLongPressStart: _showMic ? (_) => _startRecording() : null,
                                onLongPressEnd: _showMic ? (_) => _stopRecording() : null,
                                onLongPressMoveUpdate: _showMic ? (details) {
                                   if (details.localPosition.dx < -60) {
                                     _cancelRecording();
                                   }
                                   // Slide UP to Lock
                                   if (details.localPosition.dy < -60) {
                                      _lockRecording();
                                   }
                                } : null,
                                child: Transform.scale(
                                  scale: _isRecording ? 1.4 : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isRecording 
                                            ? [Colors.redAccent, Colors.red] 
                                            : [AppColors.primaryLight, AppColors.primaryBlue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isRecording ? Colors.red : AppColors.primaryBlue).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _showMic ? (_isRecording ? Icons.mic : Icons.mic_none_rounded) : Icons.send_rounded,
                                      color: Colors.white, 
                                      size: 22
                                    ),
                                  ),
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

  Widget _buildMessageBubble(String text, bool isMe, String time, {String? audioUrl, String? duration}) {
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
                            stops: [0.0, 1.0],
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
                  child: audioUrl != null
                      ? _AudioMessage(audioUrl: audioUrl, duration: duration ?? '0:00', isMe: isMe)
                      : Column(
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

class _AudioMessage extends StatefulWidget {
  final String audioUrl;
  final String duration; 
  final bool isMe;

  const _AudioMessage({
    required this.audioUrl,
    required this.duration,
    required this.isMe,
  });

  @override
  State<_AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<_AudioMessage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      Source source;
      if (widget.audioUrl.startsWith('http')) {
        source = UrlSource(widget.audioUrl);
      } else {
        try {
          source = BytesSource(base64Decode(widget.audioUrl));
        } catch (e) {
          print('Error decoding audio base64: $e');
          return;
        }
      }
      await _player.play(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, // Fixed width
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isMe ? Colors.white.withOpacity(0.2) : const Color(0xFFF0F3F8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: widget.isMe ? Colors.white : AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Fake Waveform
               Row(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: List.generate(15, (index) => 
                   Container(
                     margin: const EdgeInsets.symmetric(horizontal: 1.5),
                     width: 3,
                     height: 10.0 + ((index * 7) % 15), 
                     decoration: BoxDecoration(
                       color: widget.isMe ? Colors.white.withOpacity(0.8) : AppColors.primaryBlue.withOpacity(0.4),
                       borderRadius: BorderRadius.circular(4),
                     ),
                   )
                 ),
               ),
               const SizedBox(height: 6),
               Text(
                 widget.duration,
                 style: TextStyle(
                   color: widget.isMe ? Colors.white.withOpacity(0.9) : AppColors.textGrey,
                   fontSize: 10,
                   fontWeight: FontWeight.w600,
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }
}
