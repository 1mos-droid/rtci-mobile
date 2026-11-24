import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rtc_mobile/services/backend_client.dart';
import 'package:rtc_mobile/services/giving_service.dart';
import 'package:rtc_mobile/providers/bible_provider.dart';

BackendClient backend(Future<http.Response> Function(http.Request) respond) =>
    BackendClient(
      client: MockClient(respond),
      tokenProvider: () async => 'firebase-id-token',
      appCheckTokenProvider: () async => 'app-check-token',
      baseUri: Uri.parse('https://example.com/'),
    );
void main() {
  test(
    'Backend attaches authentication and never sends provider credentials',
    () async {
      final client = backend((request) async {
        expect(request.headers['authorization'], 'Bearer firebase-id-token');
        expect(request.headers['x-firebase-appcheck'], 'app-check-token');
        expect(request.url.path, '/initializeGiving');
        expect(jsonDecode(request.body), {
          'amount': 12,
          'fund': 'Tithe',
          'idempotencyKey': 'request_key_123456',
        });
        return http.Response(
          jsonEncode({
            'reference': 'rtci-${'a' * 48}',
            'authorizationUrl': 'https://checkout.paystack.com/session',
          }),
          200,
        );
      });
      final checkout = await GivingService(
        backend: client,
      ).initialize(12, 'Tithe', 'request_key_123456');
      expect(checkout.reference, 'rtci-${'a' * 48}');
    },
  );
  test('Unauthenticated requests never reach the network', () async {
    final client = BackendClient(
      client: MockClient((_) async => fail('Must not send')),
      tokenProvider: () async => null,
      baseUri: Uri.parse('https://example.com/'),
    );
    await expectLater(
      client.post('verifyGiving', {}),
      throwsA(isA<BackendException>()),
    );
  });
  test(
    'Checkout rejects redirects and lookalike or non-HTTPS payment hosts',
    () async {
      for (final url in [
        'http://checkout.paystack.com/x',
        'https://checkout.paystack.com.evil.com/x',
        'https://attacker@checkout.paystack.com/x',
        'https://checkout.paystack.com:8443/x',
        'javascript:alert(1)',
      ]) {
        final service = GivingService(
          backend: backend(
            (_) async => http.Response(
              jsonEncode({
                'reference': 'rtci-${'a' * 48}',
                'authorizationUrl': url,
              }),
              200,
            ),
          ),
        );
        await expectLater(
          service.initialize(12, 'Tithe', 'request_key_123456'),
          throwsA(isA<BackendException>()),
        );
      }
    },
  );
  test(
    'Verification cannot accept a different reference or an unknown status',
    () async {
      for (final response in [
        {'reference': 'other', 'status': 'completed'},
        {'reference': 'reference', 'status': 'success'},
      ]) {
        final service = GivingService(
          backend: backend(
            (_) async => http.Response(jsonEncode(response), 200),
          ),
        );
        await expectLater(
          service.verify('reference'),
          throwsA(isA<BackendException>()),
        );
      }
    },
  );
  test('Malformed backend errors expose a useful generic message', () async {
    final client = backend(
      (_) async => http.Response('<html>internal secret</html>', 500),
    );
    await expectLater(
      client.post('bibleContent', {}),
      throwsA(
        isA<BackendException>().having(
          (error) => error.message,
          'safe message',
          isNot(contains('internal secret')),
        ),
      ),
    );
  });
  test('Bible reader preserves text nested inside verse spans', () async {
    final provider = BibleProvider(
      backend: backend((request) async {
        expect(jsonDecode(request.body)['operation'], 'chapter');
        return http.Response(
          jsonEncode({
            'data': {
              'content': [
                {
                  'tag': 'p',
                  'items': [
                    {
                      'tag': 'span',
                      'attrs': {'verseId': 'JHN.1.1'},
                      'items': [
                        {'type': 'text', 'text': 'In the beginning '},
                        {'type': 'text', 'text': 'was the Word.'},
                      ],
                    },
                  ],
                },
              ],
            },
          }),
          200,
        );
      }),
    );
    addTearDown(provider.dispose);
    await provider.fetchChapterContent('KJV', 'JHN.1');
    expect(provider.verses.single.content, 'In the beginning was the Word.');
    expect(provider.error, isNull);
  });
  test(
    'Bible service failure is exposed as an error instead of an empty chapter',
    () async {
      final provider = BibleProvider(
        backend: backend(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 'bible_unconfigured',
                'message': 'Bible reading is temporarily unavailable.',
              },
            }),
            503,
          ),
        ),
      );
      addTearDown(provider.dispose);
      await provider.fetchBooks('KJV');
      expect(provider.error, 'Bible reading is temporarily unavailable.');
      expect(provider.isLoading, isFalse);
    },
  );
  test('Missing device attestation cannot reach the backend', () async {
    final client = BackendClient(
      client: MockClient((_) async => fail('Must not send')),
      tokenProvider: () async => 'firebase-id-token',
      appCheckTokenProvider: () async => null,
      baseUri: Uri.parse('https://example.com/'),
    );
    await expectLater(
      client.post('verifyGiving', {}),
      throwsA(
        isA<BackendException>().having(
          (error) => error.code,
          'code',
          'app_verification_failed',
        ),
      ),
    );
  });
}
