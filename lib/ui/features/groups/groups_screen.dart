import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/skeleton_loader.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _filterType = 'All';

  void _handleJoinToggle(GroupsProvider groupsProv, String groupId, String groupName) async {
    final success = await groupsProv.toggleJoin(groupId);
    if (success && mounted) {
      final isJoined = groupsProv.joinedGroupIds.contains(groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isJoined ? "Joined $groupName successfully!" : "Withdrawn from $groupName."),
          backgroundColor: isJoined ? Colors.green : ObsidianTheme.primaryCrimson,
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
    String selectedType = 'home_cell'; // home_cell (Group) or ministry (Department)

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E202C) : const Color(0xFFE0E5EC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Create New Group",
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: ObsidianTheme.textVibrant),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController, 
                      decoration: const InputDecoration(labelText: "Group Name"),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: leaderController, 
                      decoration: const InputDecoration(labelText: "Leader Name"),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController, 
                      decoration: const InputDecoration(labelText: "Location/Meeting Point"),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController, 
                      decoration: const InputDecoration(labelText: "Description"),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: campusController, 
                      decoration: const InputDecoration(labelText: "Campus (e.g. Main)"),
                      style: TextStyle(color: ObsidianTheme.textVibrant),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "Type"),
                      dropdownColor: isDark ? const Color(0xFF1E202C) : const Color(0xFFE0E5EC),
                      items: const [
                        DropdownMenuItem(value: 'home_cell', child: Text("Group")),
                        DropdownMenuItem(value: 'ministry', child: Text("Department")),
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
                  child: Text("CANCEL", style: TextStyle(color: ObsidianTheme.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final leader = leaderController.text.trim();
                    final location = locationController.text.trim();
                    final desc = descController.text.trim();
                    final campus = campusController.text.trim();
                    if (name.isNotEmpty && leader.isNotEmpty && location.isNotEmpty) {
                      Navigator.pop(dialogContext);
                      final success = await ref.read(groupsProvider).addGroup(
                        name: name,
                        leaderName: leader,
                        location: location,
                        type: selectedType,
                        description: desc.isEmpty ? null : desc,
                        campus: campus.isEmpty ? 'Main' : campus,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Group created successfully!"))
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ObsidianTheme.primaryCrimson, foregroundColor: Colors.white),
                  child: const Text("CREATE"),
                ),
              ],
            );
          }
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
            if (_filterType == 'Department') return g.type == 'ministry' || g.type == 'volunteer_rota';
            return true;
          }).toList();

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
            "Groups Directory",
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ObsidianTheme.textVibrant,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: isAdmin ? FloatingActionButton(
          backgroundColor: ObsidianTheme.primaryCrimson,
          onPressed: _showAddGroupDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ) : null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: ['All', 'Groups', 'Department'].map((type) {
                    final isSel = type == _filterType;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Center(child: Text(type.toUpperCase())),
                          selected: isSel,
                          selectedColor: ObsidianTheme.secondaryGold.withValues(alpha: 0.2),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSel ? ObsidianTheme.secondaryGold : ObsidianTheme.borderHairline,
                              width: 0.8,
                            ),
                          ),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSel ? ObsidianTheme.secondaryGold : ObsidianTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _filterType = type);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: groupsProv.isLoading && rawList.isEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: 3,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: GlassCard(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SkeletonContainer(width: 80, height: 16, borderRadius: 6),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SkeletonContainer(width: 120, height: 10),
                                      SizedBox(height: 4),
                                      SkeletonContainer(width: 80, height: 10),
                                    ],
                                  ),
                                  SkeletonContainer(width: 110, height: 38, borderRadius: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : list.isEmpty
                    ? Center(
                        child: Text(
                          "No directory records logged.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final grp = list[index];
                          final isJoined = groupsProv.joinedGroupIds.contains(grp.id);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GlassCard(
                              padding: const EdgeInsets.all(18),
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
                                          border: Border.all(color: ObsidianTheme.secondaryGold.withValues(alpha: 0.3), width: 0.5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          (grp.type == 'home_cell' ? 'GROUP' : (grp.type ?? 'General')).toUpperCase().replaceAll('_', ' '),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: ObsidianTheme.secondaryGold,
                                          ),
                                        ),
                                      ),
                                      if (isAdmin)
                                        IconButton(
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    grp.name,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: ObsidianTheme.textVibrant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    grp.description ?? 'No description provided.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Divider(color: ObsidianTheme.borderHairline, height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "LEADER: ${grp.leaderName.toUpperCase() ?? 'UNASSIGNED'}",
                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                    fontSize: 8.5,
                                                    color: ObsidianTheme.textMuted,
                                                  ),
                                            ),
                                            if (grp.campus != null)
                                              Text(
                                                "CAMPUS: ${grp.campus!.toUpperCase()}",
                                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                      fontSize: 8.5,
                                                      color: ObsidianTheme.textMuted,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      
                                      SizedBox(
                                        width: 110,
                                        height: 38,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isJoined ? Colors.transparent : ObsidianTheme.secondaryGold,
                                            foregroundColor: isJoined ? ObsidianTheme.textVibrant : ObsidianTheme.backgroundDark,
                                            side: isJoined ? BorderSide(color: ObsidianTheme.borderHairline) : null,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => _handleJoinToggle(groupsProv, grp.id, grp.name),
                                          child: Text(
                                            isJoined ? "WITHDRAW" : "REQUEST JOIN",
                                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
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
          ),
        ),
      ),
    );
  }
}