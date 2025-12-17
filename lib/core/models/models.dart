import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final double trustScore;
  final int points;
  final List<String> badges;
  final List<String> reportedItemIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.phoneNumber = '',
    this.trustScore = 0.0,
    this.points = 0,
    this.badges = const [],
    this.reportedItemIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      trustScore: (json['trustScore'] ?? 0.0).toDouble(),
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      reportedItemIds: List<String>.from(json['reportedItemIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'trustScore': trustScore,
      'points': points,
      'badges': badges,
      'reportedItemIds': reportedItemIds,
    };
  }
}

class ItemModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location; // Keeping as String for UI simplicity for now, or can be GeoPoint
  final String imageUrl;
  final String type; // 'LOST' or 'FOUND'
  final String category;
  final String status; // 'OPEN', 'RESOLVED'
  final DateTime date;
  final GeoPoint? geoPoint; // Optional for now

  ItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.type,
    required this.category,
    this.status = 'OPEN',
    required this.date,
    this.geoPoint,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json, String docId) {
    return ItemModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: json['type'] ?? 'LOST',
      category: json['category'] ?? 'General',
      status: json['status'] ?? 'OPEN',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      geoPoint: json['geoPoint'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'type': type,
      'category': category,
      'status': status,
      'date': Timestamp.fromDate(date),
      'geoPoint': geoPoint,
    };
  }
}

class ClaimModel {
  final String id;
  final String itemId;
  final String claimantId;
  final String finderId; // The user who posted the FOUND item
  final String claimantName;
  final String claimantAvatar;
  final String status; // 'PENDING', 'ACCEPTED', 'REJECTED'
  final String proofDescription;
  final List<String> proofImages;
  final DateTime timestamp;
  final String? rejectionReason; // Added field

  ClaimModel({
    required this.id,
    required this.itemId,
    required this.claimantId,
    required this.finderId,
    required this.claimantName,
    required this.claimantAvatar,
    required this.status,
    required this.proofDescription,
    required this.proofImages,
    required this.timestamp,
    this.rejectionReason,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json, String docId) {
    return ClaimModel(
      id: docId,
      itemId: json['itemId'] ?? '',
      claimantId: json['claimantId'] ?? '',
      finderId: json['finderId'] ?? '',
      claimantName: json['claimantName'] ?? '',
      claimantAvatar: json['claimantAvatar'] ?? '',
      status: json['status'] ?? 'PENDING',
      proofDescription: json['proofDescription'] ?? '',
      proofImages: List<String>.from(json['proofImages'] ?? []),
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'claimantId': claimantId,
      'finderId': finderId,
      'claimantName': claimantName,
      'claimantAvatar': claimantAvatar,
      'status': status,
      'proofDescription': proofDescription,
      'proofImages': proofImages,
      'timestamp': Timestamp.fromDate(timestamp),
      'rejectionReason': rejectionReason,
    };
  }
}

class AppBadge {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint; // Storing as code point for simplicity in JSON/DB if needed, or just mapped constant
  final int colorValue;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.colorValue,
  });
}

class BadgeConstants {
  static const List<AppBadge> allBadges = [
    AppBadge(
      id: 'trusted_finder',
      name: 'Trusted Finder',
      description: 'Returned your first item successfully.',
      iconCodePoint: 0xe699, // Icons.verified
      colorValue: 0xFF64B5F6,
    ),
    AppBadge(
      id: 'golden_hand',
      name: 'Golden Hand',
      description: 'Returned 5 items. You are a hero!',
      iconCodePoint: 0xf55e, // Icons.back_hand (approx) or Icons.volunteer_activism
      colorValue: 0xFFFFB74D,
    ),
    AppBadge(
      id: 'verity_vanguard',
      name: 'Verity Vanguard',
      description: 'Returned 10 items. A legend of honesty.',
      iconCodePoint: 0xe556, // Icons.shield
      colorValue: 0xFF81C784,
    ),
    AppBadge(
      id: 'golden_heart',
      name: 'Golden Heart',
      description: 'Returned 20 items. Pure benevolence.',
      iconCodePoint: 0xe25b, // Icons.favorite
      colorValue: 0xFFE57373,
    ),
  ];

  static AppBadge? getBadge(String id) {
    try {
      return allBadges.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
