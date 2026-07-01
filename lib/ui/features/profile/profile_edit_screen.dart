import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Use ref.read for initial value to avoid rebuild loop if needed
    final authUser = ref.read(authNotifierProvider).value;
    _nameController = TextEditingController(text: authUser?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 500,
    );

    if (image != null && mounted) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final url = await authNotifier.uploadAvatar(File(image.path));
      if (url != null && mounted) {
        _showIOSAlert("Success", "Your sanctuary portrait has been updated successfully!");
      }
    }
  }

  void _showIOSAlert(String title, String message) {
    showAdaptiveDialog(
      context: context,
      builder: (_) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.updateProfile(name: _nameController.text.trim());
      
      final authState = ref.read(authNotifierProvider);
      if (!authState.hasError && mounted) {
        showAdaptiveDialog(
          context: context,
          builder: (_) => AlertDialog.adaptive(
            title: const Text("Profile Saved"),
            content: const Text("Your identity has been updated in the sanctuary records."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context); // Dismiss dialog
                  Navigator.pop(context); // Go back to previous screen
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: authState.isLoading
          ? const CustomLogoLoader(message: "Updating Records...")
          : authState.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 120.0,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(color: theme.colorScheme.primary),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Identity",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                ),
              ),
              SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Column(
                          children: [
                            // Avatar Section
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: AppTheme.systemGray6,
                                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                      child: user.avatarUrl == null
                                          ? const Icon(Icons.person_outline, size: 50, color: AppTheme.systemGray2)
                                          : null,
                                    ),
                                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _showImageSourceActionSheet(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: const Icon(CupertinoIcons.camera_fill, size: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            _buildSectionHeader("PERSONAL DETAILS"),
                            const SizedBox(height: 12),
                            Form(
                              key: _formKey,
                              child: GlassCard(
                                padding: EdgeInsets.zero,
                                child: _buildIOSInput(
                                  controller: _nameController,
                                  placeholder: "Display Name",
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                                ),
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),

                            const SizedBox(height: 48),

                            FilledButton(
                              onPressed: _handleSave,
                              child: const Text("Save Changes"),
                            ).animate().fadeIn(delay: 300.ms),

                            const SizedBox(height: 24),

                            Text(
                              "Your identity is how you are known in the sanctuary community.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.systemGray,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CustomLogoLoader(message: "Loading Profile..."),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.systemGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIOSInput({
    required TextEditingController controller,
    required String placeholder,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.inter(
          color: AppTheme.systemGray2,
          fontSize: 17,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(prefixIcon, size: 20, color: AppTheme.systemGray),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.macOS;

    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: const Text("Update Photo"),
          message: const Text("Select a photo source to update your sanctuary portrait."),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
              child: const Text("Choose from Library"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
              child: const Text("Take Photo"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.systemGray3.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Update Photo",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a photo source to update your sanctuary portrait.",
                style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from Library"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }
}
