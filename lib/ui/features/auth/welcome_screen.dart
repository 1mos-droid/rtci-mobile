import 'package:flutter/material.dart';
import 'package:rtc_mobile/ui/features/auth/login_screen.dart';
import 'package:rtc_mobile/ui/features/auth/signup_screen.dart';
import 'package:rtc_mobile/ui/features/applications/application_form_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final image = ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/church_sanctuary.jpg',
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x22000000), Color(0xCC182920)],
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROOTED IN FAITH',
                              style: TextStyle(
                                color: Color(0xFFF0D7A9),
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Growing together.\nLiving with purpose.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/church_logo.png',
                          width: 44,
                          height: 44,
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
                    Text(
                      'A place to belong.',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome to Redeemed Transformation Chapel International. Stay close to your faith and your church family, wherever life takes you.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => _open(context, const LoginScreen()),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign in'),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _open(context, const SignupScreen()),
                      child: const Text('Create an account'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () =>
                          _open(context, const ApplicationFormScreen()),
                      child: const Text('New here? Become a member'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Faith. Fellowship. Family.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(
                              child: SizedBox(height: 620, child: image),
                            ),
                            const SizedBox(width: 48),
                            Expanded(child: content),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 260, child: image),
                            const SizedBox(height: 28),
                            content,
                          ],
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
