import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<dynamic> _profiles = [];
  bool _isLoading = true;
  bool _loadFailed = false;
  String? _savingId;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final snapshot = await _firestore
          .collection('profiles')
          .orderBy('name')
          .get();
      setState(() {
        _profiles = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  /// Mirrors firestore.rules, which enforce the same limits on the server:
  /// no self-changes, and developer access is managed only by developers.
  bool _canEdit(AppUser me, String profileId, UserRole role) =>
      me.isAdmin &&
      profileId != me.id &&
      (role != UserRole.developer || me.isDeveloper);

  Future<void> _changeRole(Map profile, AppUser me) async {
    final current = UserRole.fromString(profile['role']);
    final options = [
      UserRole.member,
      UserRole.departmentHead,
      UserRole.admin,
      if (me.isDeveloper) UserRole.developer,
    ];
    final selected = await showModalBottomSheet<UserRole>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Access for ${profile['name'] ?? 'this member'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final role in options)
              ListTile(
                title: Text(role.label),
                trailing: role == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, role),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == current || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change access?'),
        content: Text(
          'Make ${profile['name'] ?? 'this member'} ${selected.label}?'
          '${selected == UserRole.admin ? ' Admins can manage members, finances and other admins.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final id = profile['id'] as String;
    setState(() => _savingId = id);
    try {
      await _firestore.collection('profiles').doc(id).update({
        'role': selected.value,
      });
      if (!mounted) return;
      setState(() => profile['role'] = selected.value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${profile['name'] ?? 'Member'} is now ${selected.label}.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Role change failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Access could not be changed. Check your connection and try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authNotifierProvider).value;
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "User Management",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CustomLogoLoader(size: 48))
            : _loadFailed
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Members could not be loaded.'),
                    TextButton(
                      onPressed: _fetchProfiles,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  final role = UserRole.fromString(profile['role']);
                  final editable =
                      me != null && _canEdit(me, profile['id'], role);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ObsidianTheme.primaryCrimson
                                .withValues(alpha: 0.1),
                            child: Text(
                              profile['name']?[0] ?? 'U',
                              style: TextStyle(
                                color: ObsidianTheme.primaryCrimson,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name'] ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  profile['email'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_savingId == profile['id'])
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Semantics(
                              button: editable,
                              label: editable
                                  ? 'Change access, currently ${role.label}'
                                  : null,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: editable
                                    ? () => _changeRole(profile, me)
                                    : null,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 32,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ObsidianTheme.secondaryGold
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        role.label,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ObsidianTheme.secondaryGold,
                                        ),
                                      ),
                                      if (editable) ...[
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.expand_more_rounded,
                                          size: 16,
                                          color: ObsidianTheme.secondaryGold,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
