import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyModule {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int progress;
  final String? subtitle;

  StudyModule({required this.id, required this.title, required this.description, required this.imageUrl, this.progress = 0, this.subtitle});

  factory StudyModule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyModule(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      progress: data['progress'] ?? 0,
      subtitle: data['subtitle'],
    );
  }
}

class StudyResource {
  final String id;
  final String moduleId;
  final String title;
  final String? type;
  final String? link;

  ResourceItem({
    required this.id,
    required this.title,
    this.type,
    this.link,
  });

  factory ResourceItem.fromMap(Map<String, dynamic> map) {
    return ResourceItem(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      type: map['type'],
      link: map['link'],
    );
  }
}

class BibleStudiesProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<BibleStudyModule> _modules = [];
  List<ResourceItem> _resources = [];
  bool _isLoading = false;

  List<BibleStudyModule> get modules => _modules;
  List<ResourceItem> get resources => _resources;
  bool get isLoading => _isLoading;

  BibleStudiesProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchLibrary();
      } else {
        _modules = [];
        _resources = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchLibrary() async {
    _isLoading = true;
    notifyListeners();

    try {
      final modulesRes = await _supabase
          .from('bible_studies')
          .select()
          .order('created_at', ascending: false);

      final resourcesRes = await _supabase
          .from('resources')
          .select()
          .order('created_at', ascending: false);

      _modules = (modulesRes as List).map((m) => BibleStudyModule.fromMap(m)).toList();
      _resources = (resourcesRes as List).map((m) => ResourceItem.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error fetching library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
