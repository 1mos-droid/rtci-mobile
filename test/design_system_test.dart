import 'dart:io';
import 'dart:ui' as ui;
import 'package:rtc_mobile/ui/features/messaging/messaging_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/ui/features/dashboard/dashboard_screen.dart';
import 'package:rtc_mobile/ui/features/finance/giving_screen.dart';
import 'package:rtc_mobile/ui/features/events/events_screen.dart';
import 'package:rtc_mobile/ui/features/groups/groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/auth/login_screen.dart';
import 'package:rtc_mobile/ui/features/auth/signup_screen.dart';
import 'package:rtc_mobile/ui/features/settings/menu_screen.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/gradient_button.dart';
import 'package:rtc_mobile/widgets/skeleton_loader.dart';

class PreviewEvents extends Mock implements EventsProvider {}

class PreviewGroups extends Mock implements GroupsProvider {}

class PreviewFinance extends Mock implements FinancialProvider {}

class PreviewBroadcast extends Mock implements BroadcastProvider {}

class PreviewSermons extends Mock implements SermonProvider {}

class PreviewInsights extends Mock implements DailyInsightsProvider {}

class PreviewCare extends Mock implements CareProvider {}

class DesignAuth extends AuthNotifier {
  @override
  AppUser? build() => const AppUser(
    id: 'preview',
    name: 'Grace Mensah',
    email: 'grace@example.com',
    role: UserRole.member,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets(
    'Skeleton stops when reduced motion is enabled or tab is hidden',
    (tester) async {
      for (final reduced in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: const Scaffold(body: SkeletonContainer(height: 30)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.hasRunningAnimations, !reduced);
      }
      await tester.pumpWidget(
        const MaterialApp(
          home: TickerMode(
            enabled: false,
            child: SkeletonContainer(height: 30),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets(
    'Legacy button supports keyboard activation and wraps large labels',
    (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SizedBox(
                width: 240,
                child: GradientButton(
                  text: 'Continue to your community',
                  onPressed: () => presses++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    for (final width in [320.0, 1200.0]) {
      for (final entry in <String, Widget>{
        'welcome': const WelcomeScreen(),
        'home': const DashboardScreen(),
        'giving': const GivingScreen(),
        'groups': const GroupsScreen(),
        'events': const EventsScreen(),
        'announcements': const MessagingScreen(),
        'login': const LoginScreen(),
        'signup': const SignupScreen(),
        'explore': const MenuScreen(),
        'loader': const Scaffold(
          body: Center(
            child: CustomLogoLoader(message: 'Connecting to your church…'),
          ),
        ),
      }.entries) {
        testWidgets(
          '${entry.key} fits width $width dark=$dark with enlarged text',
          (tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final boundary = GlobalKey();
            final events = PreviewEvents();
            when(() => events.isLoading).thenReturn(false);
            when(() => events.error).thenReturn(null);
            when(() => events.rsvp(any())).thenAnswer((_) async => true);
            when(() => events.events).thenReturn([
              ChurchEvent(
                id: 'event',
                name: 'Sunday worship & thanksgiving',
                date: DateTime(2027, 1, 3),
                time: '9:00 AM – 11:00 AM',
                location: 'Main church auditorium',
                category: 'Service',
                department: 'Church family',
                description:
                    'Come as you are. Worship, pray and grow together.',
              ),
            ]);
            final groups = PreviewGroups();
            when(() => groups.isLoading).thenReturn(false);
            when(() => groups.error).thenReturn(null);
            when(() => groups.groups).thenReturn([
              CellGroup(
                id: 'group',
                name: 'Young adults fellowship',
                leaderName: 'Grace Mensah',
                location: 'Main campus',
                memberCount: 24,
                type: 'home_cell',
                campus: 'Main',
                description:
                    'A welcoming place to build friendships and grow in faith.',
              ),
            ]);
            when(() => groups.joinedGroupIds).thenReturn({});
            final finance = PreviewFinance();
            when(() => finance.isLoading).thenReturn(false);
            final broadcasts = PreviewBroadcast();
            when(() => broadcasts.isLoading).thenReturn(false);
            when(() => broadcasts.error).thenReturn(null);
            when(() => broadcasts.messages).thenReturn([]);
            when(() => broadcasts.fetchBroadcasts()).thenAnswer((_) async {});
            final sermons = PreviewSermons();
            when(() => sermons.isLoading).thenReturn(false);
            when(() => sermons.sermons).thenReturn([]);
            when(() => sermons.fetchSermons()).thenAnswer((_) async {});
            final insights = PreviewInsights();
            when(() => insights.isLoading).thenReturn(false);
            when(() => insights.currentInsight).thenReturn(null);
            final care = PreviewCare();
            when(() => care.careQueue).thenReturn([]);
            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  authNotifierProvider.overrideWith(DesignAuth.new),
                  eventsProvider.overrideWith((ref) => events),
                  groupsProvider.overrideWith((ref) => groups),
                  financialProvider.overrideWith((ref) => finance),
                  broadcastProvider.overrideWith((ref) => broadcasts),
                  sermonProvider.overrideWith((ref) => sermons),
                  dailyInsightsProvider.overrideWith((ref) => insights),
                  careProvider.overrideWith((ref) => care),
                ],
                child: MaterialApp(
                  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                  home: MediaQuery(
                    data: MediaQueryData(
                      size: Size(width, 900),
                      disableAnimations: true,
                      textScaler: const TextScaler.linear(1.4),
                    ),
                    child: RepaintBoundary(key: boundary, child: entry.value),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            if (entry.key == 'login') {
              await tester.ensureVisible(find.text('Sign in'));
              await tester.tap(find.text('Sign in'));
              await tester.pumpAndSettle();
              expect(find.text('Enter a valid email address'), findsOneWidget);
              expect(find.text('Enter your password'), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
            if (entry.key == 'events') {
              await tester.ensureVisible(find.text('I’m attending'));
              await tester.tap(find.text('I’m attending'));
              await tester.pumpAndSettle();
              verify(() => events.rsvp('event')).called(1);
              expect(find.text('You’re on the list'), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
            if (entry.key == 'explore') {
              expect(find.text('Church calendar'), findsOneWidget);
              expect(find.text('Groups'), findsOneWidget);
              expect(find.text('Church administration'), findsNothing);
            }
            // Explicitly opt into review artifacts; regular tests never capture images.
            if (const bool.fromEnvironment('CAPTURE_UI')) {
              await tester.runAsync(() async {
                final render =
                    boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary;
                final picture = await render.toImage();
                final bytes = await picture.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                await Directory('/tmp/rtci-design').create(recursive: true);
                await File(
                  '/tmp/rtci-design/${entry.key}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
                ).writeAsBytes(bytes!.buffer.asUint8List());
                picture.dispose();
              });
            }
          },
        );
      }
    }
  }
}
