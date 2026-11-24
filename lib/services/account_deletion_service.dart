import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountDeletionServiceProvider = Provider(
  (ref) => AccountDeletionService(),
);

/// A durable, identity-bound request for the church's documented deletion
/// process. Submitting a request never claims that records have been erased.
class AccountDeletionService {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  const AccountDeletionService({this.auth, this.firestore});

  Future<void> requestDeletion() async {
    final user = (auth ?? FirebaseAuth.instance).currentUser;
    if (user == null) throw StateError('Please sign in again.');
    final request = (firestore ?? FirebaseFirestore.instance)
        .collection('account_deletion_requests')
        .doc(user.uid);
    final existing = await request
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    if (existing.exists) return;
    await request
        .set({
          'user_id': user.uid,
          'status': 'pending',
          'created_at': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
  }
}
