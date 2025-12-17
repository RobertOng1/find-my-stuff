import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Added
import 'dart:io'; // Added
import 'dart:convert'; // Added

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Not used anymore

  // Generate a consistent chat ID based on participants (User-Centric)
  String getChatId(String userA, String userB) {
    // Sort user IDs to ensure consistency regardless of who starts the chat
    List<String> users = [userA, userB];
    users.sort();
    return '${users[0]}_${users[1]}';
  }

  // Create or get existing chat (Updates context if existing)
  Future<String> createChat({
    required String itemId,
    required String itemName,
    required String claimantId,
    required String finderId,
  }) async {
    // 1. Check for ANY existing conversation between these users (Legacy & New)
    String? existingChatId;
    
    try {
      final QuerySnapshot query = await _firestore
          .collection('chats')
          .where('participants', arrayContains: claimantId)
          .get();

      // Find valid chat doc
      for (var doc in query.docs) {
        final participants = List<String>.from(doc['participants'] as List);
        if (participants.contains(finderId)) {
          // Found a conversation!
          existingChatId = doc.id;
          
          // Optimization: If we find a chat that matches our new ID format, stop and use it.
          if (doc.id == getChatId(claimantId, finderId)) break;
        }
      }
    } catch (e) {
      print('Error finding existing chat: $e');
    }

    // 2. Determine Chat ID to use
    final String chatId = existingChatId ?? getChatId(claimantId, finderId);
    final DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);

    final docSnapshot = await chatDoc.get();

    final Map<String, dynamic> data = {
      'id': chatId,
      'itemId': itemId, // Update context to current item
      'itemName': itemName,
      'participants': [claimantId, finderId],
      'claimantId': claimantId, 
      'finderId': finderId,
    };

    if (!docSnapshot.exists) {
       data['createdAt'] = FieldValue.serverTimestamp();
       data['lastMessage'] = '';
       data['lastMessageTime'] = FieldValue.serverTimestamp();
    }
    
    // Merge updates the fields provided (switching context to new item)
    await chatDoc.set(data, SetOptions(merge: true));

    return chatId;
  }

  // Encode Audio to Base64 (Bypassing Storage)
  Future<String> uploadAudio(File audioFile, String chatId) async {
    print('DEBUG: Converting audio to Base64...');
    try {
      final bytes = await audioFile.readAsBytes();
      // Check size limit (approx 1MB for Firestore document less overhead)
      if (bytes.length > 700000) { // Safety buffer for metadata (700KB)
         throw 'Audio too long (limit > 1 min). Please record a shorter message.';
      }
      
      final base64String = base64Encode(bytes);
      print('DEBUG: Encoded Audio length: ${base64String.length}');
      return base64String;
    } catch (e) {
      print('Error encoding audio: $e');
      throw e;
    }
  }

  // Send a message (Text or Audio)
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId, // NEW: Needed to increment unread count
    required String senderName,   
    required String senderAvatar, 
    String? text,
    String? audioUrl,
    String? duration,
  }) async {
    if ((text == null || text.trim().isEmpty) && audioUrl == null) return;

    final DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);
    final CollectionReference messagesCol = chatDoc.collection('messages');

    await _firestore.runTransaction((transaction) async {
      // Add message to sub-collection
      transaction.set(messagesCol.doc(), {
        'text': text ?? '',
        'audioUrl': audioUrl,
        'duration': duration,
        'isAudio': audioUrl != null,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update parent chat document
      String previewText = audioUrl != null ? '🎤 Voice Message' : (text ?? '');

      final Map<String, dynamic> updates = {
        'lastMessage': previewText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': senderId, 
        'lastSenderName': senderName, 
        'lastSenderAvatar': senderAvatar, 
      };

      // Increment unread count for the RECEIVER
      if (receiverId.isNotEmpty) {
        updates['unreadCounts.$receiverId'] = FieldValue.increment(1);
      }

      transaction.update(chatDoc, updates);
    });
  }

  // Stream messages for a specific chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'lastRead.$userId': FieldValue.serverTimestamp(),
      'unreadCounts.$userId': 0, // Reset counter
    });
  }
}
