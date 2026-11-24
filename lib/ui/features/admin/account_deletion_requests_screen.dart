import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';

class AccountDeletionRequestsScreen extends ConsumerStatefulWidget {
  const AccountDeletionRequestsScreen({super.key});
  @override
  ConsumerState<AccountDeletionRequestsScreen> createState() =>
      _AccountDeletionRequestsScreenState();
}

class _AccountDeletionRequestsScreenState
    extends ConsumerState<AccountDeletionRequestsScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _requests;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _requests = FirebaseFirestore.instance
        .collection('account_deletion_requests')
        .orderBy('created_at', descending: true)
        .limit(100)
        .get(const GetOptions(source: Source.server));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Account deletion requests')),
      body: user?.isAdmin != true
          ? const FeatureState(
              icon: Icons.lock_outline,
              title: 'Administrator access required',
              message:
                  'Account deletion requests are available to church administrators.',
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: _requests,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CustomLogoLoader(
                        message: 'Loading requests…',
                      );
                    }
                    if (snapshot.hasError) {
                      return FeatureState(
                        icon: Icons.cloud_off_outlined,
                        title: 'Requests are unavailable',
                        message: 'Check your connection and try again.',
                        actionLabel: 'Try again',
                        onAction: () => setState(_reload),
                      );
                    }
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return const FeatureState(
                        icon: Icons.check_circle_outline,
                        title: 'No deletion requests',
                        message:
                            'Submitted requests will appear here for administrator review.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(_reload);
                        await _requests;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: documents.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Text(
                              'Review requests promptly and process them within the 30-day period in the privacy policy. Verify account ownership and any required financial-record retention before removal.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.6),
                            );
                          }
                          final document = documents[index - 1];
                          final data = document.data();
                          final created = (data['created_at'] as Timestamp?)
                              ?.toDate();
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account: ${document.id}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${data['status'] ?? 'pending'}',
                                  ),
                                  if (created != null)
                                    Text(
                                      'Submitted ${DateFormat.yMMMd().format(created)}',
                                    ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.copy_outlined),
                                    label: const Text('Copy account ID'),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: document.id),
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Account ID copied.'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
