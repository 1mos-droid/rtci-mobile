import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/bible_provider.dart';

class LiveBibleScreen extends StatefulWidget {
  const LiveBibleScreen({super.key});

  @override
  State<LiveBibleScreen> createState() => _LiveBibleScreenState();
}

class _LiveBibleScreenState extends State<LiveBibleScreen> {
  final _noteController = TextEditingController();
  List<String> _savedNotes = [];

  String _selectedVersion = 'KJV';
  String? _selectedBookId;
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBible();
    });
  }

  void _initBible() async {
    final bibleProv = Provider.of<BibleProvider>(context, listen: false);
    await bibleProv.fetchBooks(_selectedVersion);
    if (bibleProv.books.isNotEmpty) {
      setState(() {
        _selectedBookId = bibleProv.books[0]['id'];
      });
      _loadChapters();
    }
  }

  void _loadChapters() async {
    if (_selectedBookId == null) return;
    final bibleProv = Provider.of<BibleProvider>(context, listen: false);
    await bibleProv.fetchChapters(_selectedVersion, _selectedBookId!);
    if (bibleProv.chapters.isNotEmpty) {
      setState(() {
        _selectedChapterId = bibleProv.chapters[0]['id'];
      });
      _loadContent();
    }
  }

  void _loadContent() {
    if (_selectedChapterId == null) return;
    final bibleProv = Provider.of<BibleProvider>(context, listen: false);
    bibleProv.fetchChapterContent(_selectedVersion, _selectedChapterId!);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNotes = prefs.getStringList('sermon_notes_vault') ?? [];
    });
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final newNote = "${DateTime.now().toString().substring(0, 16)}: ${_noteController.text.trim()}";
    _savedNotes.insert(0, newNote);
    await prefs.setStringList('sermon_notes_vault', _savedNotes);
    if (!mounted) return;
    setState(() { _noteController.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note saved!")));
  }

  @override
  Widget build(BuildContext context) {
    final bibleProv = Provider.of<BibleProvider>(context);

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Scripture Hub",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: ObsidianTheme.textVibrant),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSelectors(bibleProv),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildReader(bibleProv),
                      const SizedBox(height: 24),
                      _buildNotePad(),
                      if (_savedNotes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildNotesList(),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(BibleProvider bibleProv) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: "Version",
                  value: _selectedVersion,
                  items: bibleProv.versionMap.keys.toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() { _selectedVersion = val; });
                      _initBible();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildDropdown(
                  label: "Book",
                  value: _selectedBookId,
                  items: bibleProv.books.map((b) => b['id'] as String).toList(),
                  itemLabels: bibleProv.books.map((b) => b['name'] as String).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() { _selectedBookId = val; });
                      _loadChapters();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            label: "Chapter",
            value: _selectedChapterId,
            items: bibleProv.chapters.map((c) => c['id'] as String).toList(),
            itemLabels: bibleProv.chapters.map((c) => c['number'] as String).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() { _selectedChapterId = val; });
                _loadContent();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required dynamic value, required List<String> items, List<String>? itemLabels, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.borderHairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(label, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
          dropdownColor: ObsidianTheme.surfaceDark,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          items: List.generate(items.length, (i) {
            return DropdownMenuItem(value: items[i], child: Text(itemLabels != null ? itemLabels[i] : items[i]));
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReader(BibleProvider bibleProv) {
    if (bibleProv.isLoading) return const Center(child: CircularProgressIndicator());
    if (bibleProv.verses.isEmpty) return const Center(child: Text("Select a chapter to read.", style: TextStyle(color: ObsidianTheme.textMuted)));

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bibleProv.verses.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${v['number']} ",
                    style: GoogleFonts.cinzel(color: ObsidianTheme.secondaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  TextSpan(
                    text: v['text'],
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, height: 1.6, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotePad() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("SERMON NOTES", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: ObsidianTheme.secondaryGold)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Insights...", hintStyle: TextStyle(color: ObsidianTheme.textMuted), border: InputBorder.none),
          ),
          ElevatedButton(onPressed: _saveNote, child: const Text("SAVE TO VAULT")),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SAVED NOTES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        ..._savedNotes.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(padding: const EdgeInsets.all(12), child: Text(n, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12))),
        )),
      ],
    );
  }
}
