import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GalleryImage {
  final String id;
  final String url;
  final String? description;
  final DateTime serviceDate;

  GalleryImage({
    required this.id,
    required this.url,
    required this.serviceDate,
    this.description,
  });

  factory GalleryImage.fromMap(Map<String, dynamic> map) {
    return GalleryImage(
      id: map['id']?.toString() ?? '',
      url: map['url'] ?? '',
      description: map['description'],
      serviceDate: DateTime.parse(map['service_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class GalleryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
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
