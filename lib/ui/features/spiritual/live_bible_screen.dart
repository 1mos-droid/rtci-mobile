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
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, 
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded, 
              size: 20, 
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookPicker(BuildContext context, BibleProvider prov) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String searchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardTheme.color ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredBooks = prov.books
                .where((b) => b['name']
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select Book",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) {
                        setSheetState(() {
                          searchQuery = val;
                        });
                      },
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Search books...",
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          final isSelected = book['id'] == _selectedBookId;
                          return ListTile(
                            onTap: () {
                              setState(() {
                                _selectedBookId = book['id'];
                                _selectedChapterId = null;
                              });
                              _loadChapters();
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text(
                              book['name'],
                              style: GoogleFonts.inter(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isSelected 
                                ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChapterPicker(BuildContext context, BibleProvider prov) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Select Chapter",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: prov.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = prov.chapters[index];
                    final isSelected = chapter['id'] == _selectedChapterId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedChapterId = chapter['id'];
                        });
                        _loadContent();
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          chapter['number'].toString(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesPanel(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.85),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            width: 1.0,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _noteController,
                        style: GoogleFonts.inter(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: "Jot down a revelation...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveNote,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
