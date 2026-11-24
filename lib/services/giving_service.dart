import 'dart:convert';
import 'dart:math';
import 'backend_client.dart';

class GivingCheckout {
  final String reference;
  final Uri authorizationUrl;
  const GivingCheckout(this.reference, this.authorizationUrl);
}

class GivingService {
  final BackendClient backend;
  const GivingService({this.backend = const BackendClient()});

  static String newRequestKey() => base64UrlEncode(
    List<int>.generate(24, (_) => Random.secure().nextInt(256)),
  ).replaceAll('=', '');

  Future<GivingCheckout> initialize(
    double amount,
    String fund,
    String requestKey,
  ) async {
    final response = await backend.post('initializeGiving', {
      'amount': amount,
      'fund': fund,
      'idempotencyKey': requestKey,
    });
    final reference = response['reference'];
    final url = Uri.tryParse(response['authorizationUrl']?.toString() ?? '');
    if (reference is! String ||
        !RegExp(r'^rtci-[a-f0-9]{48}$').hasMatch(reference) ||
        url == null ||
        url.scheme != 'https' ||
        url.host != 'checkout.paystack.com' ||
        url.userInfo.isNotEmpty ||
        (url.hasPort && url.port != 443)) {
      throw const BackendException(
        'invalid_checkout',
        'Checkout could not be prepared. Please contact the church.',
      );
    }
    return GivingCheckout(reference, url);
  }

  Future<String> verify(String reference) async {
    final response = await backend.post('verifyGiving', {
      'reference': reference,
    });
    if (response['reference'] != reference ||
        !['pending', 'completed'].contains(response['status'])) {
      throw const BackendException(
        'invalid_verification',
        'Payment confirmation is unavailable. Please try again.',
      );
    }
    return response['status'] as String;
  }
}
