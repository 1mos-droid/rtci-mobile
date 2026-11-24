import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

Future<void> initializeAppCheck() async {
  const webSiteKey = String.fromEnvironment('APP_CHECK_SITE_KEY');
  if (kIsWeb && !kDebugMode && webSiteKey.isEmpty) {
    throw StateError('Release web builds require APP_CHECK_SITE_KEY.');
  }
  if (!kIsWeb &&
      !kDebugMode &&
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform)) {
    throw UnsupportedError(
      'Production App Check is configured for Android and Apple platforms.',
    );
  }
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider(),
    providerWeb: kIsWeb
        ? (kDebugMode ? WebDebugProvider() : ReCaptchaV3Provider(webSiteKey))
        : null,
  );
}
