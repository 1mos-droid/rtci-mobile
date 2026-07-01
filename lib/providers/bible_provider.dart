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
                walk(item['items'] as List<dynamic>);
              }
            }
          }
        }

        if (data['content'] is List) {
          walk(data['content'] as List<dynamic>);
        }

        final List<BibleVerse> versesList = [];
        for (var id in verseOrder) {
          final map = verseMap[id]!;
          final String rawText = map['text'] as String;
          final String text = version == 'GENZ' ? translateToGenZ(rawText) : rawText;
          final int? vNum = int.tryParse(map['number'] as String);
          
          final parts = chapterId.split('.');
          final bookName = parts.isNotEmpty ? parts[0] : '';
          final int chapterNum = parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) : 1;

          versesList.add(BibleVerse(
            id: id,
            book: bookName,
            chapter: chapterNum,
            verse: vNum ?? 1,
            content: text,
          ));
        }
        _verses = versesList;
      } else {
        debugPrint('Failed to load chapter content: ${response.statusCode}');
        _verses = [];
      }
    } catch (e) {
      debugPrint('Error fetching verses: $e');
      _verses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVerses(String book, int chapter) async {
    _isLoading = true;
    notifyListeners();
    try {
      String bookId = book;
      if (_books.isNotEmpty) {
        final found = _books.firstWhere(
          (b) => b['name'].toString().toLowerCase() == book.toLowerCase() ||
                 b['id'].toString().toLowerCase() == book.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (found.isNotEmpty) {
          bookId = found['id'] as String;
        }
      }
      final chapterId = '$bookId.$chapter';
      await fetchChapterContent('KJV', chapterId);
    } catch (e) {
      debugPrint('Error in fetchVerses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const Map<String, String> slangDictionary = {
    // === THE DEEP LORE (Idioms & Phrases) ===
    "weeping and gnashing of teeth": "malding and coping",
    "kingdom of heaven": "the W server",
    "kingdom of god": "the OG's server",
    "son of man": "bro",
    "holy spirit": "the ultimate vibe",
    "holy ghost": "the ultimate vibe",
    "eye for an eye": "matching energy",
    "flesh and blood": "IRL stuff",
    "give up the ghost": "log off for good",
    "and it came to pass": "so basically",
    "verily, verily": "no cap fr fr",
    "gird up thy loins": "lock in",
    "woe unto": "massive L for",
    "in the beginning": "day one",
    "fear not": "don't panic chat",
    "peace be unto you": "good vibes only",
    "laid hands on": "caught hands from",
    "lifted up his voice": "started yapping",
    "fell on his face": "ate dirt",
    "cast out": "yeeted",
    "yielded up the ghost": "respawn timer started",
    "alpha and omega": "first and last boss",

    // === DIVINE & SUPERNATURAL ===
    "lord": "Big Bro",
    "god": "the OG",
    "jehovah": "the Creator",
    "satan": "the biggest hater",
    "devil": "the final boss",
    "demon": "griefer",
    "demons": "trolls",
    "angel": "mod",
    "angels": "the mods",
    "heaven": "W tier", 
    "hell": "Ohio",
    "abyss": "the backrooms",
    "sheol": "the shadow realm",

    // === ROLES, TITLES & PEOPLE ===
    "king": "CEO", 
    "master": "boss",
    "servant": "NPC", 
    "prophet": "influencer", 
    "disciple": "mutual",
    "apostle": "day one homie",
    "pharisees": "gatekeepers",
    "scribe": "reddit mod",
    "hypocrite": "poser with zero aura",
    "sinner": "walking L",
    "saints": "the real ones",
    "brethren": "the squad",
    "multitude": "chat", 
    "gentiles": "the normies",
    "virgin": "simp-free",
    "harlot": "thot",
    "fool": "goofball",
    "wise": "big brain",

    // === ITEMS, GEAR & LOOT ===
    "garments": "fit",
    "raiment": "drip",
    "cloak": "hoodie",
    "sword": "blicky",
    "shield": "plot armor",
    "spear": "pokey stick",
    "chariot": "whip", 
    "chariots": "whips",
    "crown": "W hat",
    "throne": "gaming chair",
    "money": "the bag", 
    "gold": "the bag", 
    "silver": "crypto",
    "shekels": "V-Bucks",
    "bread": "carbs",
    "wine": "juice",
    "water": "hydration",
    "altar": "the setup",
    "tabernacle": "the crib",
    "temple": "the main stage",

    // === KJV ACTIONS & VERBS ===
    "repent": "rebrand", 
    "rejoice": "pop off",
    "weep": "cry about it", 
    "forsake": "ghost", 
    "smite": "cancel", 
    "slay": "unalive",
    "crucify": "cancel",
    "resurrect": "respawn",
    "baptize": "vibe check",
    "covet": "simp for", 
    "pray": "manifest", 
    "fasting": "starving fr",
    "sin": "take an L",
    "sinned": "took an L",
    "saith": "yaps",
    "spake": "dropped info",
    "sayest": "saying",
    "crieth": "yelling",
    "hearken": "listen up chat",
    "tarry": "stick around",
    "beseech": "beg",
    "begat": "spawned",
    "smote": "clapped",
    "cleave": "stick like glue",
    "rend": "rip up",
    "knoweth": "knows the tea",
    "loveth": "simps for",
    "maketh": "cooks up",
    "goeth": "dips",
    "cometh": "pulls up",
    "walketh": "struts",

    // === KJV CONCEPTS ===
    "miracle": "main character energy", 
    "judgment": "the vibe check", 
    "parable": "storytime",
    "wisdom": "the tea", 
    "enemies": "the opps", 
    "temptation": "intrusive thoughts", 
    "flesh": "the ick", 
    "spirit": "the vibes",
    "gospel": "the lore", 
    "truth": "fax", 
    "testament": "lore drop",
    "covenant": "pinky promise",
    "wilderness": "the middle of nowhere",
    "famine": "zero snacks",
    "pestilence": "a massive debuff",
    "salvation": "the ultimate W", 
    "grace": "the ultimate pass",
    "glory": "aesthetic",
    "wrath": "crashing out",
    "woe": "big yikes", 
    "iniquity": "sus behavior",
    "abomination": "cringe",

    // === ADJECTIVES & DESCRIPTORS ===
    "verily": "no cap", 
    "greatly": "highkey", 
    "blessed": "living your best life", 
    "righteous": "based",
    "righteousness": "positive aura",
    "wicked": "sus", 
    "holy": "top tier",
    "sacred": "untouchable",
    "cursed": "shadowbanned",
    "almighty": "busted OP",
    "meek": "lowkey",
    "proud": "ego-lifting",

    // === GRAMMAR, PRONOUNS & CONNECTORS ===
    "thee": "you", 
    "thou": "you", 
    "thy": "your", 
    "thine": "yours", 
    "ye": "y'all",
    "thyself": "your own self",
    "myself": "my main character",
    "art": "are",
    "shalt": "gonna",
    "wilt": "will",
    "hath": "has", 
    "doth": "does", 
    "hast": "have",
    "didst": "did",
    "unto": "to",
    "upon": "on",
    "whence": "from where",
    "hither": "here",
    "thither": "there",
    "wherefore": "why",
    "therefore": "so",
    "thus": "like this",
    "moreover": "plus",
    "nevertheless": "anyways",
    "yea": "fr fr", 
    "nay": "nah",
    "alas": "bruh",
    "lo": "peep this",
    "behold": "look bro",
    "lest": "or else",
    "forthwith": "ASAP",
    "hitherto": "up till now",
    "wherewith": "with what",
    "therein": "in there"
  };

  static String translateToGenZ(String text) {
    if (text.isEmpty) return "";
    String result = text;

}
