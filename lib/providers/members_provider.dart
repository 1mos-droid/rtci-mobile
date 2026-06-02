import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String? department;
  final String? phone;
  final String? status;

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.department,
    this.phone,
    this.status,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'],
      phone: map['phone'],
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
