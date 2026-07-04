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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GoogleSignIn.instance.initialize();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: RTCIMobileApp(),
    ),
  );
}

class RTCIMobileApp extends ConsumerWidget {
  const RTCIMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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