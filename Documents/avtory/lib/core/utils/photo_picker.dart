import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Picks an image (camera or gallery), compresses it hard, and returns a
/// base64 data-URL string small enough to store inline on the request.
/// Returns null if the user cancels.
Future<String?> pickPhotoDataUrl(ImageSource source) async {
  final picker = ImagePicker();
  final x = await picker.pickImage(source: source, imageQuality: 35, maxWidth: 1000);
  if (x == null) return null;
  final bytes = await x.readAsBytes();
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}

/// Decodes a base64 data-URL back into bytes for [Image.memory]. Null if invalid.
Uint8List? decodeDataUrl(String? s) {
  if (s == null || !s.contains('base64,')) return null;
  try {
    return base64Decode(s.split('base64,').last);
  } catch (_) {
    return null;
  }
}
