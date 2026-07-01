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
      status: map['status'],
    );
  }
}

class MembersProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Member> _members = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  MembersProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
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
      final response = await _supabase
          .from('members')
          .select()
          .order('name', ascending: true);

      _members = (response as List).map((m) => Member.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerMember({
    required String name,
    required String email,
    String? phone,
    String? department,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('members').insert({
        'name': name,
        'email': email,
        'phone': phone,
        'department': department,
        'status': 'active',
      });
      
      await fetchMembers();
      return true;
    } catch (e) {
      debugPrint('Error registering member: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
