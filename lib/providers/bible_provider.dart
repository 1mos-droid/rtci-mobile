import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rtc_mobile/services/backend_client.dart';

class BibleVerse {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String content;

  BibleVerse({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.content,
  });

  factory BibleVerse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BibleVerse(
      id: doc.id,
      book: data['book'] ?? '',
      chapter: data['chapter'] ?? 1,
      verse: data['verse'] ?? 1,
      content: data['content'] ?? '',
    );
  }

  // Support operator [] for compatibility with older Map-based code
  dynamic operator [](String key) {
    if (key == 'number') return verse;
    if (key == 'text') return content;
    return null;
  }
}

class BibleProvider extends ChangeNotifier {
  final BackendClient _backend;
  BibleProvider({BackendClient backend = const BackendClient()})
    : _backend = backend;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _chapters = [];
  List<BibleVerse> _verses = [];
  bool _isLoading = false;
  String? _error;
  String _copyright = '';
  String get copyright => _copyright;
  int _generation = 0;
  bool _disposed = false;

  List<Map<String, dynamic>> get books => _books;
  List<Map<String, dynamic>> get chapters => _chapters;
  List<BibleVerse> get verses => _verses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _load(
    String operation,
    String version,
    Map<String, dynamic> arguments,
    void Function(dynamic data) apply,
  ) async {
    final generation = ++_generation;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _backend.post('bibleContent', {
        'operation': operation,
        'version': version,
        ...arguments,
      });
      if (!_disposed && generation == _generation) apply(response['data']);
    } on BackendException catch (error) {
      if (!_disposed && generation == _generation) _error = error.message;
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _error = 'This chapter could not be loaded. Please try again.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchBooks(String version) =>
      _load('books', version, {}, (data) {
        if (data is! List) throw const FormatException();
        _books = data
            .map(
              (item) => <String, dynamic>{
                'id': item['id'] as String,
                'name': item['name'] as String,
                'nameLong': item['nameLong'] as String? ?? '',
              },
            )
            .toList();
      });

  Future<void> fetchChapters(String version, String bookId) {
    _chapters = [];
    _verses = [];
    return _load('chapters', version, {'bookId': bookId}, (data) {
      if (data is! List) throw const FormatException();
      _chapters = data
          .where((item) => int.tryParse(item['number'].toString()) != null)
          .map(
            (item) => <String, dynamic>{
              'id': item['id'] as String,
              'number': int.parse(item['number'].toString()),
            },
          )
          .toList();
    });
  }

  Future<void> fetchChapterContent(String version, String chapterId) {
    _verses = [];
    return _load('chapter', version, {'chapterId': chapterId}, (data) {
      if (data is! Map || data['content'] is! List) {
        throw const FormatException();
      }
      _copyright =
          (data['copyright'] is String ? data['copyright'] as String : '')
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .trim();
      final text = <String, String>{};
      void walk(List<dynamic> items, [String? verseId]) {
        for (final item in items) {
          if (item is! Map) continue;
          final attrs = item['attrs'];
          final currentId = attrs is Map && attrs['verseId'] is String
              ? attrs['verseId'] as String
              : verseId;
          if (item['type'] == 'text' &&
              currentId != null &&
              item['text'] is String) {
            text[currentId] =
                (text[currentId] ?? '') + (item['text'] as String);
          }
          if (item['items'] is List) walk(item['items'] as List, currentId);
        }
      }

      walk(data['content'] as List);
      if (text.isEmpty) throw const FormatException();
      final parts = chapterId.split('.');
      _verses = text.entries
          .map(
            (entry) => BibleVerse(
              id: entry.key,
              book: parts.first,
              chapter: int.tryParse(parts.last) ?? 1,
              verse: int.tryParse(entry.key.split('.').last) ?? 1,
              content: entry.value.trim(),
            ),
          )
          .toList();
    });
  }

  Future<void> fetchVerses(String book, int chapter) async {
    if (_books.isEmpty) await fetchBooks('KJV');
    if (_disposed || _error != null) return;
    final matching = _books.where(
      (item) =>
          item['name'].toString().toLowerCase() == book.toLowerCase() ||
          item['id'].toString().toLowerCase() == book.toLowerCase(),
    );
    final bookId = matching.isEmpty ? book : matching.first['id'];
    await fetchChapterContent('KJV', '$bookId.$chapter');
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
