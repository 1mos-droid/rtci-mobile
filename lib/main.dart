import 'package:rtc_mobile/services/app_check_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/services/notification_service.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/ui/features/auth/startup_loader_screen.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/firebase_options.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/application/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPrint still writes to the device log in release builds; error
  // details can include account data, so release builds log nothing.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(const ProviderScope(child: RTCIMobileApp()));
}

class RTCIMobileApp extends ConsumerStatefulWidget {
  const RTCIMobileApp({super.key});

  @override
  ConsumerState<RTCIMobileApp> createState() => _RTCIMobileAppState();
}

class _RTCIMobileAppState extends ConsumerState<RTCIMobileApp> {
  bool _initialized = false;
  bool _initializationFailed = false;
  String _loadingMessage = 'Getting things ready…';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _initializationFailed = false;
      _loadingMessage = 'Connecting to your church…';
    });
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await initializeAppCheck();
      if (!mounted) return;
      setState(() => _loadingMessage = 'Getting things ready…');
      // Notifications are optional; their availability must not prevent sign-in.
      try {
        await NotificationService().initialize();
      } catch (error) {
        debugPrint('Notifications unavailable: $error');
      }
      if (mounted) setState(() => _initialized = true);
    } catch (error) {
      debugPrint('Initialization error: $error');
      if (mounted) setState(() => _initializationFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);

    if (!_initialized) {
      return MaterialApp(
        title: 'RTCI Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: _initializationFailed
            ? Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 40),
                          const SizedBox(height: 20),
                          const Text(
                            'We couldn’t connect',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Please check your connection and try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _initialize,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : StartupLoaderScreen(message: _loadingMessage),
      );
    }

    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'RTCI Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) => user != null
            ? MainTabScreen(key: ValueKey(user.id))
            : const WelcomeScreen(),
        loading: () =>
            const StartupLoaderScreen(message: 'Opening your community…'),
        error: (_, _) => const WelcomeScreen(),
      ),
    );
  }
}
