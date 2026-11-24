import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Matches the 10 MB limit enforced by storage.rules.
const maxImageUploadBytes = 10 * 1024 * 1024;

class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException(this.message);
  @override
  String toString() => message;
}

/// Detects the image type from the file's signature, never its extension.
/// Returns null for anything other than JPEG, PNG or WebP.
String? imageContentType(Uint8List header) {
  bool startsWith(List<int> signature, [int offset = 0]) {
    if (header.length < offset + signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (header[offset + i] != signature[i]) return false;
    }
    return true;
  }

  if (startsWith([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (startsWith('RIFF'.codeUnits) && startsWith('WEBP'.codeUnits, 8)) {
    return 'image/webp';
  }
  return null;
}

/// Validates an image before upload and returns metadata for Storage.
/// Storage rules re-check type and size on the server.
Future<SettableMetadata> validatedImageMetadata(File file) async {
  final size = await file.length();
  if (size == 0 || size > maxImageUploadBytes) {
    throw const ImageUploadException('Choose a photo smaller than 10 MB.');
  }
  final handle = await file.open();
  final Uint8List header;
  try {
    header = await handle.read(12);
  } finally {
    await handle.close();
  }
  final contentType = imageContentType(header);
  if (contentType == null) {
    throw const ImageUploadException('Choose a JPEG, PNG or WebP photo.');
  }
  return SettableMetadata(contentType: contentType);
}
