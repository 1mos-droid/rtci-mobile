import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { member, department_head, admin, developer, guest }

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';
  UserRole _role = UserRole.guest;
  bool _isLoading = false;
  String? _department;

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  UserRole get role => _role;
  bool get isLoading => _isLoading;
  String? get department => _department;

  bool get isAdmin => _role == UserRole.admin || _role == UserRole.developer;
  bool get isDeptHead => _role == UserRole.department_head || _role == UserRole.admin || _role == UserRole.developer;
  bool get isDeveloper => _role == UserRole.developer;

  AuthProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _isAuthenticated = true;
        _userEmail = session.user.email ?? '';
        _fetchProfile(session.user.id);
      } else {
        _isAuthenticated = false;
        _userName = '';
        _userEmail = '';
        _role = UserRole.guest;
        _department = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _userName = data['name'] ?? 'Member';
        final roleStr = data['role'] ?? 'member';
        _department = data['department'];

        switch (roleStr) {
          case 'developer': _role = UserRole.developer; break;
          case 'admin': _role = UserRole.admin; break;
          case 'department_head': _role = UserRole.department_head; break;
          default: _role = UserRole.member;
        }
      } else {
        _userName = _userEmail.split('@')[0];
        _role = UserRole.member;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _role = UserRole.member;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, {bool asLeadership = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': fullName,
          'role': 'member',
        },
      );
      
      if (res.user != null) {
        // Trigger handle_new_user should take care of the profile creation
        _isLoading = false;
        return true;
      }
      _isLoading = false;
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
