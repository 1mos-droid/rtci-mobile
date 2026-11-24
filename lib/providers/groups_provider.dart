import 'dart:async';
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
  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  List<CellGroup> _groups = [];
  Set<String> _joinedGroupIds = {};
  bool _isLoading = false;
  String? _error;
  String? get error => _error;

  List<CellGroup> get groups => _groups;
  Set<String> get joinedGroupIds => _joinedGroupIds;
  bool get isLoading => _isLoading;

  GroupsProvider() {
    _init();
  }

  void _init() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (_disposed) return;
      _groups = [];
      _joinedGroupIds = {};
      notifyListeners();
      if (user != null) {
        fetchGroups();
        _fetchUserMemberships(user.uid);
      }
    });
  }

  Future<void> fetchGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('cell_groups').get();
      _groups = snapshot.docs
          .map((doc) => CellGroup.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'We couldn’t load groups. Please try again.';
      debugPrint('Error fetching groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserMemberships(String userId) async {
    try {
      final snapshots = await Future.wait([
        _firestore
            .collectionGroup('members')
            .where('user_id', isEqualTo: userId)
            .get(),
        _firestore
            .collection('group_memberships')
            .where('user_id', isEqualTo: userId)
            .get(),
      ]);
      if (_disposed || _auth.currentUser?.uid != userId) return;
      _joinedGroupIds = {
        for (final snapshot in snapshots)
          for (final doc in snapshot.docs) doc.data()['group_id'] as String,
      };
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

      final membership = _firestore
          .collection('cell_groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(membership);
        if (!existing.exists) {
          transaction.set(membership, {
            'group_id': groupId,
            'user_id': user.uid,
            'joined_at': FieldValue.serverTimestamp(),
          });
        }
      });

      if (_disposed || _auth.currentUser?.uid != user.uid) return false;
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

      await _firestore
          .collection('cell_groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid)
          .delete();
      // Remove any old, randomly keyed memberships belonging to this account.
      final legacy = await _firestore
          .collection('group_memberships')
          .where('user_id', isEqualTo: user.uid)
          .get();
      for (final doc in legacy.docs.where(
        (doc) => doc.data()['group_id'] == groupId,
      )) {
        await doc.reference.delete();
      }

      if (_disposed || _auth.currentUser?.uid != user.uid) return false;
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
          .collection('group_memberships')
          .where('group_id', isEqualTo: groupId)
          .get();
      for (final doc in membershipsSnapshot.docs) {
        await doc.reference.delete();
      }

      await fetchGroups();
      return true;
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
