import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChurchMember {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? department;
  final String? avatarUrl;

  ChurchMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
    this.avatarUrl,
  });

  String get name => fullName; // Support getter name mismatch

  factory ChurchMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChurchMember(
      id: doc.id,
      fullName: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'member',
      department: data['department'],
      avatarUrl: data['avatar_url'],
    );
  }
}

class MembersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChurchMember> _members = [];
  bool _isLoading = false;

  List<ChurchMember> get members => _members;
  bool get isLoading => _isLoading;

  MembersProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchMembers();
      } else {
        _members = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('profiles').get();
      _members = snapshot.docs.map((doc) => ChurchMember.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
