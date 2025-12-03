import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final double trustScore;
  final int points;
  final List<String> badges;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.trustScore = 0.0,
    this.points = 0,
    this.badges = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      trustScore: (json['trustScore'] ?? 0.0).toDouble(),
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'trustScore': trustScore,
      'points': points,
      'badges': badges,
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
    };
  }
}
