import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRecord {
  final String id;
  final DateTime date;
  final int headcount;
  final String? department;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.headcount,
    this.department,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id']?.toString() ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      headcount: map['headcount'] ?? 0,
      department: map['department'],
    );
  }
}

class AttendanceProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;

  AttendanceProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchRecords();
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
