import 'package:flutter/material.dart';

enum LiveRequestStatus {
  searching,
  accepted,
  onWay,
  arrived,
  working,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case LiveRequestStatus.searching:
        return 'Qidirilmoqda';
      case LiveRequestStatus.accepted:
        return 'Qabul qilindi';
      case LiveRequestStatus.onWay:
        return 'Yo\'lda';
      case LiveRequestStatus.arrived:
        return 'Yetib keldi';
      case LiveRequestStatus.working:
        return 'Ishlamoqda';
      case LiveRequestStatus.completed:
        return 'Yakunlandi';
      case LiveRequestStatus.cancelled:
        return 'Bekor qilindi';
    }
  }

  Color get color {
    switch (this) {
      case LiveRequestStatus.searching:
        return const Color(0xFFF59E0B);
      case LiveRequestStatus.accepted:
        return const Color(0xFF3B82F6);
      case LiveRequestStatus.onWay:
        return const Color(0xFF8B5CF6);
      case LiveRequestStatus.arrived:
        return const Color(0xFF1A56CC);
      case LiveRequestStatus.working:
        return const Color(0xFF0F172A);
      case LiveRequestStatus.completed:
        return const Color(0xFF10B981);
      case LiveRequestStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case LiveRequestStatus.searching:
        return Icons.search_rounded;
      case LiveRequestStatus.accepted:
        return Icons.check_circle_outline;
      case LiveRequestStatus.onWay:
        return Icons.near_me_rounded;
      case LiveRequestStatus.arrived:
        return Icons.location_on;
      case LiveRequestStatus.working:
        return Icons.build_rounded;
      case LiveRequestStatus.completed:
        return Icons.check_circle;
      case LiveRequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static LiveRequestStatus fromApi(String status) {
    switch (status) {
      case 'pending':
        return LiveRequestStatus.searching;
      case 'accepted':
        return LiveRequestStatus.accepted;
      case 'onWay':
        return LiveRequestStatus.onWay;
      case 'arrived':
        return LiveRequestStatus.arrived;
      case 'completed':
        return LiveRequestStatus.completed;
      case 'cancelled':
        return LiveRequestStatus.cancelled;
      default:
        return LiveRequestStatus.searching;
    }
  }

  int get stepIndex {
    switch (this) {
      case LiveRequestStatus.searching:
        return 0;
      case LiveRequestStatus.accepted:
        return 1;
      case LiveRequestStatus.onWay:
        return 2;
      case LiveRequestStatus.arrived:
        return 3;
      case LiveRequestStatus.working:
        return 4;
      case LiveRequestStatus.completed:
        return 5;
      case LiveRequestStatus.cancelled:
        return -1;
    }
  }
}
