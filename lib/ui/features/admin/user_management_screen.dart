import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/mesh_gradient_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .order('name', ascending: true);
      setState(() {
        _profiles = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "User Management",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: ObsidianTheme.textVibrant),
          ),
          centerTitle: true,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                final role = profile['role'] ?? 'member';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ObsidianTheme.primaryCrimson.withValues(alpha: 0.1),
                          child: Text(profile['name']?[0] ?? 'U', style: const TextStyle(color: ObsidianTheme.primaryCrimson)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(profile['email'] ?? '', style: const TextStyle(fontSize: 12, color: ObsidianTheme.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ObsidianTheme.secondaryGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: ObsidianTheme.secondaryGold),
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
