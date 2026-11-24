import 'package:flutter/material.dart';
import 'package:rtc_mobile/widgets/glass_card.dart';

/// The same comfortable reading width and hierarchy for every account flow.
class AuthPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  const AuthPage({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/church_logo.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'RTCI CONNECT',
                            style: theme.textTheme.labelLarge?.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(title, style: theme.textTheme.displayLarge),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlassCard(child: child),
                    const SizedBox(height: 24),
                    Text(
                      'Faith. Fellowship. Family.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
