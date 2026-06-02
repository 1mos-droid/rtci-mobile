import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BibleStudyModule {
  final String id;
  final String title;
  final String? subtitle;
  final int sessions;
  final int progress;

  BibleStudyModule({
    required this.id,
    required this.title,
    required this.sessions,
    required this.progress,
    this.subtitle,
  });

  factory BibleStudyModule.fromMap(Map<String, dynamic> map) {
    return BibleStudyModule(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      sessions: map['sessions'] ?? 1,
      progress: map['progress'] ?? 0,
    );
  }
}

class ResourceItem {
  final String id;
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
