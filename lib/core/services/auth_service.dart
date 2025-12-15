import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user model: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create User Document
      if (cred.user != null) {
        final userModel = UserModel(
          uid: cred.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: '',
        );
        await _db.collection('users').doc(cred.user!.uid).set(userModel.toJson());
      }
      
      return cred;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
