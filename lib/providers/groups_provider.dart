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
      type: data['type'],
      description: data['description'],
      campus: data['campus'],
    );
  }
}

class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<CellGroup> _groups = [];
  Set<String> _joinedGroupIds = {};
  bool _isLoading = false;

  List<CellGroup> get groups => _groups;
  Set<String> get joinedGroupIds => _joinedGroupIds;
  bool get isLoading => _isLoading;

  GroupsProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchGroups();
        _fetchUserMemberships(user.uid);
      } else {
        _groups = [];
        _joinedGroupIds = {};
        notifyListeners();
      }
    });
  }

  Future<void> fetchGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('cell_groups').get();
      _groups = snapshot.docs.map((doc) => CellGroup.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserMemberships(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('group_memberships')
          .where('user_id', isEqualTo: userId)
          .get();
      _joinedGroupIds = snapshot.docs.map((doc) => doc.data()['group_id'] as String).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching memberships: $e');
    }
  }

  Future<bool> toggleJoin(String groupId) async {
    if (_joinedGroupIds.contains(groupId)) {
      return await leaveGroup(groupId);
    } else {
      return await joinGroup(groupId);
    }
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('cell_groups').doc(groupId).update({
        'member_count': FieldValue.increment(1),
      });
      
      await _firestore.collection('group_memberships').add({
        'group_id': groupId,
        'user_id': user.uid,
        'joined_at': FieldValue.serverTimestamp(),
      });

      _joinedGroupIds.add(groupId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error joining group: $e');
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('cell_groups').doc(groupId).update({
        'member_count': FieldValue.increment(-1),
      });
      
      final snapshot = await _firestore
          .collection('group_memberships')
          .where('group_id', isEqualTo: groupId)
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      _joinedGroupIds.remove(groupId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error leaving group: $e');
      return false;
    }
  }

  Future<bool> addGroup({
    required String name,
    required String leaderName,
    required String location,
    required String type,
    String? description,
    String? campus,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('cell_groups').add({
        'name': name,
        'leader_name': leaderName,
        'location': location,
        'member_count': 0,
        'type': type,
        'description': description ?? '',
        'campus': campus ?? 'Main',
      });
      await fetchGroups();
      return true;
    } catch (e) {
      debugPrint('Error adding group: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('cell_groups').doc(groupId).delete();
      
      // Clean up memberships belonging to this group
      final membershipsSnapshot = await _firestore
}