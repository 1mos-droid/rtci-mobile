import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryItem {
  final String id;
  final String imageUrl;
  final String title;
  final String? description;
  final DateTime date;

  GalleryItem({required this.id, required this.imageUrl, required this.title, this.description, required this.date});

  String get url => imageUrl; // Support getter name mismatch

  factory GalleryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryItem(
      id: doc.id,
      imageUrl: data['image_url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class GalleryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<GalleryItem> _items = [];
  bool _isLoading = false;

  List<GalleryItem> get items => _items;
  List<GalleryItem> get images => _items; // Support getter name mismatch
  bool get isLoading => _isLoading;

  GalleryProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchGallery();
      } else {
        _items = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchGallery() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('gallery')
          .orderBy('date', descending: true)
          .get();
      _items = snapshot.docs.map((doc) => GalleryItem.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadImage(File file) async {
    final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref().child('gallery').child(fileName);
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  Future<bool> addGalleryItem({
    required String imageUrl,
    required String title,
    required String description,
    required DateTime date,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('gallery').add({
        'image_url': imageUrl,
        'title': title,
        'description': description,
        'date': Timestamp.fromDate(date),
        'created_at': FieldValue.serverTimestamp(),
      });
      await fetchGallery();
      return true;
    } catch (e) {
      debugPrint('Error adding gallery item: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGalleryItem(String itemId, String imageUrl) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Try to delete from storage
      try {
        if (imageUrl.contains('firebasestorage.googleapis.com')) {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        }
      } catch (e) {
        debugPrint('Error deleting storage file: $e');
      }

      // 2. Delete from Firestore
      await _firestore.collection('gallery').doc(itemId).delete();
      await fetchGallery();
      return true;
    } catch (e) {
      debugPrint('Error deleting gallery item: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
