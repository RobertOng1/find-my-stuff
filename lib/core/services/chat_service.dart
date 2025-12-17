import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);
    final CollectionReference messagesCol = chatDoc.collection('messages');

    await _firestore.runTransaction((transaction) async {
      // Add message to sub-collection
      transaction.set(messagesCol.doc(), {
        'text': text,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update parent chat document
      transaction.update(chatDoc, {
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    });
  }

  // Stream messages for a specific chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
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
}
