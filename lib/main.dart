import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtc_mobile/core/config/supabase_config.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/providers/auth_provider.dart';
import 'package:rtc_mobile/providers/members_provider.dart';
import 'package:rtc_mobile/providers/application_provider.dart';
import 'package:rtc_mobile/providers/prayer_provider.dart';
import 'package:rtc_mobile/providers/financial_provider.dart';
import 'package:rtc_mobile/providers/events_provider.dart';
import 'package:rtc_mobile/providers/care_provider.dart';
import 'package:rtc_mobile/providers/insights_provider.dart';
import 'package:rtc_mobile/providers/groups_provider.dart';
import 'package:rtc_mobile/providers/children_provider.dart';
import 'package:rtc_mobile/providers/leadership_provider.dart';
import 'package:rtc_mobile/providers/bible_studies_provider.dart';
import 'package:rtc_mobile/providers/bible_provider.dart';
import 'package:rtc_mobile/providers/gallery_provider.dart';
import 'package:rtc_mobile/providers/attendance_provider.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/ui/features/dashboard/main_tab_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseConfig.initialize();

  runApp(const RTCIMobileApp());
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
