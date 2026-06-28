import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import 'app_icon.dart';

class DsSurface extends StatelessWidget {
  const DsSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.color,
    this.hasBorder = false,
    this.borderColor,
    this.shadows,
    this.gradient,
    this.onTap,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final Color? color;
  final bool hasBorder;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    final surface = Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        color: gradient != null ? null : (color ?? context.cCard),
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius ?? context.radiusLG),
        border: hasBorder
            ? Border.all(color: borderColor ?? context.cBorder.withValues(alpha: 0.5))
            : null,
        boxShadow: shadows ?? context.shadowSM,
      ),
      alignment: alignment,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: 'Sirt',
          child: surface,
        ),
      );
    }
    return surface;
  }
}

class DsGlassSurface extends StatelessWidget {
  const DsGlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.blur = 12,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final double blur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? context.radiusLG),
      child: BackdropFilter(
        filter: DesignTokens.glassFilter(blur),
        child: Container(
          margin: margin,
          padding: padding ?? EdgeInsets.all(context.spLG),
          decoration: BoxDecoration(
            color: context.glassFill,
            borderRadius: BorderRadius.circular(radius ?? context.radiusLG),
            border: Border.all(color: context.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.fontSize,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.spLG,
        right: context.spLG,
        bottom: context.spSM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize ?? 18,
                    fontWeight: FontWeight.w700,
                    color: context.cTextPrimary,
                    fontFamily: 'Inter',
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.cTextTertiary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            Semantics(
              link: true,
              label: actionLabel!,
              child: GestureDetector(
                onTap: onAction,
                child: Padding(
                  padding: EdgeInsets.only(left: context.spSM),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.cPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DsInfoRow extends StatelessWidget {
  const DsInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.appIcon,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? appIcon;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 16, color: context.cTextTertiary),
            SizedBox(width: context.spSM),
          ] else if (appIcon != null) ...[
            AppIcon(appIcon!, size: 16, color: context.cTextTertiary),
            SizedBox(width: context.spSM),
          ],
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.cTextSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: valueColor ?? context.cTextPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
