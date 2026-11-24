import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});
  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(broadcastProvider).fetchBroadcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broadcasts = ref.watch(broadcastProvider);
    final canPublish =
        ref.watch(authNotifierProvider).value?.isDeptHead ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Church announcements')),
      floatingActionButton: canPublish
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (_) => const _AnnouncementComposer(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Write announcement'),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: broadcasts.isLoading && broadcasts.messages.isEmpty
                ? const CustomLogoLoader(message: 'Loading announcements…')
                : broadcasts.error != null && broadcasts.messages.isEmpty
                ? FeatureState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Announcements are unavailable',
                    message: broadcasts.error!,
                    actionLabel: 'Try again',
                    onAction: broadcasts.fetchBroadcasts,
                  )
                : RefreshIndicator(
                    onRefresh: broadcasts.fetchBroadcasts,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Text(
                          'Keep your community close.',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Updates shared with your church family appear here.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (broadcasts.messages.isEmpty)
                          const FeatureState(
                            icon: Icons.campaign_outlined,
                            title: 'A quiet moment',
                            message:
                                'There are no announcements yet. New church updates will appear here.',
                          ),
                        for (final message in broadcasts.messages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.category.isEmpty
                                        ? 'Church update'
                                        : message.category,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    message.subject,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    message.body,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${message.senderName} · ${DateFormat('d MMM yyyy').format(message.createdAt)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
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

class _AnnouncementComposer extends ConsumerStatefulWidget {
  const _AnnouncementComposer();
  @override
  ConsumerState<_AnnouncementComposer> createState() =>
      _AnnouncementComposerState();
}

class _AnnouncementComposerState extends ConsumerState<_AnnouncementComposer> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String _category = 'Church update';
  bool _publishing = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_publishing || !_form.currentState!.validate()) return;
    if (!(ref.read(authNotifierProvider).value?.isDeptHead ?? false)) return;
    setState(() {
      _publishing = true;
      _error = null;
    });
    final success = await ref
        .read(broadcastProvider)
        .sendBroadcast(
          target: 'All Members',
          channel: 'app',
          subject: _subject.text.trim(),
          body: _body.text.trim(),
          category: _category,
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement published to the church feed.'),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _publishing = false;
        _error =
            'We couldn’t publish your announcement. Your draft is still here. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_publishing,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share a church update',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This announcement will be visible to members in the app.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    [
                          'Church update',
                          'Pastoral Word',
                          'Financial Update',
                          'Event',
                        ]
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: _publishing
                    ? null
                    : (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _subject,
                enabled: !_publishing,
                maxLength: 160,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Add an announcement title'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                enabled: !_publishing,
                minLines: 4,
                maxLines: 10,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Write your message'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomPrimaryButton(
                text: 'Publish announcement',
                isLoading: _publishing,
                onPressed: _publish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
