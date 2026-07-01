import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/services/notification_service.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/firebase_options.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/application/theme/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
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
}

class RTCIMobileApp extends StatelessWidget {
  const RTCIMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MembersProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => CareProvider()),
        ChangeNotifierProvider(create: (_) => DailyInsightsProvider()),
        ChangeNotifierProvider(create: (_) => GroupsProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
        ChangeNotifierProvider(create: (_) => LeadershipProvider()),
        ChangeNotifierProvider(create: (_) => BibleStudiesProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'RTCI Connect',
            debugShowCheckedModeBanner: false,
            theme: ObsidianTheme.darkTheme,
            home: auth.isAuthenticated ? const MainTabScreen() : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
