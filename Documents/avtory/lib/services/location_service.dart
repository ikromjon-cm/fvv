import 'package:geolocator/geolocator.dart';

/// Resolves the user's real GPS position with a graceful Tashkent fallback.
class LocationService {
  LocationService._();

  static const double fallbackLat = 41.2995;
  static const double fallbackLng = 69.2401;

  /// Stream of continuous position updates.
  static Stream<({double lat, double lng, bool real})> stream({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: null,
        distanceFilter: 10,
      ),
    ).map((p) => (lat: p.latitude, lng: p.longitude, real: true));
  }

  /// Requests permission (if needed) and returns the current position.
  /// `real` is false ONLY when we truly have nothing (permission denied AND no
  /// cached fix) — in that case the Tashkent centre is used.
  ///
  /// Strategy: reliability first, then accuracy. A pure high-accuracy fix often
  /// times out indoors/with a weak signal and would leave the user stranded on
  /// the Tashkent centre (looks like "wrong location"). So we try progressively
  /// faster accuracy tiers with short timeouts, and fall back to the last-known
  /// position before ever resorting to the city centre. The driver can always
  /// fine-tune the exact spot with the on-map picker.
  static Future<({double lat, double lng, bool real})> current() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        // No permission — a cached fix (if any) still beats the city centre.
        final last = await _lastKnown();
        return last ?? (lat: fallbackLat, lng: fallbackLng, real: false);
      }

      final serviceOn = await Geolocator.isLocationServiceEnabled();

      if (serviceOn) {
        // Try a fresh fix, dropping accuracy if a lock is slow. High usually
        // locks in 1–3s outdoors; medium/low get *something* fast indoors.
        for (final acc in const [
          LocationAccuracy.high,
          LocationAccuracy.medium,
          LocationAccuracy.low,
        ]) {
          try {
            final p = await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: acc,
                timeLimit: const Duration(seconds: 7),
              ),
            ).timeout(const Duration(seconds: 8));
            return (lat: p.latitude, lng: p.longitude, real: true);
          } catch (_) {
            // try the next (faster) accuracy tier
          }
        }
      }

      // No fresh fix — the last-known position is still far better than the
      // city centre for someone outside Tashkent.
      final last = await _lastKnown();
      if (last != null) return last;
    } catch (_) {
      // location services off / permission error — use fallback
    }
    return (lat: fallbackLat, lng: fallbackLng, real: false);
  }

  static Future<({double lat, double lng, bool real})?> _lastKnown() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return (lat: last.latitude, lng: last.longitude, real: true);
      }
    } catch (_) {}
    return null;
  }

  /// Opens the OS location/app settings so the user can enable GPS or grant
  /// permission after a previous denial.
  static Future<void> openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }
}
