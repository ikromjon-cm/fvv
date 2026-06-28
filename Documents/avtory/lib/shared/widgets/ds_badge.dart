import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import 'app_icon.dart';

enum DsBadgeVariant {
  primary,
  success,
  danger,
  warning,
  info,
  neutral,
  premium,
}

class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.variant = DsBadgeVariant.primary,
    this.icon,
    this.fontSize = 11,
    this.padding,
    this.isOutlined = false,
  });

  final String label;
  final DsBadgeVariant variant;
  final String? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;

  Color _color(BuildContext context) {
    switch (variant) {
      case DsBadgeVariant.primary:
        return context.cPrimary;
      case DsBadgeVariant.success:
        return context.cSuccess;
      case DsBadgeVariant.danger:
        return context.cDanger;
      case DsBadgeVariant.warning:
        return context.cWarning;
      case DsBadgeVariant.info:
        return context.cInfo;
      case DsBadgeVariant.neutral:
        return context.cTextTertiary;
      case DsBadgeVariant.premium:
        return context.cPremium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
              horizontal: context.spSM, vertical: context.spXXS),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.radiusSM),
        border: isOutlined ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: fontSize + 2, color: color),
            SizedBox(width: context.spXXS),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isOutlined ? color : color,
              fontFamily: 'Inter',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class DsCountBadge extends StatelessWidget {
  const DsCountBadge({
    super.key,
    required this.count,
    this.size = 20,
    this.color,
    this.textColor,
  });

  final int count;
  final double size;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.symmetric(horizontal: size * 0.3),
      decoration: BoxDecoration(
        color: color ?? context.cDanger,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.white,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class DsStatusDot extends StatelessWidget {
  const DsStatusDot({
    super.key,
    this.isActive = true,
    this.activeColor,
    this.size = 8,
  });

  final bool isActive;
  final Color? activeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor ?? context.cOnline)
            : context.cOffline,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (activeColor ?? context.cOnline)
                      .withValues(alpha: 0.4),
                  blurRadius: size,
                ),
              ]
            : null,
      ),
    );
  }
}
