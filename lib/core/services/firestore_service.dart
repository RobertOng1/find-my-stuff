import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/chat_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Posts (Items) ---

  Future<void> createPost(ItemModel item) async {
    try {
      await _db.collection('posts').doc(item.id).set(item.toJson());
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Stream<List<ItemModel>> getFeedItems(String type) {
    return _db
        .collection('posts')
        .where('type', isEqualTo: type)
        .where('status', isEqualTo: 'OPEN')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> resolveItem(String itemId) async {
    try {
      await _db.collection('posts').doc(itemId).update({'status': 'RESOLVED'});
    } catch (e) {
      print('Error resolving item: $e');
      rethrow;
    }
  }

  Future<ItemModel?> getItem(String itemId) async {
    try {
      final doc = await _db.collection('posts').doc(itemId).get();
      if (doc.exists) {
        return ItemModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting item: $e');
      return null;
    }
  }

  // --- Claims ---

  Future<void> submitClaim(ClaimModel claim) async {
    try {
      await _db.collection('claims').doc(claim.id).set(claim.toJson());
    } catch (e) {
      print('Error submitting claim: $e');
      rethrow;
    }
  }

  Stream<List<ClaimModel>> getClaimsForUser(String userId) {
    return _db
        .collection('claims')
        .where('claimantId', isEqualTo: userId)
        //.orderBy('timestamp', descending: true) // Removed to avoid index issues for now
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClaimModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ClaimModel>> getClaimsForItem(String itemId) {
    return _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        //.orderBy('timestamp', descending: true) // Removed to avoid index issues for now
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClaimModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateClaimStatus(String claimId, String status) async {
    try {
      await _db.collection('claims').doc(claimId).update({'status': status});
    } catch (e) {
      print('Error updating claim status: $e');
      rethrow;
    }
  }
  Future<String> createChat({
    required String itemId,
    required String itemName,
    required String claimantId,
    required String finderId,
  }) {
    return ChatService().createChat(
      itemId: itemId, 
      itemName: itemName, 
      claimantId: claimantId, 
      finderId: finderId
    );
  }
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  // Profile Stats
  Future<int> getUserItemCount(String userId, String type) async {
    try {
      final snapshot = await _db
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting $type count: $e');
      return 0;
    }
  }

  Stream<List<ItemModel>> getUserActiveItems(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'OPEN') // Only active items
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ItemModel>> getUserPosts(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
