import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildCheckIn {
  final String id;
  final String childName;
  final String? parentName;
  final String? parentPhone;
  final String guardianId;
  final DateTime checkInTime;
  final String status;
  final String? tagNumber;

  ChildCheckIn({
    required this.id, 
    required this.childName, 
    required this.guardianId, 
    required this.checkInTime, 
    required this.status,
    this.parentName,
    this.parentPhone,
    this.tagNumber,
  });

  factory ChildCheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildCheckIn(
      id: doc.id,
      childName: data['child_name'] ?? '',
      parentName: data['parent_name'],
      parentPhone: data['parent_phone'],
      guardianId: data['guardian_id'] ?? '',
      checkInTime: (data['check_in_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'checked_in',
      tagNumber: data['tag_number'] ?? doc.id.substring(0, 4).toUpperCase(),
    );
  }
}

class ChildrenProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChildCheckIn> _activeCheckIns = [];
  bool _isLoading = false;

  List<ChildCheckIn> get activeCheckIns => _activeCheckIns;
  List<ChildCheckIn> get checkins => _activeCheckIns; // Support getter name mismatch
  bool get isLoading => _isLoading;

  ChildrenProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchActiveCheckIns();
      } else {
        _activeCheckIns = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchActiveCheckIns() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('child_checkins')
          .where('status', isEqualTo: 'checked_in')
          .get();
      _activeCheckIns = snapshot.docs.map((doc) => ChildCheckIn.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching children check-ins: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn({
    required String childName,
    required String parentName,
    required String parentPhone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('child_checkins').add({
        'child_name': childName,
        'parent_name': parentName,
        'parent_phone': parentPhone,
        'guardian_id': _auth.currentUser?.uid,
        'check_in_time': FieldValue.serverTimestamp(),
        'status': 'checked_in',
        'tag_number': 'T-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      });
      await fetchActiveCheckIns();
      return true;
    } catch (e) {
      debugPrint('Error checking in child: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOut(String id) async {
    try {
      await _firestore.collection('child_checkins').doc(id).update({
        'status': 'checked_out',
        'check_out_time': FieldValue.serverTimestamp(),
      });
      await fetchActiveCheckIns();
    } catch (e) {
      debugPrint('Error checking out child: $e');
    }
  }
}
