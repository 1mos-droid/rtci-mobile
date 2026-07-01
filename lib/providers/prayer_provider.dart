import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/prayer_request.dart';

class PrayerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<PrayerRequest> _prayers = [];
  bool _isLoading = false;

  List<PrayerRequest> get prayers => _prayers;
  bool get isLoading => _isLoading;

  PrayerProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
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
      final snapshot = await _firestore
          .collection('prayer_requests')
          .orderBy('created_at', descending: true)
          .get();
      _prayers = snapshot.docs.map((doc) => PrayerRequest.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching prayers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle both named and positional arguments for UI flexibility
  Future<bool> submitPrayer(String content, [bool isPrivate = false, String? category]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      await _firestore.collection('prayer_requests').add({
        'content': content,
        'user_id': user?.uid,
        'user_name': isPrivate ? 'Anonymous' : (user?.displayName ?? 'Member'),
        'is_anonymous': isPrivate,
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
      await _firestore.collection('prayer_requests').doc(id).update({
        'intercession_count': FieldValue.increment(1),
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
