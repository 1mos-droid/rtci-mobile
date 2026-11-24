import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/prayer_request.dart';

class PrayerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  List<PrayerRequest> _prayers = [];
  bool _isLoading = false;

  List<PrayerRequest> get prayers => _prayers;
  bool get isLoading => _isLoading;

  PrayerProvider() {
    _init();
  }

  void _init() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _prayers = [];
      notifyListeners();
      if (user != null) {
        fetchPrayers();
      } else {
        _prayers = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchPrayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _prayers = [];
        return;
      }
      final profile = await _firestore
          .collection('profiles')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      final admin = ['admin', 'developer'].contains(profile.data()?['role']);
      final prayers = _firestore.collection('prayer_requests');
      final snapshots = admin
          ? [await prayers.get(const GetOptions(source: Source.server))]
          : await Future.wait([
              prayers
                  .where('is_private', isEqualTo: false)
                  .where('is_anonymous', isEqualTo: false)
                  .get(const GetOptions(source: Source.server)),
              prayers
                  .where('user_id', isEqualTo: user.uid)
                  .get(const GetOptions(source: Source.server)),
            ]);
      if (_disposed || _auth.currentUser?.uid != user.uid) return;
      final byId = {
        for (final snapshot in snapshots)
          for (final doc in snapshot.docs)
            doc.id: PrayerRequest.fromFirestore(doc),
      };
      _prayers = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error fetching prayers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle both named and positional arguments for UI flexibility
  Future<bool> submitPrayer(
    String content, [
    bool isPrivate = false,
    String? category,
  ]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await _firestore.collection('prayer_requests').add({
        'content': content,
        'user_id': user.uid,
        'user_name': isPrivate ? 'Anonymous' : (user.displayName ?? 'Member'),
        'is_anonymous': isPrivate,
        'is_private': isPrivate,
        'category': category ?? 'General',
        'status': 'pending',
        'intercession_count': 0,
        'created_at': FieldValue.serverTimestamp(),
      });
      await fetchPrayers();
      return true;
    } catch (e) {
      debugPrint('Error submitting prayer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supportPrayer(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final supporter = _firestore
          .collection('prayer_requests')
          .doc(id)
          .collection('supporters')
          .doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(supporter);
        if (!snapshot.exists) {
          transaction.set(supporter, {
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      });
      await fetchPrayers();
    } catch (e) {
      debugPrint('Error supporting prayer: $e');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _firestore.collection('prayer_requests').doc(id).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      await fetchPrayers();
    } catch (e) {
      debugPrint('Error updating prayer status: $e');
    }
  }
}
