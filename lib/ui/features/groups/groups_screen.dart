import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/skeleton_loader.dart';
import 'package:rtc_mobile/widgets/feature_state.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _filterType = 'All';
  final Set<String> _updatingGroups = {};

  void _handleJoinToggle(
    GroupsProvider groupsProv,
    String groupId,
    String groupName,
  ) async {
    if (_updatingGroups.contains(groupId)) return;
    setState(() => _updatingGroups.add(groupId));
    final success = await groupsProv.toggleJoin(groupId);
    if (!mounted) return;
    setState(() => _updatingGroups.remove(groupId));
    if (success && mounted) {
      final isJoined = groupsProv.joinedGroupIds.contains(groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isJoined
                ? "Joined $groupName successfully!"
                : "Withdrawn from $groupName.",
          ),
          backgroundColor: isJoined
              ? Colors.green
              : ObsidianTheme.primaryCrimson,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Action failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    final leaderController = TextEditingController();
    final locationController = TextEditingController();
    final descController = TextEditingController();
    final campusController = TextEditingController();
    String selectedType =
        'home_cell'; // home_cell (Group) or ministry (Department)

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark
                  ? const Color(0xFF1E202C)
                  : const Color(0xFFE0E5EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                "Create New Group",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Group Name",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: leaderController,
                      decoration: const InputDecoration(
                        labelText: "Leader Name",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location/Meeting Point",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: campusController,
                      decoration: const InputDecoration(
                        labelText: "Campus (e.g. Main)",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "Type"),
                      dropdownColor: isDark
                          ? const Color(0xFF1E202C)
                          : const Color(0xFFE0E5EC),
                      items: const [
                        DropdownMenuItem(
                          value: 'home_cell',
                          child: Text("Group"),
                        ),
                        DropdownMenuItem(
                          value: 'ministry',
                          child: Text("Department"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedType = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final leader = leaderController.text.trim();
                    final location = locationController.text.trim();
                    final desc = descController.text.trim();
                    final campus = campusController.text.trim();
                    if (name.isNotEmpty &&
                        leader.isNotEmpty &&
                        location.isNotEmpty) {
                      Navigator.pop(dialogContext);
                      final success = await ref
                          .read(groupsProvider)
                          .addGroup(
                            name: name,
                            leaderName: leader,
                            location: location,
                            type: selectedType,
                            description: desc.isEmpty ? null : desc,
                            campus: campus.isEmpty ? 'Main' : campus,
                          );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Group created successfully!"),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primaryCrimson,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("CREATE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsProv = ref.watch(groupsProvider);
    final user = ref.watch(authNotifierProvider).value;
    final isAdmin = user?.isAdmin ?? false;
    final rawList = groupsProv.groups;

    final list = _filterType == 'All'
        ? rawList
        : rawList.where((g) {
            if (_filterType == 'Groups') return g.type == 'home_cell';
            if (_filterType == 'Ministries') {
              return g.type == 'ministry' || g.type == 'volunteer_rota';
            }
            return true;
          }).toList();

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
            "Groups",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                backgroundColor: ObsidianTheme.primaryCrimson,
                onPressed: _showAddGroupDialog,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', 'Groups', 'Ministries']
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type),
                          selected: type == _filterType,
                          onSelected: (selected) {
                            if (selected) setState(() => _filterType = type);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: groupsProv.isLoading && rawList.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: GlassCard(
                            padding: EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SkeletonContainer(
                                      width: 80,
                                      height: 16,
                                      borderRadius: 6,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                SkeletonContainer(width: 180, height: 20),
                                SizedBox(height: 8),
                                SkeletonContainer(width: 250, height: 14),
                                SizedBox(height: 4),
                                SkeletonContainer(width: 140, height: 14),
                                Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SkeletonContainer(
                                          width: 120,
                                          height: 10,
                                        ),
                                        SizedBox(height: 4),
                                        SkeletonContainer(
                                          width: 80,
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                    SkeletonContainer(
                                      width: 120,
                                      height: 48,
                                      borderRadius: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : groupsProv.error != null && rawList.isEmpty
                    ? FeatureState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Groups are unavailable',
                        message: groupsProv.error!,
                        actionLabel: 'Try again',
                        onAction: groupsProv.fetchGroups,
                      )
                    : list.isEmpty
                    ? FeatureState(
                        icon: Icons.people_outline_rounded,
                        title: 'Find your people',
                        message: _filterType == 'All'
                            ? 'Groups will appear here when your church adds them.'
                            : 'There are no groups in this category yet.',
                        actionLabel: _filterType == 'All'
                            ? 'Refresh'
                            : 'Show all groups',
                        onAction: () {
                          if (_filterType == 'All') {
                            groupsProv.fetchGroups();
                          } else {
                            setState(() => _filterType = 'All');
                          }
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final grp = list[index];
                          final isJoined = groupsProv.joinedGroupIds.contains(
                            grp.id,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ObsidianTheme.secondaryGold
                                              .withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: ObsidianTheme.secondaryGold
                                                .withValues(alpha: 0.3),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          (grp.type == 'home_cell'
                                                  ? 'GROUP'
                                                  : (grp.type ?? 'General'))
                                              .toUpperCase()
                                              .replaceAll('_', ' '),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: ObsidianTheme.secondaryGold,
                                          ),
                                        ),
                                      ),
                                      if (isAdmin)
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          onPressed: () => ref
                                              .read(groupsProvider)
                                              .deleteGroup(grp.id),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    grp.name,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    grp.description ??
                                        'No description provided.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    height: 24,
                                  ),
                                  Text(
                                    'Led by ${grp.leaderName}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  if (grp.campus != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Campus: ${grp.campus}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonal(
                                      onPressed:
                                          _updatingGroups.contains(grp.id)
                                          ? null
                                          : () => _handleJoinToggle(
                                              groupsProv,
                                              grp.id,
                                              grp.name,
                                            ),
                                      child: Text(
                                        _updatingGroups.contains(grp.id)
                                            ? 'Please wait…'
                                            : isJoined
                                            ? 'Leave group'
                                            : 'Join group',
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
            ],
          ),
        ),
      ),
    );
  }
}
