import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceRecord {
  final String id;
  final String serviceName;
  final DateTime date;
  final int count;
  final String? department;

  AttendanceRecord({required this.id, required this.serviceName, required this.date, required this.count, this.department});

  int get headcount => count; // Support getter name mismatch

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      serviceName: data['service_name'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      count: data['count'] ?? 0,
      department: data['department'],
    );
  }
}

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;

  AttendanceProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchAttendance();
      } else {
        _records = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('attendance')
          .orderBy('date', descending: true)
          .get();
      _records = snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRecord({
    required DateTime date,
    required int headcount,
    String? department,
    String serviceName = 'General Service',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('attendance').add({
        'service_name': serviceName,
        'count': headcount,
        'department': department,
        'date': Timestamp.fromDate(date),
        'logged_by': _auth.currentUser?.uid,
      });
      await fetchAttendance();
      return true;
    } catch (e) {
      debugPrint('Error logging attendance: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
