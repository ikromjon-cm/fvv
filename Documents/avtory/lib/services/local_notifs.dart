import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around flutter_local_notifications. Turns the backend
/// notifications (polled by [NotificationService]) into real system
/// notifications (heads-up / tray) while the app is running.
///
/// Note: delivery while the app is fully CLOSED needs FCM push (Firebase) —
/// this covers foreground/background only.
class LocalNotifs {
  LocalNotifs._();
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static const _channel = AndroidNotificationDetails(
    'avtory_default',
    'AVTORY',
    channelDescription: 'AVTORY bildirishnomalari',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
      // Android 13+ runtime permission
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Plugin unavailable (e.g. web) — silently ignore.
    }
  }

  static Future<void> show(int id, String title, String body) async {
    if (!_inited) return;
    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(android: _channel),
      );
    } catch (_) {}
  }
}
