import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a consistent chat ID based on item and participants
  String getChatId(String itemId, String userA, String userB) {
    // Sort user IDs to ensure consistency regardless of who starts the chat
    List<String> users = [userA, userB];
    users.sort();
    return '${itemId}_${users[0]}_${users[1]}';
  }

  // Create or get existing chat
  Future<String> createChat({
    required String itemId,
    required String itemName,
    required String claimantId,
    required String finderId,
  }) async {
    final String chatId = getChatId(itemId, claimantId, finderId);
    final DocumentReference chatDoc = _firestore.collection('chats').doc(chatId);

    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      await chatDoc.set({
        'id': chatId,
        'itemId': itemId,
        'itemName': itemName,
        'participants': [claimantId, finderId],
        'claimantId': claimantId,
        'finderId': finderId,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

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
