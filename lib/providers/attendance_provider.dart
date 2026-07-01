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

  Future<void> fetchRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('attendance')
          .select()
          .order('date', ascending: false);

      _records = (response as List).map((m) => AttendanceRecord.fromMap(m)).toList();
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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('attendance').insert({
        'date': date.toIso8601String(),
        'headcount': headcount,
        'department': department,
      });
      
      await fetchRecords();
      return true;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
