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
