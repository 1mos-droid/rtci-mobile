import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveBibleScreen extends ConsumerStatefulWidget {
  const LiveBibleScreen({super.key});

  @override
  ConsumerState<LiveBibleScreen> createState() => _LiveBibleScreenState();
}

class _LiveBibleScreenState extends ConsumerState<LiveBibleScreen> {
  final _noteController = TextEditingController();
  List<String> _savedNotes = [];
  String? _notesUid;

  final String _selectedVersion = 'KJV';
  String? _selectedBookId;
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    _notesUid = ref.read(authNotifierProvider).value?.id;
    _loadNotes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initBible();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
    if (!mounted ||
        _notesUid == null ||
        ref.read(authNotifierProvider).value?.id != _notesUid) {
      return;
    }
    setState(() {
      _savedNotes = prefs.getStringList('rtci_bible_notes_$_notesUid') ?? [];
    });
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty || _notesUid == null) return;
    final note = _noteController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || ref.read(authNotifierProvider).value?.id != _notesUid) {
      return;
    }
    _savedNotes.add(note);
    await prefs.setStringList('rtci_bible_notes_$_notesUid', _savedNotes);
    if (!mounted) return;
    _noteController.clear();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Note saved.")));
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
                style: TextStyle(
                  fontFamily: 'Inter',
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
                          ? bibleProv.books.firstWhere(
                              (b) => b['id'] == _selectedBookId,
                            )['name']
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
                          ? bibleProv.chapters
                                .firstWhere(
                                  (c) => c['id'] == _selectedChapterId,
                                )['number']
                                .toString()
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
              child: Center(child: CustomLogoLoader(size: 48)),
            )
          else if (bibleProv.error != null)
            SliverFillRemaining(
              child: FeatureState(
                icon: Icons.cloud_off_outlined,
                title: 'Bible reading is unavailable',
                message: bibleProv.error!,
                actionLabel: 'Try again',
                onAction: () {
                  if (bibleProv.books.isEmpty) {
                    _initBible();
                  } else if (_selectedChapterId == null) {
                    _loadChapters();
                  } else {
                    _loadContent();
                  }
                },
              ),
            )
          else if (bibleProv.verses.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("Select a chapter to begin reading.")),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final v = bibleProv.verses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: 18,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black.withOpacity(0.9),
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
                }, childCount: bibleProv.verses.length),
              ),
            ),
          if (bibleProv.copyright.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  bibleProv.copyright,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
      bottomSheet: _buildNotesPanel(context),
    );
  }

  Widget _buildSelector(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
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
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
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
                style: TextStyle(
                  fontFamily: 'Inter',
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
                .where(
                  (b) => b['name'].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                )
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
                      style: TextStyle(
                        fontFamily: 'Inter',
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
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Search books...",
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
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
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              book['name'],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                  )
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
                style: TextStyle(
                  fontFamily: 'Inter',
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
                              : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          chapter['number'].toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
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
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
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
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _noteController,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15),
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
}
