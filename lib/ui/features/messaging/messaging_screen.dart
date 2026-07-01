import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';

class BroadcastMessage {
  final String id;
  final String sender;
  final String target;
  final String mode;
  final String subject;
  final String body;
  final DateTime date;
  final String category;

  BroadcastMessage({
    required this.id,
    required this.sender,
    required this.target,
    required this.mode,
    required this.subject,
    required this.body,
    required this.date,
    required this.category,
  });
}

class OutboxItem {
  final String id;
  final String target;
  final String mode;
  final String subject;
  final String body;
  final DateTime timestamp;

  OutboxItem({
    required this.id,
    required this.target,
    required this.mode,
    required this.subject,
    required this.body,
    required this.timestamp,
  });
}

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  String _selectedTarget = 'All Members';
  String _selectedMode = 'Push Notification';
  String _selectedCategory = 'Pastoral Word';
  bool _simulateOffline = false;
  bool _isSubmitting = false;

  final List<String> _targets = ['All Members', 'Transformation Choir', 'Intercessors Core', 'Youth Roundtable'];
  final List<String> _modes = ['Push Notification', 'Secure Email', 'SMS Broadcast'];
  final List<String> _categories = ['Pastoral Word', 'General Sanctuary', 'Financial Update', 'Ministerial Announcement'];

  final List<BroadcastMessage> _feedMessages = [
    BroadcastMessage(
      id: 'msg-1',
      sender: "Bishop Vance Kingsley",
      target: "All Members",
      mode: "Push Notification",
      subject: "A Spiritual Decree of Divine Multiplication",
      body: "Beloved congregation, as we approach the Supernatural Acceleration Conference, I decree an opening of heavenly portals. Prepare your hearts for a massive influx of spiritual fire and financial breakthroughs. We start fasting and prayers this Tuesday.",
      date: DateTime.now().subtract(const Duration(hours: 3)),
      category: "Pastoral Word",
    ),
    BroadcastMessage(
      id: 'msg-2',
      sender: "Elder John Sterling",
      target: "Intercessors Core",
      mode: "Secure Email",
      subject: "Weekly Vigil Directives & Warfare Points",
      body: "Intercessors, our Friday vigil will focus on tearing down spiritual walls and securing the conference grounds. Please check the attachment in your emails for specific scripture focuses. Let us remain steadfast in prayer.",
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: "General Sanctuary",
    ),
    BroadcastMessage(
      id: 'msg-3',
      sender: "Pastor Alexander Vance",
      target: "All Members",
      mode: "SMS Broadcast",
      subject: "Sanctuary Ledger Audits Complete",
      body: "Dear Covenant Members, our annual financial audits are complete. The ledger remains healthy, and building fund milestones are 85% achieved. We express deep gratitude for your sacrificial tithing and offerings. Detailed reports are available in the office.",
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: "Financial Update",
    ),
  ];

  final List<OutboxItem> _outbox = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(String senderName) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (_simulateOffline) {
      setState(() {
        _outbox.insert(
          0,
          OutboxItem(
            id: 'out-${DateTime.now().millisecondsSinceEpoch}',
            target: _selectedTarget,
            mode: _selectedMode,
            subject: _subjectController.text,
            body: _bodyController.text,
            timestamp: DateTime.now(),
          ),
        );
        _isSubmitting = false;
        _subjectController.clear();
        _bodyController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Broadcaster offline. Message queued in Sanctuary Outbox! ⚠️"),
          backgroundColor: Colors.orange,
        ),
      );
      
      _tabController.animateTo(1);
    } else {
      setState(() {
        _feedMessages.insert(
          0,
          BroadcastMessage(
            id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
            sender: senderName,
            target: _selectedTarget,
            mode: _selectedMode,
            subject: _subjectController.text,
            body: _bodyController.text,
            date: DateTime.now(),
            category: _selectedCategory,
          ),
        );
        _isSubmitting = false;
        _subjectController.clear();
        _bodyController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sanctuary Broadcast transmitted successfully! 🕊️"),
          backgroundColor: Colors.green,
        ),
      );
      
      _tabController.animateTo(0);
    }
  }

  void _handleRetryOutbox(OutboxItem item, String senderName) async {
    if (_simulateOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Still offline. Sanctuary connection not restored yet. ❌"),
          backgroundColor: ObsidianTheme.primaryCrimson,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transmitting message from Sanctuary Outbox... ⏳"),
          backgroundColor: Colors.blue,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      setState(() {
        _feedMessages.insert(
          0,
          BroadcastMessage(
            id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
            sender: senderName,
            target: item.target,
            mode: item.mode,
            subject: item.subject,
            body: item.body,
            date: DateTime.now(),
            category: "General Sanctuary",
          ),
        );
        _outbox.removeWhere((x) => x.id == item.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Message successfully delivered and purged from Outbox! ✅"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    final isLeader = user?.isDeptHead ?? false;

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: ObsidianTheme.textVibrant, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Communication Center",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
          bottom: isLeader
              ? TabBar(
                  controller: _tabController,
                  indicatorColor: ObsidianTheme.secondaryGold,
                  labelColor: ObsidianTheme.primaryCrimson,
                  unselectedLabelColor: ObsidianTheme.textMuted,
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    const Tab(text: "Broadcast Feed"),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Compose"),
                          if (_outbox.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                              child: Text(
                                "${_outbox.length}",
                                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        ),
        body: SafeArea(
          child: isLeader
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeedTab(),
                    _buildComposeTab(user?.name ?? 'Member'),
                  ],
                )
              : _buildFeedTab(),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SANCTUARY ANNOUNCEMENTS",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.5,
                      color: ObsidianTheme.secondaryGold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "Congregational Feed",
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ObsidianTheme.textVibrant,
                ),
              ),
              Text(
                "Read divine updates, letters from the pastoral desk, and regional cell developments.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: _feedMessages.isEmpty
              ? Center(
                  child: Text(
                    "No broadcasts received yet.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: _feedMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _feedMessages[index];
                    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(msg.date);
                    
                    GlassBorderType border = GlassBorderType.normal;
                    if (msg.category == 'Pastoral Word') border = GlassBorderType.gold;
                    if (msg.category == 'Financial Update') border = GlassBorderType.crimson;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GlassCard(
                        padding: const EdgeInsets.all(18),
                        borderType: border,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ObsidianTheme.secondaryGold.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: ObsidianTheme.secondaryGold.withValues(alpha: 0.3), width: 0.5),
                                  ),
                                  child: Text(
                                    msg.category.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: ObsidianTheme.secondaryGold,
                                    ),
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              msg.subject,
                              style: GoogleFonts.cinzel(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: ObsidianTheme.textVibrant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "TO: ${msg.target.toUpperCase()} • VIA: ${msg.mode.toUpperCase()}",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                color: ObsidianTheme.textMuted,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Divider(color: ObsidianTheme.borderHairline, height: 20),
                            Text(
                              msg.body,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12.5,
                                    color: ObsidianTheme.textVibrant,
                                    height: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "BROADCAST BY: ${msg.sender.toUpperCase()}",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ObsidianTheme.secondaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildComposeTab(String senderName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_outbox.isNotEmpty) ...[
              Text(
                "PENDING SANCTUARY OUTBOX (${_outbox.length})",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.orange,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _outbox.length,
                itemBuilder: (context, idx) {
                  final item = _outbox[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      borderType: GlassBorderType.crimson,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "OFFLINE TRANSMISSION QUEUED ⚠️",
                                style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.delete_outline, size: 16, color: ObsidianTheme.primaryCrimson),
                                onPressed: () {
                                  setState(() {
                                    _outbox.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.subject,
                            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 14, color: ObsidianTheme.textVibrant),
                          ),
                          Text(
                            "Target: ${item.target} | Mode: ${item.mode}",
                            style: TextStyle(fontSize: 10, color: ObsidianTheme.textMuted),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 32,
                                child: TextButton.icon(
                                  icon: Icon(Icons.sync_outlined, size: 14, color: ObsidianTheme.secondaryGold),
                                  label: Text(
                                    "RETRY DELIVERY",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ObsidianTheme.secondaryGold,
                                    ),
                                  ),
                                  onPressed: () => _buildOfflineRetryAlert(item, senderName),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            Text(
              "COMPOSE BROADCAST",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.0,
                    color: ObsidianTheme.textVibrant,
                  ),
            ),
            const SizedBox(height: 8),

            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: ObsidianTheme.surfaceDark,
                    style: TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Category"),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedTarget,
                    dropdownColor: ObsidianTheme.surfaceDark,
                    style: TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Target"),
                    items: _targets.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTarget = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedMode,
                    dropdownColor: ObsidianTheme.surfaceDark,
                    style: TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(labelText: "Channel"),
                    items: _modes.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMode = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _subjectController,
                    style: TextStyle(color: ObsidianTheme.textVibrant),
                    decoration: const InputDecoration(
                      labelText: "Subject",
                      hintText: "E.g., Pastoral Greetings",
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Subject is required" : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Message Body",
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Message body is required" : null,
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(
                      "Simulate offline status?",
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: ObsidianTheme.textMuted),
                    ),
                    value: _simulateOffline,
                    activeThumbColor: Colors.orange,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _simulateOffline = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_outlined),
                    label: const Text("Initiate Broadcast"),
                    onPressed: _isSubmitting ? null : () => _handleSendMessage(senderName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildOfflineRetryAlert(OutboxItem item, String senderName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ObsidianTheme.surfaceDark,
          title: Text(
            "Outbox Transmission",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
          ),
          content: Text(
            _simulateOffline
                ? "Broadcasting console is offline. Deactivate the offline simulator in the 'Compose' tab to retry delivery."
                : "Deliver this broadcast update to members of ${item.target} now?",
            style: const TextStyle(color: ObsidianTheme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleRetryOutbox(item, senderName);
              },
              child: Text(
                "DELIVER NOW",
                style: TextStyle(color: _simulateOffline ? Colors.grey : ObsidianTheme.secondaryGold, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
