import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeadershipProfile {
  final String id;
  final String name;
  final String title;
  final String department;
  final String? avatarUrl;

  LeadershipProfile({required this.id, required this.name, required this.title, required this.department, this.avatarUrl});

  factory LeadershipProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadershipProfile(
      id: doc.id,
      name: data['name'] ?? '',
      title: data['title'] ?? 'Leader',
      department: data['department'] ?? '',
      avatarUrl: data['avatar_url'],
    );
  }
}

class LeadershipProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<LeadershipProfile> _leaders = [];
  bool _isLoading = false;

  List<LeadershipProfile> get leaders => _leaders;
  bool get isLoading => _isLoading;

  LeadershipProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchLeaders();
      } else {
        _leaders = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchLeaders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('profiles')
          .where('role', whereIn: ['admin', 'department_head', 'developer'])
          .get();
      _leaders = snapshot.docs.map((doc) => LeadershipProfile.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching leaders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
