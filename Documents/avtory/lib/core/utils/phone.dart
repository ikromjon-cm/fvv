import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer with [phone] pre-filled (tel: scheme).
/// No-op for empty numbers; silently ignores if no dialer is available.
Future<void> dialPhone(String phone) async {
  final n = phone.trim();
  if (n.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: n);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

/// Opens [url] in the external browser.
Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Opens the mail composer addressed to [email].
Future<void> openEmail(String email) async {
  final uri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

/// Opens turn-by-turn navigation to [lat],[lng] in the device's maps app.
/// Tries the native geo: scheme first (Google Maps / Yandex picker on Android),
/// then falls back to a universal Google Maps directions URL.
Future<void> navigateTo(double lat, double lng) async {
  final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
  if (await canLaunchUrl(geo)) {
    await launchUrl(geo, mode: LaunchMode.externalApplication);
    return;
  }
  final maps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
  if (await canLaunchUrl(maps)) {
    await launchUrl(maps, mode: LaunchMode.externalApplication);
  }
}
