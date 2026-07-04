import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:rtc_mobile/domain/auth/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('profiles').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> register(String fullName, String email, String password, {String? department}) async {
    final res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (res.user != null) {
      await _firestore.collection('profiles').doc(res.user!.uid).set({
        'name': fullName,
        'email': email,
        'department': department,
        'role': 'member',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('profiles').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<String> uploadAvatar(String uid, File imageFile) async {
    final fileName = 'avatar_$uid.jpg';
    final ref = _storage.ref().child('avatars').child(fileName);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Ensure Google Sign In is initialized with serverClientId
      await _googleSignIn.initialize(
        serverClientId: '381753713314-0bjahjac04c2ibr5m7b6a780meni572s.apps.googleusercontent.com',
      );

      final gsi.GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final gsi.GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Retrieve access token via authorizationClient
      final authorization = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // On Android 14+ Credential Manager may throw GetCredentialException if no saved accounts exist.
      // In this case, we catch the error to prevent app crash and let the UI handle it.
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> createProfileIfMissing(User user) async {
    final doc = await _firestore.collection('profiles').doc(user.uid).get();
    if (!doc.exists) {
      await _firestore.collection('profiles').doc(user.uid).set({
        'name': user.displayName ?? 'Member',
        'email': user.email,
        'role': 'member',
        'avatar_url': user.photoURL,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
