import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLinks {
  static const supportEmail = 'ea6971684@gmail.com';
  static final privacy = Uri.parse(
    'https://rtci-22582-support.web.app/privacy/',
  );
  static final deletion = Uri.parse(
    'https://rtci-22582-support.web.app/delete-account/',
  );
  static Future<void> open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn’t open this page. Please try again.'),
        ),
      );
    }
  }
}
