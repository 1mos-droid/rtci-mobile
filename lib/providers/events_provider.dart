import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChurchEvent {
  final String id;
  final String name;
  final DateTime date;
  final String time;
  final String location;
  final String category;
  final bool isOnline;
  final String? department;
  final String? description;

  ChurchEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    this.isOnline = false,
    this.department,
    this.description,
  });

  factory ChurchEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChurchEvent(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? 'Service',
      isOnline: data['is_online'] ?? false,
      department: data['department'],
      description: data['description'],
    );
  }
}

class EventsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChurchEvent> _events = [];
  bool _isLoading = false;

  List<ChurchEvent> get events => _events;
  bool get isLoading => _isLoading;

  EventsProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
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
