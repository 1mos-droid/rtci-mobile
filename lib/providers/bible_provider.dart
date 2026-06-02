import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BibleProvider extends ChangeNotifier {
  static const String _apiKey = 'loPsbJCaWjl5ITSeS4WWD';
  static const String _baseUrl = 'https://rest.api.bible/v1';

  final Map<String, String> versionMap = {
    'KJV': 'de4e12af7f28f599-01',
    'NKJV': '179568874c45066f-01',
    'NIV': '65eec8e0b60e656b-01',
    'AMP': '06125adad2d5898a-01',
  };

  List<dynamic> _books = [];
  List<dynamic> _chapters = [];
  List<Map<String, String>> _verses = [];
  bool _isLoading = false;

  List<dynamic> get books => _books;
  List<dynamic> get chapters => _chapters;
  List<Map<String, String>> get verses => _verses;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks(String versionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bibleId = versionMap[versionId] ?? versionMap['KJV']!;
      final response = await http.get(
        Uri.parse('$_baseUrl/bibles/$bibleId/books'),
        headers: {'api-key': _apiKey},
      );
      if (response.statusCode == 200) {
        _books = json.decode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChapters(String versionId, String bookId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bibleId = versionMap[versionId] ?? versionMap['KJV']!;
      final response = await http.get(
        Uri.parse('$_baseUrl/bibles/$bibleId/books/$bookId/chapters'),
        headers: {'api-key': _apiKey},
      );
      if (response.statusCode == 200) {
        _chapters = json.decode(response.body)['data'];
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChapterContent(String versionId, String chapterId) async {
    _isLoading = true;
    _verses = [];
    notifyListeners();
    try {
      final bibleId = versionMap[versionId] ?? versionMap['KJV']!;
      final response = await http.get(
        Uri.parse('$_baseUrl/bibles/$bibleId/chapters/$chapterId?content-type=json&include-notes=false&include-titles=true&include-chapter-numbers=false&include-verse-numbers=true'),
        headers: {'api-key': _apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final List<Map<String, String>> extractedVerses = [];
        
        void walk(dynamic item) {
          if (item is Map) {
            if (item['type'] == 'text' && item['attrs'] != null && item['attrs']['verseId'] != null) {
              final vId = item['attrs']['verseId'] as String;
              final vNum = vId.split('.').last;
              final vText = item['text'] as String;
              
              final existingIndex = extractedVerses.indexWhere((v) => v['number'] == vNum);
              if (existingIndex != -1) {
                extractedVerses[existingIndex]['text'] = (extractedVerses[existingIndex]['text'] ?? '') + vText;
              } else {
                extractedVerses.add({'number': vNum, 'text': vText});
              }
            }
            if (item['items'] != null) {
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
