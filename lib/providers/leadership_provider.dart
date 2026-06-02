import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderProfile {
  final String id;
  final String name;
  final String? title;
  final String? department;
  final String? avatarUrl;
  final String? campus;

  LeaderProfile({
    required this.id,
    required this.name,
    this.title,
    this.department,
    this.avatarUrl,
    this.campus,
  });

  factory LeaderProfile.fromMap(Map<String, dynamic> map) {
    return LeaderProfile(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      title: map['title'],
      department: map['department'],
      avatarUrl: map['avatar_url'],
      campus: map['campus'],
    );
  }
}

class LeadershipProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<LeaderProfile> _leaders = [];
  bool _isLoading = false;

  List<LeaderProfile> get leaders => _leaders;
  bool get isLoading => _isLoading;

  LeadershipProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
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
      final response = await _supabase
          .from('profiles')
          .select()
          .neq('role', 'member')
          .order('name', ascending: true);

      _leaders = (response as List).map((m) => LeaderProfile.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching leaders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
