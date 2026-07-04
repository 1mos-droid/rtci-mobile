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
  final String type;
  final String url;

  StudyResource({required this.id, required this.moduleId, required this.title, required this.type, required this.url});

  factory StudyResource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyResource(
      id: doc.id,
      moduleId: data['module_id'] ?? '',
      title: data['title'] ?? '',
      type: data['type'] ?? 'pdf',
      url: data['url'] ?? '',
    );
  }
}

class BibleStudiesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<StudyModule> _modules = [];
  List<StudyResource> _resources = [];
  bool _isLoading = false;

  List<StudyModule> get modules => _modules;
  List<StudyResource> get resources => _resources;
  bool get isLoading => _isLoading;

  BibleStudiesProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchStudies();
      } else {
        _modules = [];
        _resources = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchStudies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final modulesSnapshot = await _firestore.collection('study_modules').get();
      _modules = modulesSnapshot.docs.map((doc) => StudyModule.fromFirestore(doc)).toList();
      
      final resourcesSnapshot = await _firestore.collection('study_resources').get();
      _resources = resourcesSnapshot.docs.map((doc) => StudyResource.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching study data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addModule({
    required String title,
    required String description,
    required String imageUrl,
    required String subtitle,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('study_modules').add({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'progress': 0,
        'subtitle': subtitle,
      });
      await fetchStudies();
      return true;
    } catch (e) {
      debugPrint('Error adding study module: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteModule(String moduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('study_modules').doc(moduleId).delete();
      
      // Clean up resources belonging to this module
      final resourcesSnapshot = await _firestore
          .collection('study_resources')
          .where('module_id', isEqualTo: moduleId)
          .get();
      for (final doc in resourcesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      await fetchStudies();
      return true;
    } catch (e) {
      debugPrint('Error deleting study module: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addResource({
    required String moduleId,
    required String title,
    required String type,
    required String url,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('study_resources').add({
        'module_id': moduleId,
        'title': title,
        'type': type,
        'url': url,
      });
      await fetchStudies();
      return true;
    } catch (e) {
      debugPrint('Error adding study resource: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteResource(String resourceId) async {
    _isLoading = true;
    notifyListeners();
}