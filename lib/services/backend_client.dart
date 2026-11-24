import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class BackendException implements Exception {
  final String code;
  final String message;
  const BackendException(this.code, this.message);
  @override
  String toString() => message;
}

/// Only public endpoint locations live in the app; provider credentials stay on the server.
class BackendClient {
  final http.Client? client;
  final Future<String?> Function()? tokenProvider;
  final Uri? baseUri;
  final Future<String?> Function()? appCheckTokenProvider;
  const BackendClient({
    this.client,
    this.tokenProvider,
    this.baseUri,
    this.appCheckTokenProvider,
  });

  Uri get _base =>
      baseUri ??
      Uri.parse(
        'https://us-central1-${Firebase.app().options.projectId}.cloudfunctions.net/',
      );

  Future<Map<String, dynamic>> post(
    String function,
    Map<String, dynamic> payload,
  ) async {
    final token =
        await (tokenProvider?.call() ??
            FirebaseAuth.instance.currentUser?.getIdToken() ??
            Future.value(null));
    if (token == null) {
      throw const BackendException('unauthenticated', 'Please sign in again.');
    }
    String? appCheck;
    try {
      appCheck =
          await (appCheckTokenProvider?.call() ??
              FirebaseAppCheck.instance.getToken());
    } catch (_) {
      throw const BackendException(
        'app_verification_failed',
        'This device could not be verified. Please try again.',
      );
    }
    if (appCheck == null) {
      throw const BackendException(
        'app_verification_failed',
        'This device could not be verified. Please try again.',
      );
    }
    final transport = client ?? http.Client();
    try {
      final response = await transport
          .post(
            _base.resolve(function),
            headers: {
              'Authorization': 'Bearer $token',
              'X-Firebase-AppCheck': appCheck,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode != 200) {
        final error = decoded['error'];
        if (error is Map &&
            error['code'] is String &&
            error['message'] is String) {
          throw BackendException(error['code'], error['message']);
        }
        throw const FormatException();
      }
      return decoded;
    } on BackendException {
      rethrow;
    } catch (_) {
      throw const BackendException(
        'unavailable',
        'This service is temporarily unavailable. Please try again.',
      );
    } finally {
      if (client == null) transport.close();
    }
  }
}
