import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/providers/bible_provider.dart';

class LiveBibleScreen extends ConsumerStatefulWidget {
  const LiveBibleScreen({super.key});

  @override
  ConsumerState<LiveBibleScreen> createState() => _LiveBibleScreenState();
}

class _LiveBibleScreenState extends ConsumerState<LiveBibleScreen> {
  final _noteController = TextEditingController();
  List<String> _savedNotes = [];

  final String _selectedVersion = 'KJV';
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
    final bibleProv = ref.read(bibleProvider);
    await bibleProv.fetchBooks(_selectedVersion);
    if (bibleProv.books.isNotEmpty && mounted) {
      setState(() {
        _selectedBookId = bibleProv.books[0]['id'];
      });
      _loadChapters();
    }
  }

  void _loadChapters() async {
    if (_selectedBookId == null) return;
    final bibleProv = ref.read(bibleProvider);
    await bibleProv.fetchChapters(_selectedVersion, _selectedBookId!);
    if (bibleProv.chapters.isNotEmpty && mounted) {
      setState(() {
        _selectedChapterId = bibleProv.chapters[0]['id'];
      });
      _loadContent();
    }
  }

  void _loadContent() {
    if (_selectedChapterId == null) return;
    final bibleProv = ref.read(bibleProvider);
    bibleProv.fetchChapterContent(_selectedVersion, _selectedChapterId!);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNotes = prefs.getStringList('bible_notes') ?? [];
    });
  }

  Future<void> _saveNote() async {
    if (_noteController.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _savedNotes.add(_noteController.text);
    await prefs.setStringList('bible_notes', _savedNotes);
    _noteController.clear();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Revelation preserved.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleProv = ref.watch(bibleProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 120.0,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Bible",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSelector(
                      context,
                      label: _selectedBookId != null 
                        ? bibleProv.books.firstWhere((b) => b['id'] == _selectedBookId)['name']
                        : "Book",
                      onTap: () => _showBookPicker(context, bibleProv),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: _buildSelector(
                      context,
                      label: _selectedChapterId != null 
                        ? bibleProv.chapters.firstWhere((c) => c['id'] == _selectedChapterId)['number'].toString()
                        : "Ch",
                      onTap: () => _showChapterPicker(context, bibleProv),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (bibleProv.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (bibleProv.verses.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("Select a chapter to begin reading.")),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final v = bibleProv.verses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontSize: 18,
                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9),
                          ),
                          children: [
                            TextSpan(
                              text: "${v.verse} ",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(text: v.content),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: bibleProv.verses.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
      bottomSheet: _buildNotesPanel(context),
    );
  }

  Widget _buildSelector(BuildContext context, {required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
        ),
        body: Column(
          children: [
            _buildSelectors(bibleProv),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReader(bibleProv),
                    const SizedBox(height: 32),
                    _buildNotePad(),
                    if (_savedNotes.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      _buildNotesList(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors(BibleProvider bibleProv) {
    return Container(
      color: ObsidianTheme.surfaceDark.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
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
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: "Ch.",
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required dynamic value, required List<String> items, List<String>? itemLabels, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ObsidianTheme.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ObsidianTheme.borderHairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(label, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 16)),
          dropdownColor: ObsidianTheme.backgroundDark,
          iconSize: 32,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
    if (bibleProv.verses.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("Select a chapter to read.", style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 18))));

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bibleProv.verses.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${v['number']}  ",
                    style: GoogleFonts.plusJakartaSans(color: ObsidianTheme.secondaryGold, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextSpan(
                    text: v['text'],
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, height: 1.6, fontSize: 20),
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
    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ObsidianTheme.primaryCrimson.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: ObsidianTheme.secondaryGold),
              const SizedBox(width: 8),
              Text("TAKE NOTES", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: ObsidianTheme.textVibrant)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: "Write your thoughts here...", 
              hintStyle: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 18), 
              filled: true,
              fillColor: ObsidianTheme.backgroundDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveNote, 
            style: ElevatedButton.styleFrom(
              backgroundColor: ObsidianTheme.primaryCrimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("SAVE NOTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("YOUR SAVED NOTES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0)),
        const SizedBox(height: 16),
        ..._savedNotes.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(padding: const EdgeInsets.all(20), child: Text(n, style: const TextStyle(color: ObsidianTheme.textVibrant, fontSize: 16, height: 1.4))),
        )),
      ],
    );
  }
}
