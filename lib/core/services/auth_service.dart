import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        await _saveUserToFirestore(cred.user!, displayName: displayName);
      }
      
      return cred;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Save user to Firestore if new
      if (userCredential.user != null) {
         // Check if user exists first to avoid overwriting existing data (like points/badges)
         final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
         if (!userDoc.exists) {
           await _saveUserToFirestore(userCredential.user!, displayName: googleUser.displayName ?? '');
         }
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user, {String displayName = ''}) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName.isNotEmpty ? displayName : (user.displayName ?? 'User'),
      photoUrl: user.photoURL ?? '',
    );
    await _db.collection('users').doc(user.uid).set(userModel.toJson());
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
