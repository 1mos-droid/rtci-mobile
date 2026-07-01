import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareTicket {
  final String id;
  final String memberName;
  final String memberId;
  final int absenceCount;
  final String status;
  final DateTime lastChecked;

  CareTicket({
    required this.id,
    required this.memberName,
    required this.memberId,
    required this.absenceCount,
    required this.status,
    required this.lastChecked,
  });

  factory CareTicket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CareTicket(
      id: doc.id,
      memberName: data['member_name'] ?? '',
      memberId: data['member_id'] ?? '',
      absenceCount: data['absence_count'] ?? 0,
      status: data['status'] ?? 'pending',
      lastChecked: (data['last_checked'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CareProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<CareTicket> _careQueue = [];
  bool _isLoading = false;

  List<CareTicket> get careQueue => _careQueue;
  bool get isLoading => _isLoading;

  CareProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchCareQueue();
      } else {
        _careQueue = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchCareQueue() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('care_tickets')
          .where('status', isEqualTo: 'pending')
          .get();
      _careQueue = snapshot.docs.map((doc) => CareTicket.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching care queue: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveTicket(String id) async {
    try {
      await _firestore.collection('care_tickets').doc(id).update({
        'status': 'resolved',
        'resolved_at': FieldValue.serverTimestamp(),
        'resolved_by': _auth.currentUser?.uid,
          .eq('id', id);
      
      _careQueue.removeWhere((item) => item.id == id && (status == 'Resolved' || status == 'Ignored'));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating care status: $e');
    }
  }
}
