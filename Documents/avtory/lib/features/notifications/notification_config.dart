import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

enum NotificationCategory {
  request('request', 'So\'rov', DesignTokens.primary, 'build_circle_outlined'),
  accepted('accepted', 'Qabul qilindi', DesignTokens.success, 'handyman_outlined'),
  onWay('on_way', 'Yo\'lda', DesignTokens.primary, 'near_me_rounded'),
  arrived('arrived', 'Yetib keldi', DesignTokens.primary, 'location_on_outlined'),
  completed('completed', 'Bajarildi', DesignTokens.success, 'check_circle_outline'),
  cancelled('cancelled', 'Bekor qilindi', DesignTokens.danger, 'cancel_outlined'),
  message('message', 'Xabar', DesignTokens.emerald, 'chat_bubble_outline'),
  review('review', 'Sharh', DesignTokens.warning, 'star_rounded'),
  favorite('favorite', 'Sevimli', DesignTokens.danger, 'favorite'),
  system('system', 'Tizim', DesignTokens.lightTextSecondary, 'notifications_outlined'),
  security('security', 'Xavfsizlik', DesignTokens.danger, 'lock_outline_rounded'),
  promo('promo', 'Aksiya', DesignTokens.premium, 'local_offer_rounded');

  const NotificationCategory(this.type, this.label, this.color, this.icon);

  final String type;
  final String label;
  final Color color;
  final String icon;

  bool get isHidden => this == NotificationCategory.promo;

  static NotificationCategory fromType(String type) {
    return NotificationCategory.values.firstWhere(
      (c) => c.type == type,
      orElse: () => NotificationCategory.system,
    );
  }
}
