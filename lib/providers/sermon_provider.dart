import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtc_mobile/models/sermon.dart';

class SermonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Sermon> _sermons = [];
  bool _isLoading = false;

  List<Sermon> get sermons => _sermons;
  bool get isLoading => _isLoading;

  Future<void> fetchSermons() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('sermons')
          .orderBy('date', descending: true)
          .get();

      _sermons = snapshot.docs.map((doc) => Sermon.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching sermons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSermon({
    required String title,
    required String speaker,
    required String category,
    required String duration,
    required String imageUrl,
    required String tag,
    String? audioUrl,
    String? videoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('sermons').add({
        'title': title,
        'speaker': speaker,
        'category': category,
        'duration': duration,
        'image_url': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=500&q=80' : imageUrl,
        'tag': tag,
        'audio_url': audioUrl ?? '',
        'video_url': videoUrl ?? '',
        'date': FieldValue.serverTimestamp(),
        'logged_by': user.uid,
      });

      await fetchSermons();