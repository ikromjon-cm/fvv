import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';

class StatusConfig {
  const StatusConfig({
    required this.icon,
    required this.color,
    required this.label,
    Color? bgColor,
  }) : bgColor = bgColor ?? Colors.transparent;

  final String icon;
  final Color color;
  final String label;
  final Color bgColor;
}

class HistoryStatusBadge extends StatelessWidget {
  const HistoryStatusBadge({
    super.key,
    required this.status,
    this.size = 20,
    this.showLabel = true,
    this.animated = true,
  });

  final String status;
  final double size;
  final bool showLabel;
  final bool animated;

  static const Map<String, StatusConfig> statusConfigs = {
    'pending': StatusConfig(
      icon: 'pending_actions_rounded',
      color: DesignTokens.warning,
      label: 'Kutilmoqda',
    ),
    'searching': StatusConfig(
      icon: 'sensors_rounded',
      color: DesignTokens.primary,
      label: 'Qidirilmoqda',
    ),
    'accepted': StatusConfig(
      icon: 'handyman_outlined',
      color: DesignTokens.success,
      label: 'Qabul qilindi',
    ),
    'on_way': StatusConfig(
      icon: 'near_me_rounded',
      color: DesignTokens.primary,
      label: "Yo'lda",
    ),
    'driving': StatusConfig(
      icon: 'near_me_rounded',
      color: DesignTokens.primary,
      label: "Yo'lda",
    ),
    'arrived': StatusConfig(
      icon: 'place_rounded',
      color: DesignTokens.warning,
      label: 'Yetib keldi',
    ),
    'working': StatusConfig(
      icon: 'build_rounded',
      color: DesignTokens.primaryLight,
      label: 'Ishlamoqda',
    ),
    'completed': StatusConfig(
      icon: 'check_circle_rounded',
      color: DesignTokens.success,
      label: 'Yakunlandi',
    ),
    'cancelled': StatusConfig(
      icon: 'cancel_outlined',
      color: DesignTokens.danger,
      label: 'Bekor qilindi',
    ),
    'expired': StatusConfig(
      icon: 'timer_outlined',
      color: DesignTokens.danger,
      label: "Muddati o'tdi",
    ),
  };

  StatusConfig get _config =>
      statusConfigs[status] ??
      const StatusConfig(
        icon: 'help_outline',
        color: DesignTokens.lightTextTertiary,
        label: 'Noma\'lum',
      );

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final badgeColor = cfg.color;
    final isActive = status == 'pending' ||
        status == 'searching' ||
        status == 'accepted' ||
        status == 'on_way' ||
        status == 'driving' ||
        status == 'arrived' ||
        status == 'working';

    Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 10 : 6,
        vertical: showLabel ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isActive ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: badgeColor.withValues(alpha: isActive ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: AppIcon(cfg.icon, size: size, color: badgeColor),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              cfg.label,
              style: context.labelSmall(color: badgeColor).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );

    if (!animated) return badge;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: badge,
    );
  }
}
