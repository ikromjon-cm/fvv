import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'local_notifs.dart';

enum NotifType { request, message, system, promo }

class AppNotification {

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.time,
  });
  final String id;
  final String title;
  final String body;
  final NotifType type;
  bool isRead;
  final DateTime time;

  String get icon => switch (type) {
        NotifType.request => 'check_circle_outline',
        NotifType.message => 'chat_bubble_outline',
        NotifType.promo => 'local_offer_outlined',
        _ => 'notifications_outlined',
      };

  Color get color => switch (type) {
        NotifType.request => const Color(0xFF10B981),
        NotifType.message => const Color(0xFF4F46E5),
        NotifType.promo => const Color(0xFFF59E0B),
        _ => const Color(0xFF6B7280),
      };
}

class NotificationService {
  factory NotificationService() => _i;
  NotificationService._();
  static final NotificationService _i = NotificationService._();

  // Banner: fires only for genuinely new notifications.
  final _newCtrl = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get onNew => _newCtrl.stream;

  // Badge: fires the unread count on every refresh.
  final _countCtrl = StreamController<int>.broadcast();
  Stream<int> get onCount => _countCtrl.stream;

  final List<AppNotification> _all = [];
  final Set<String> _seen = {};
  bool _firstLoad = true;

  List<AppNotification> get all => List.unmodifiable(_all);
  int get unreadCount => _all.where((n) => !n.isRead).length;

  Timer? _timer;
  int _consecutiveAuthFailures = 0;
  static const _maxAuthFailures = 3;

  static NotifType _typeFrom(String? s) => switch (s) {
        'request' || 'accepted' || 'on_way' || 'arrived' || 'completed' || 'cancelled' =>
          NotifType.request,
        'message' => NotifType.message,
        'promo' => NotifType.promo,
        _ => NotifType.system,
      };

  AppNotification _fromBackend(Map<String, dynamic> m) => AppNotification(
        id: '${m['id']}',
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        type: _typeFrom(m['notif_type'] as String?),
        isRead: m['is_read'] as bool? ?? false,
        time: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  /// Starts polling the backend for the signed-in user's notifications.
  /// Real notifications (new request, chat message, …) drive both the banner
  /// and the badge, and are the same items shown in the notifications screen.
  void init() {
    LocalNotifs.init();
    _consecutiveAuthFailures = 0;
    refresh();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => refresh());
  }

  Future<void> refresh() async {
    // Back off while signed out / session invalid, instead of hammering the
    // server every 12s forever — but keep retrying occasionally so polling
    // self-heals as soon as a valid session exists again (e.g. after login).
    if (_consecutiveAuthFailures >= _maxAuthFailures &&
        _consecutiveAuthFailures % _maxAuthFailures != 0) {
      _consecutiveAuthFailures++;
      return;
    }
    try {
      final raw = await ApiService.getNotifications();
      _consecutiveAuthFailures = 0;
      final list = raw.map((e) => _fromBackend(e as Map<String, dynamic>)).toList();

      final fresh = list.where((n) => !_seen.contains(n.id)).toList();
      _all
        ..clear()
        ..addAll(list);
      for (final n in list) {
        _seen.add(n.id);
      }

      // Banner + system notification only for new unread items that arrive
      // after the first load (so we don't replay history on sign-in).
      if (!_firstLoad) {
        for (final n in fresh.where((n) => !n.isRead).take(2).toList().reversed) {
          _newCtrl.add(n);
          LocalNotifs.show(int.tryParse(n.id) ?? n.hashCode, n.title, n.body);
        }
      }
      _firstLoad = false;
      _countCtrl.add(unreadCount);
    } catch (e) {
      // not signed in / offline — ignore, badge stays as-is.
      if (e is ApiException && e.statusCode == 401) {
        _consecutiveAuthFailures++;
      }
    }
  }

  Future<void> markRead(String id) async {
    final idx = _all.indexWhere((n) => n.id == id);
    if (idx >= 0) _all[idx].isRead = true;
    _countCtrl.add(unreadCount);
    final numId = int.tryParse(id);
    if (numId != null) {
      try {
        await ApiService.markRead(numId);
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    for (final n in _all) {
      n.isRead = true;
    }
    _countCtrl.add(unreadCount);
    try {
      await ApiService.markAllRead();
    } catch (_) {}
  }

  /// Call on logout to reset state so the next user starts clean.
  void reset() {
    _all.clear();
    _seen.clear();
    _firstLoad = true;
    _countCtrl.add(0);
  }

  void dispose() {
    _timer?.cancel();
    _newCtrl.close();
    _countCtrl.close();
  }
}
