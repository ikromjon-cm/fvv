import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/router/app_router.dart';
import 'api_service.dart';
import 'local_notifs.dart';

/// Background isolate handler — must be a top-level function annotated with
/// vm:entry-point. When a push with a `notification` payload arrives while the
/// app is terminated/background, Android shows it in the tray automatically;
/// this just ensures Firebase is ready in the background isolate.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

/// Wires Firebase Cloud Messaging:
///  • registers the device token with the backend (so server-side push works),
///  • shows a local notification for foreground messages,
///  • deep-links to the relevant screen when a notification is tapped.
/// Fully optional — if Firebase isn't configured the app still works via the
/// 12s in-app polling in [NotificationService].
class FcmService {
  FcmService._();

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      // Register the token now (if logged in) and whenever it rotates.
      final token = await messaging.getToken();
      if (token != null) _saveToken(token);
      messaging.onTokenRefresh.listen(_saveToken);

      // Foreground push → show a heads-up local notification.
      FirebaseMessaging.onMessage.listen((m) {
        final n = m.notification;
        if (n != null) {
          LocalNotifs.show(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            n.title ?? 'AVTORY',
            n.body ?? '',
          );
        }
      });

      // Tapped while backgrounded.
      FirebaseMessaging.onMessageOpenedApp.listen(_route);
      // Tapped while terminated (cold start).
      final initial = await messaging.getInitialMessage();
      if (initial != null) _route(initial);
    } catch (_) {
      // Firebase unavailable (web/dev/misconfig) — ignore; polling still works.
    }
  }

  /// Re-register after login (the first token may have been captured while the
  /// user was still unauthenticated).
  static Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) _saveToken(token);
    } catch (_) {}
  }

  /// Unregister the FCM token on the backend (called on logout).
  static Future<void> unregisterToken() async {
    try {
      await ApiService.deleteFcmToken();
    } catch (_) {}
  }

  static void _saveToken(String token) {
    // Needs auth; harmlessly no-ops (catch) if not logged in yet.
    ApiService.saveFcmToken(token).catchError((_) {});
  }

  static void _route(RemoteMessage m) {
    final reqId = m.data['request_id'];
    if (reqId != null) {
      try {
        appRouter.push('/request-status/$reqId');
      } catch (_) {}
    }
  }
}
