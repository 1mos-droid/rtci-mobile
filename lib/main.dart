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
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RTCIMobileApp(),
    ),
  );
}

class RTCIMobileApp extends ConsumerStatefulWidget {
  const RTCIMobileApp({super.key});

  @override
  ConsumerState<RTCIMobileApp> createState() => _RTCIMobileAppState();
}

class _RTCIMobileAppState extends ConsumerState<RTCIMobileApp> {
  bool _initialized = false;
  String _loadingMessage = "Preparing Sanctuary...";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _loadingMessage = "Connecting to Vault...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() => _loadingMessage = "Authenticating Gatekeeper...");
      await GoogleSignIn.instance.initialize();
      setState(() => _loadingMessage = "Initializing Echoes...");
      await NotificationService().initialize();
      
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() {
        _initialized = true;
      });
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
        home: StartupLoaderScreen(message: _loadingMessage),
      );
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'RTCI Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.when(
        data: (user) => user != null ? const MainTabScreen() : const WelcomeScreen(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const WelcomeScreen(),
      ),
    );
  }
}