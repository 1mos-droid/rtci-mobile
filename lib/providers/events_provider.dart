import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChurchEvent {
  final String id;
  final String name;
  final DateTime date;
  final String time;
  final String location;
  final bool isOnline;
  final String description;
  final String? department;

  ChurchEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.isOnline,
    required this.description,
    this.department,
  });

  factory ChurchEvent.fromMap(Map<String, dynamic> map) {
    return ChurchEvent(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      isOnline: map['is_online'] ?? false,
      description: map['description'] ?? '',
      department: map['department']?.toString(),
    );
  }
}

class EventsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ChurchEvent> _events = [];
  bool _isLoading = false;

  List<ChurchEvent> get events => _events;
  bool get isLoading => _isLoading;

  EventsProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchEvents();
      } else {
        _events = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('date', ascending: true);

      _events = (response as List).map((m) => ChurchEvent.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleEvent({
    required String name,
    required DateTime date,
    required String time,
    required String location,
    bool isOnline = false,
    String? description,
    String? department,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('events').insert({
        'name': name,
        'date': date.toIso8601String(),
        'time': time,
        'location': location,
        'is_online': isOnline,
        'description': description,
        'department': department,
      });
      
      await fetchEvents();
      return true;
    } catch (e) {
      debugPrint('Error scheduling event: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
