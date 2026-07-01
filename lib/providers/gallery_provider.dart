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
  List<GalleryImage> _images = [];
  bool _isLoading = false;

  List<GalleryImage> get images => _images;
  bool get isLoading => _isLoading;

  GalleryProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchImages();
      } else {
        _images = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('service_images')
          .select()
          .order('service_date', ascending: false);

      _images = (response as List).map((m) => GalleryImage.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
