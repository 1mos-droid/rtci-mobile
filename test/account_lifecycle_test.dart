// Firestore exposes sealed reference types; mocks exercise the service boundary.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rtc_mobile/providers/account_notifier.dart';
import 'package:rtc_mobile/services/notification_service.dart';

class TestMessaging extends Mock implements FirebaseMessaging {}

class TestAuth extends Mock implements FirebaseAuth {}

class TestUser extends Mock implements User {}

class TestFirestore extends Mock implements FirebaseFirestore {}

class TestCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class TestDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class TestLocalNotifications extends Mock
    implements FlutterLocalNotificationsPlugin {}

class TestSettings extends Mock implements NotificationSettings {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Replacing account state cancels listeners and ignores late notifications',
    () async {
      final stream = StreamController<int>();
      final state = AccountNotifier();
      var delivered = 0;
      state.trackSubscription(
        stream.stream.listen((_) => state.notifyListeners()),
      );
      state.addListener(() => delivered++);
      stream.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(delivered, 1);
      state.dispose();
      expect(stream.hasListener, isFalse);
      stream.add(2);
      state
          .notifyListeners(); // A fetch may finish after a tab/account is replaced.
      await Future<void>.delayed(Duration.zero);
      expect(delivered, 1);
      await stream.close();
    },
  );

  late TestMessaging messaging;
  late TestAuth auth;
  late TestUser user;
  late TestDocument profile;
  late TestLocalNotifications local;
  late TestSettings settings;
  late NotificationService service;
  setUp(() {
    messaging = TestMessaging();
    auth = TestAuth();
    user = TestUser();
    final firestore = TestFirestore();
    final profiles = TestCollection();
    profile = TestDocument();
    local = TestLocalNotifications();
    settings = TestSettings();
    when(() => user.uid).thenReturn('alice');
    when(() => auth.currentUser).thenReturn(user);
    when(() => firestore.collection('profiles')).thenReturn(profiles);
    when(() => profiles.doc('alice')).thenReturn(profile);
    when(() => profile.update(any())).thenAnswer((_) async {});
    when(
      () => settings.authorizationStatus,
    ).thenReturn(AuthorizationStatus.authorized);
    when(
      () => messaging.getNotificationSettings(),
    ).thenAnswer((_) async => settings);
    when(() => messaging.getToken()).thenAnswer((_) async => 'device-token');
    when(() => messaging.deleteToken()).thenAnswer((_) async {});
    when(() => local.cancelAll()).thenAnswer((_) async {});
    service = NotificationService.forTesting(
      messaging: messaging,
      auth: auth,
      firestore: firestore,
      local: local,
    );
  });
  test(
    'A registration retry cannot reattach the old account during sign-out',
    () async {
      await service.clearToken();
      await service.updateToken();
      verifyNever(() => messaging.getToken());
      verify(() => profile.update(any())).called(1);
    },
  );
  test('Notification registration respects a denied permission', () async {
    when(
      () => settings.authorizationStatus,
    ).thenReturn(AuthorizationStatus.denied);
    await service.updateToken();
    verifyNever(() => messaging.getToken());
    verifyNever(() => profile.update(any()));
  });
  test(
    'A delayed token cannot be attached after the account changes',
    () async {
      final token = Completer<String?>();
      when(() => messaging.getToken()).thenAnswer((_) => token.future);
      final updating = service.updateToken();
      await Future<void>.delayed(Duration.zero);
      when(() => auth.currentUser).thenReturn(null);
      token.complete('old-device-token');
      await updating;
      verifyNever(() => profile.update(any()));
    },
  );
  test(
    'Sign-out invalidates the device token even if profile cleanup fails',
    () async {
      when(() => profile.update(any())).thenThrow(Exception('offline'));
      await service.clearToken();
      verify(() => messaging.deleteToken()).called(1);
      verify(() => local.cancelAll()).called(1);
    },
  );
  test(
    'An in-flight registration cannot undo sign-out token cleanup',
    () async {
      final token = Completer<String?>();
      when(() => messaging.getToken()).thenAnswer((_) => token.future);
      final updating = service.updateToken();
      await Future<void>.delayed(Duration.zero);
      await service.clearToken();
      token.complete('stale-token');
      await updating;
      verify(
        () => profile.update(any()),
      ).called(1); // Removal only; no late save.
    },
  );
}
