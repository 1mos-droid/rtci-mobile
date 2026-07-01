import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CellGroup {
  final String id;
  final String name;
  final String leaderName;
  final String location;
  final int memberCount;
  final String? type;
  final String? description;
  final String? campus;

  CellGroup({
    required this.id, 
    required this.name, 
    required this.leaderName, 
    required this.location, 
    required this.memberCount,
    this.type,
    this.description,
    this.campus,
  });

  factory CellGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CellGroup(
      id: doc.id,
      name: data['name'] ?? '',
      leaderName: data['leader_name'] ?? '',
      location: data['location'] ?? '',
      memberCount: data['member_count'] ?? 0,
      leaderName: map['leader'] != null ? map['leader']['name'] : null,
      campus: map['campus'],
    );
  }
}

class GroupsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Group> _groups = [];
  Set<String> _joinedGroupIds = Set();
  bool _isLoading = false;

  List<Group> get groups => _groups;
  Set<String> get joinedGroupIds => _joinedGroupIds;
  bool get isLoading => _isLoading;

  GroupsProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchGroups();
        fetchMyMemberships();
      } else {
        _groups = [];
        _joinedGroupIds = Set();
        notifyListeners();
      }
    });
  }

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('groups')
          .select('*, leader:members!leader_id(name)')
          .order('name', ascending: true);

      _groups = (response as List).map((m) => Group.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyMemberships() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get member ID
      final memberRes = await _supabase
          .from('members')
          .select('id')
          .eq('email', user.email!)
          .maybeSingle();

      if (memberRes != null) {
        final memberId = memberRes['id'];
        final memberships = await _supabase
            .from('group_members')
            .select('group_id')
            .eq('member_id', memberId);
        
        _joinedGroupIds = (memberships as List).map((m) => m['group_id'] as String).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching memberships: $e');
    }
  }

  Future<bool> toggleJoin(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final memberRes = await _supabase
          .from('members')
          .select('id')
          .eq('email', user.email!)
          .maybeSingle();

      if (memberRes == null) return false;
      final memberId = memberRes['id'];

      if (_joinedGroupIds.contains(groupId)) {
        await _supabase
            .from('group_members')
            .delete()
            .eq('group_id', groupId)
            .eq('member_id', memberId);
        _joinedGroupIds.remove(groupId);
      } else {
        await _supabase
            .from('group_members')
            .insert({'group_id': groupId, 'member_id': memberId});
        _joinedGroupIds.add(groupId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling group: $e');
      return false;
    }
  }
}
