import 'package:flutter/material.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';

class StartupLoaderScreen extends StatelessWidget {
  final String message;
  const StartupLoaderScreen({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RTCI CONNECT',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              CustomLogoLoader(size: 88, message: message),
              const SizedBox(height: 32),
              Text(
                'Faith. Fellowship. Family.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
