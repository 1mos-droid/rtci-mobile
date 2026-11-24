import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_mobile/utils/image_upload.dart';

void main() {
  test('detects allowed image types from file signatures', () {
    expect(
      imageContentType(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])),
      'image/jpeg',
    );
    expect(
      imageContentType(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
      ),
      'image/png',
    );
    expect(
      imageContentType(
        Uint8List.fromList('RIFF\x00\x00\x00\x00WEBP'.codeUnits),
      ),
      'image/webp',
    );
  });

  test('rejects files whose contents are not an allowed image', () {
    expect(
      imageContentType(Uint8List.fromList('<svg onload=alert(1)>'.codeUnits)),
      isNull,
    );
    expect(imageContentType(Uint8List.fromList('GIF89a'.codeUnits)), isNull);
    expect(imageContentType(Uint8List(0)), isNull);
  });

  test('renamed non-image files cannot be uploaded', () async {
    final dir = await Directory.systemTemp.createTemp('upload_test');
    addTearDown(() => dir.delete(recursive: true));
    final fake = File('${dir.path}/photo.jpg')
      ..writeAsStringSync('<html>not an image</html>');
    expect(validatedImageMetadata(fake), throwsA(isA<ImageUploadException>()));

    final real = File('${dir.path}/real.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect((await validatedImageMetadata(real)).contentType, 'image/jpeg');
  });
}
