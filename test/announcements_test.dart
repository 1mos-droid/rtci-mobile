import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/providers/riverpod_providers.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/messaging/messaging_screen.dart';

class TestBroadcasts extends Mock implements BroadcastProvider {}

class LeaderAuth extends AuthNotifier {
  @override
  AppUser? build() => const AppUser(
    id: 'leader',
    name: 'Leader',
    email: 'leader@example.com',
    role: UserRole.admin,
  );
}

class MemberAuth extends AuthNotifier {
  @override
  AppUser? build() => const AppUser(
    id: 'member',
    name: 'Member',
    email: 'member@example.com',
    role: UserRole.member,
  );
}

void main() {
  late TestBroadcasts broadcasts;
  setUp(() {
    broadcasts = TestBroadcasts();
    when(() => broadcasts.isLoading).thenReturn(false);
    when(() => broadcasts.error).thenReturn(null);
    when(() => broadcasts.messages).thenReturn([]);
    when(() => broadcasts.fetchBroadcasts()).thenAnswer((_) async {});
  });

  Future<void> open(WidgetTester tester, {bool member = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            member ? MemberAuth.new : LeaderAuth.new,
          ),
          broadcastProvider.overrideWith((ref) => broadcasts),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MessagingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Members can read announcements but cannot compose', (
    tester,
  ) async {
    await open(tester, member: true);
    expect(find.text('Write announcement'), findsNothing);
    expect(find.text('A quiet moment'), findsOneWidget);
  });

  for (final success in [true, false]) {
    testWidgets(
      'Publishing stores the entered announcement, success=$success',
      (tester) async {
        when(
          () => broadcasts.sendBroadcast(
            target: any(named: 'target'),
            channel: any(named: 'channel'),
            subject: any(named: 'subject'),
            body: any(named: 'body'),
            category: any(named: 'category'),
          ),
        ).thenAnswer((_) async => success);
        await open(tester);
        await tester.tap(find.text('Write announcement'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Sunday gathering',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Join us at 9 AM.',
        );
        await tester.ensureVisible(find.text('Publish announcement'));
        await tester.tap(find.text('Publish announcement'));
        await tester.pumpAndSettle();
        verify(
          () => broadcasts.sendBroadcast(
            target: 'All Members',
            channel: 'app',
            subject: 'Sunday gathering',
            body: 'Join us at 9 AM.',
            category: 'Church update',
          ),
        ).called(1);
        if (success) {
          expect(
            find.text('Announcement published to the church feed.'),
            findsOneWidget,
          );
          expect(find.text('Share a church update'), findsNothing);
        } else {
          expect(
            find.textContaining('Your draft is still here'),
            findsOneWidget,
          );
          expect(find.text('Sunday gathering'), findsOneWidget);
          expect(find.text('Join us at 9 AM.'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
