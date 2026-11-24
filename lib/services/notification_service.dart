import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? local,
  }) : _messaging = messaging,
       _authOverride = auth,
       _firestoreOverride = firestore,
       _localNotifications = local ?? FlutterLocalNotificationsPlugin();

  @visibleForTesting
  factory NotificationService.forTesting({
    required FirebaseMessaging messaging,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FlutterLocalNotificationsPlugin local,
  }) => NotificationService._internal(
    messaging: messaging,
    auth: auth,
    firestore: firestore,
    local: local,
  ).._registrationUid = auth.currentUser?.uid;

  final FirebaseMessaging? _messaging;
  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseMessaging get _fcm => _messaging ?? FirebaseMessaging.instance;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  Future<void>? _initializing;
  StreamSubscription<String>? _tokenChanges;
  StreamSubscription<RemoteMessage>? _messages;
  StreamSubscription<User?>? _authChanges;
  String? _registrationUid;
  int _generation = 0;

  bool get _mobile =>
      !kIsWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);

  /// Sets up delivery without showing a permission dialog during startup.
  Future<void> initialize() => _initializing ??= _initialize();
  Future<void> _initialize() async {
    if (!_mobile) return;
    try {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'church_updates',
              'Church updates',
              description: 'Announcements from your church',
              importance: Importance.high,
            ),
          );
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _messages = FirebaseMessaging.onMessage.listen(
        (message) => unawaited(_showLocalNotification(message)),
      );
      _tokenChanges = _fcm.onTokenRefresh.listen(
        (token) => unawaited(_saveToken(token)),
        onError: (Object error) =>
            debugPrint('Notification token refresh unavailable.'),
      );
      _authChanges = _auth.authStateChanges().listen((user) {
        if (user?.uid != _auth.currentUser?.uid) return;
        _registrationUid = user?.uid;
        _generation++;
        if (user != null) unawaited(updateToken());
      });
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      await updateToken();
    } catch (error) {
      _initializing = null;
      await _messages?.cancel();
      await _tokenChanges?.cancel();
      await _authChanges?.cancel();
      debugPrint('Notification setup is unavailable.');
    }
  }

  Future<bool> requestPermission() async {
    if (!_mobile) return false;
    await initialize();
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted = [
      AuthorizationStatus.authorized,
      AuthorizationStatus.provisional,
    ].contains(settings.authorizationStatus);
    if (granted) await updateToken();
    return granted;
  }

  Future<void> updateToken() async {
    final generation = _generation;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null || uid != _registrationUid) return;
      final settings = await _fcm.getNotificationSettings();
      if (![
        AuthorizationStatus.authorized,
        AuthorizationStatus.provisional,
      ].contains(settings.authorizationStatus)) {
        return;
      }
      final token = await _fcm.getToken();
      if (generation == _generation &&
          _auth.currentUser?.uid == uid &&
          token != null) {
        await _saveToken(token, expectedUid: uid);
      }
    } catch (_) {
      debugPrint('Notification registration is unavailable.');
    }
  }

  Future<void> _saveToken(String token, {String? expectedUid}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null ||
        uid != _registrationUid ||
        (expectedUid != null && expectedUid != uid)) {
      return;
    }
    try {
      await _firestore.collection('profiles').doc(uid).update({
        'fcm_token': token,
      });
    } catch (_) {
      debugPrint('Notification registration is unavailable.');
    }
  }

  /// Run before Firebase sign-out while the profile is still owned by this user.
  Future<void> clearToken() async {
    _generation++;
    _registrationUid = null;
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore
            .collection('profiles')
            .doc(uid)
            .update({'fcm_token': FieldValue.delete()})
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        debugPrint('Notification profile cleanup is unavailable.');
      }
    }
    // Invalidates the device token even if the profile update failed offline.
    try {
      await _fcm.deleteToken().timeout(const Duration(seconds: 5));
    } catch (_) {}
    try {
      await _localNotifications.cancelAll();
    } catch (_) {}
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        _auth.currentUser == null) {
      return;
    }
    final notification = message.notification;
    if (notification == null) return;
    try {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'church_updates',
            'Church updates',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (_) {
      debugPrint('Notification display is unavailable.');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
