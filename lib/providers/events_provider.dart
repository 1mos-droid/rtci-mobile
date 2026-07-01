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
      if (user != null) {
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
      final snapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: false)
          .get();
      _events = snapshot.docs.map((doc) => ChurchEvent.fromFirestore(doc)).toList();
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
    String category = 'Service',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('events').add({
        'name': name,
        'date': Timestamp.fromDate(date),
        'time': time,
        'location': location,
        'is_online': isOnline,
        'description': description,
        'department': department,
        'category': category,
        'created_at': FieldValue.serverTimestamp(),
        'created_by': _auth.currentUser?.uid,
      });
      await fetchEvents();
      return true;
    } catch (e) {
      debugPrint('Error scheduling event: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
