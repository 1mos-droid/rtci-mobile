import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
  static const String apiKey = 'loPsbJCaWjl5ITSeS4WWD';
  static const String baseUrl = 'https://rest.api.bible/v1';

  static const Map<String, String> versionMap = {
    'KJV': 'de4e12af7f28f599-01',
    'NKJV': '179568874c45066f-01',
    'NIV': '65eec8e0b60e656b-01',
    'AMP': '06125adad2d5898a-01',
    'GENZ': 'de4e12af7f28f599-01',
  };

  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _chapters = [];
  List<BibleVerse> _verses = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get books => _books;
  List<Map<String, dynamic>> get chapters => _chapters;
  List<BibleVerse> get verses => _verses;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks(String version) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bibleId = versionMap[version] ?? versionMap['KJV']!;
      final url = Uri.parse('$baseUrl/bibles/$bibleId/books');
      final response = await http.get(url, headers: {'api-key': apiKey});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        _books = list.map((item) => {
          'id': item['id'] as String,
          'name': item['name'] as String,
          'nameLong': item['nameLong'] as String? ?? '',
        }).toList();
      } else {
        debugPrint('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChapters(String version, String bookId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bibleId = versionMap[version] ?? versionMap['KJV']!;
      final url = Uri.parse('$baseUrl/bibles/$bibleId/books/$bookId/chapters');
      final response = await http.get(url, headers: {'api-key': apiKey});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        _chapters = list
            .map((item) {
              final String numStr = item['number'] as String;
              return {
                'id': item['id'] as String,
                'number': int.tryParse(numStr) ?? numStr,
              };
            })
            .where((item) => item['number'] != 'intro')
            .toList();
      } else {
        debugPrint('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChapterContent(String version, String chapterId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bibleId = versionMap[version] ?? versionMap['KJV']!;
      final url = Uri.parse(
        '$baseUrl/bibles/$bibleId/chapters/$chapterId'
        '?content-type=json&include-notes=false&include-titles=true'
        '&include-chapter-numbers=false&include-verse-numbers=true',
      );
      final response = await http.get(url, headers: {'api-key': apiKey});
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> data = responseData['data'] ?? {};
        
        final Map<String, Map<String, dynamic>> verseMap = {};
        final List<String> verseOrder = [];

        void walk(List<dynamic>? items) {
          if (items == null) return;
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              if (item['type'] == 'text' && item['attrs'] is Map && item['attrs']['verseId'] != null) {
                final String vId = item['attrs']['verseId'];
                final String vNumStr = vId.split('.').last;
                if (!verseMap.containsKey(vId)) {
                  verseMap[vId] = {'number': vNumStr, 'text': ''};
                  verseOrder.add(vId);
                }
                verseMap[vId]!['text'] = (verseMap[vId]!['text'] as String) + (item['text'] ?? '');
              }
              if (item['items'] is List) {
              walk(item['items']);
            }
          } else if (item is List) {
            for (var subItem in item) {
              walk(subItem);
            }
          }
        }

        walk(data['content']);
        _verses = extractedVerses;
      }
    } catch (e) {
      debugPrint('Error fetching chapter content: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
