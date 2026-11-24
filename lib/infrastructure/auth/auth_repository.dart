import 'package:rtc_mobile/firebase_options.dart';
import 'package:rtc_mobile/services/notification_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/utils/image_upload.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (doc.exists) {
        return AppUser.fromFirestore(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Once the account exists, registration has succeeded: profile setup
  /// failures are logged and retried by [createProfileIfMissing] on next load,
  /// which falls back to the display name saved on the account here.
  Future<User?> register(
    String fullName,
    String email,
    String password, {
    String? department,
  }) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) return null;
    try {
      await user.updateDisplayName(fullName);
      // The auth listener may create a default profile concurrently; when it
      // wins, only the name may be changed by the owner (see firestore.rules).
      final doc = _firestore.collection('profiles').doc(user.uid);
      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(doc);
        if (snapshot.exists) {
          tx.update(doc, {'name': fullName});
        } else {
          tx.set(doc, {
            'name': fullName,
            'email': user.email ?? email,
            'department': department,
            'role': 'member',
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('Profile setup deferred after registration: $e');
    }
    return _auth.currentUser ?? user;
  }

  Future<void> logout() async {
    await NotificationService().clearToken();
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Google session cleanup unavailable: $error');
    }
    await _auth.signOut();
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('profiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<String> uploadAvatar(String uid, File imageFile) async {
    final fileName = 'avatar_$uid.jpg';
    final ref = _storage.ref().child('avatars').child(fileName);
    await ref.putFile(imageFile, await validatedImageMetadata(imageFile));
    return await ref.getDownloadURL();
  }

  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      try {
        await _googleSignIn.initialize(
          clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
          serverClientId:
              '381753713314-0bjahjac04c2ibr5m7b6a780meni572s.apps.googleusercontent.com',
        );
        _googleSignInInitialized = true;
      } catch (e) {
        debugPrint('GoogleSignIn initialize: $e');
        _googleSignInInitialized = false;
        rethrow;
      }
    }
  }

  Future<UserCredential> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);
    if (credential.user != null) await createProfileIfMissing(credential.user!);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        if (credential.user != null) {
          await createProfileIfMissing(credential.user!);
        }
        return credential;
      }
      await _ensureGoogleSignInInitialized();

      final gsi.GoogleSignInAccount googleUser = await _googleSignIn
          .authenticate();
      final gsi.GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-token',
          message: 'Google could not complete sign-in. Please try again.',
        );
      }
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await createProfileIfMissing(userCredential.user!);
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> createProfileIfMissing(User user) async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) {
        final displayName =
            (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!
            : (user.email != null && user.email!.contains('@')
                  ? user.email!.split('@')[0]
                  : 'Member');
        await _firestore.collection('profiles').doc(user.uid).set({
          'name': displayName,
          'email': user.email ?? '',
          'role': 'member',
          'avatar_url': user.photoURL,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error creating profile if missing: $e');
    }
  }
}
