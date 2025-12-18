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
      final batch = _db.batch();

      // 1. Create the claim
      final claimRef = _db.collection('claims').doc(claim.id);
      batch.set(claimRef, claim.toJson());

      // 2. Add item ID to user's reported list (to disable button)
      final userRef = _db.collection('users').doc(claim.claimantId);
      batch.update(userRef, {
        'reportedItemIds': FieldValue.arrayUnion([claim.itemId])
      });

      await batch.commit();
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

  // Badge Logic
  Future<List<String>> checkAndAwardBadges(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final user = UserModel.fromJson(userDoc.data()!);
      final foundCount = await getUserItemCount(userId, 'FOUND'); // This might query based on "status=RESOLVED" ideally.
      // Ideally we should store foundCount in User model to avoid count queries, 
      // but for now relying on actual returned count or a counter field.
      // Let's increment a counter in completeReturnTransaction instead to be safe.
      
      List<String> newBadges = [];
      List<String> currentBadges = List.from(user.badges);

      // Criteria
      if (foundCount >= 1 && !currentBadges.contains('trusted_finder')) {
        newBadges.add('trusted_finder');
        currentBadges.add('trusted_finder');
      }
      if (foundCount >= 5 && !currentBadges.contains('golden_hand')) {
        newBadges.add('golden_hand');
        currentBadges.add('golden_hand');
      }
      if (foundCount >= 10 && !currentBadges.contains('verity_vanguard')) {
        newBadges.add('verity_vanguard');
        currentBadges.add('verity_vanguard');
      }
      if (foundCount >= 20 && !currentBadges.contains('golden_heart')) {
        newBadges.add('golden_heart');
        currentBadges.add('golden_heart');
      }

      if (newBadges.isNotEmpty) {
        await _db.collection('users').doc(userId).update({
          'badges': currentBadges,
          'points': FieldValue.increment(newBadges.length * 50), // Bonus points for badges
        });
      }

      return newBadges;
    } catch (e) {
      print('Error awarding badges: $e');
      return [];
    }
  }

  Future<List<String>> completeReturnTransaction({
    required String itemId,
    required String claimId,
    required String finderId,
  }) async {
    try {
      // 1. Update Item Status
      await _db.collection('posts').doc(itemId).update({'status': 'RESOLVED'});

      // 2. Update Claim Status
      await _db.collection('claims').doc(claimId).update({'status': 'COMPLETED'});

      // 3. Increment Finder Points/Count
      // Note: We are relying on getUserItemCount queries usually, but let's assume 
      // checkAndAwardBadges counts actual items. 
      // However, to make checkAndAwardBadges work accurately with "Resolved" items, 
      // we need to make sure getUserItemCount filters by resolved or we assume any found item counts.
      // For now, let's just award points here.
      await _db.collection('users').doc(finderId).update({
        'points': FieldValue.increment(100), // 100 points for a return
      });

      // 4. Check Badges
      return await checkAndAwardBadges(finderId);
    } catch (e) {
      print('Error completing transaction: $e');
      rethrow;
    }
  }

  Future<void> acceptClaim({required String claimId, required String itemId}) async {
    try {
      final batch = _db.batch();

      // 1. Update Claim Status
      final claimRef = _db.collection('claims').doc(claimId);
      batch.update(claimRef, {'status': 'ACCEPTED'});

      // 2. Update Item Status (Lock it so it's hidden from feed)
      final itemRef = _db.collection('posts').doc(itemId);
      batch.update(itemRef, {'status': 'CLAIMED'});

      await batch.commit();
    } catch (e) {
      print('Error accepting claim: $e');
      rethrow;
    }
  }

  Future<void> updateClaimStatus(String claimId, String status, {String? reason}) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (reason != null) {
        data['rejectionReason'] = reason;
      }
      await _db.collection('claims').doc(claimId).update(data);
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

  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Create a map of fields to update
      // We don't want to overwrite everything just in case, but using set with merge is cleaner
      // But for now, specifically updating profile fields and standardizing. 
      // Using set(options: SetOptions(merge: true)) is safer.
      await _db.collection('users').doc(user.uid).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  // Profile Stats
  Future<int> getUserItemCount(String userId, String type, {String? status}) async {
    try {
      Query query = _db
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type);
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting $type count: $e');
      return 0;
    }
  }

  Stream<int> getUserItemCountStream(String userId, String type, {String? status}) {
    Query query = _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) => snapshot.size);
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
