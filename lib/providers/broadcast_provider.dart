import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BroadcastMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String target;
  final String channel;
  final String subject;
  final String body;
  final DateTime createdAt;
  final String category;

  BroadcastMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.target,
    required this.channel,
    required this.subject,
    required this.body,
    required this.createdAt,
    required this.category,
  });

  factory BroadcastMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BroadcastMessage(
      id: doc.id,
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? '',
      target: data['target'] ?? '',
      channel: data['channel'] ?? '',
      subject: data['subject'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '',
    );
  }
}

class BroadcastProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<BroadcastMessage> _messages = [];
  bool _isLoading = false;

  List<BroadcastMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchBroadcasts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('broadcasts')
          .orderBy('created_at', descending: true)
          .get();

      _messages = snapshot.docs.map((doc) => BroadcastMessage.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching broadcasts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendBroadcast({
    required String target,
    required String channel,
    required String subject,
    required String body,
    required String category,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Fetch sender name from profiles
      final profileDoc = await _firestore.collection('profiles').doc(user.uid).get();
      final senderName = profileDoc.data()?['name'] ?? 'Official';

      await _firestore.collection('broadcasts').add({
        'sender_id': user.uid,
        'sender_name': senderName,
        'target': target,
        'channel': channel,
        'subject': subject,
        'body': body,
        'category': category,
        'created_at': FieldValue.serverTimestamp(),
      });

      await fetchBroadcasts();
      return true;
    } catch (e) {
      debugPrint('Error sending broadcast: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
