import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../animations/motion.dart';
import '../../animations/animation_tokens.dart';
import '../../widgets/app_icon.dart';

// ─── Base Card ───

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.color,
    this.gradient,
    this.shadows,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.hasBorder = false,
    this.borderColor,
    this.width,
    this.height,
    this.isSelected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasBorder;
  final Color? borderColor;
  final double? width;
  final double? height;
  final bool isSelected;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isTappable => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: MotionTokens.fast,
      curve: MotionTokens.decelerate,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding ?? EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        color: widget.gradient != null
            ? null
            : (widget.color ?? context.cCard),
        gradient: widget.gradient,
        borderRadius:
            BorderRadius.circular(widget.radius ?? context.radiusLG),
        border: widget.isSelected
            ? Border.all(
                color: context.cPrimary,
                width: 1.5,
              )
            : widget.hasBorder
                ? Border.all(
                    color: widget.borderColor ??
                        context.cBorder.withValues(alpha: 0.5))
                : null,
        boxShadow: widget.shadows ??
            (widget.isSelected ? context.shadowMD : context.shadowSM),
      ),
      child: widget.child,
    );

    if (!_isTappable) return card;

    return Semantics(
      button: true,
      label: 'Karta',
      child: _pressCtrl.wrapGesture(
        child: card,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }
}

// ─── Glass Card ───

class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.blur = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final double blur;

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

// ─── Info Card ───

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.appIcon,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? appIcon;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(context.spMD),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: context.cTextTertiary),
            SizedBox(width: context.spSM),
          ] else if (appIcon != null) ...[
            AppIcon(appIcon!, size: 20, color: context.cTextTertiary),
            SizedBox(width: context.spSM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.cTextTertiary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? context.cTextPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Stat Card ───

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.appIcon,
    this.valueColor,
    this.iconColor,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData? icon;
  final String? appIcon;
  final Color? valueColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(context.spMD),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 22, color: iconColor ?? context.cPrimary),
          if (appIcon != null)
            AppIcon(appIcon!,
                size: 22, color: iconColor ?? context.cPrimary),
          SizedBox(height: context.spSM),
          FadeInOnVisible(
            offsetY: 0,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.cTextPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.cTextTertiary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

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
                    fontSize: 18,
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
              label: actionLabel ?? '',
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

// ─── Stats Row ───

class AppStatsRow extends StatelessWidget {
  const AppStatsRow({super.key, required this.items});
  final List<AppStatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final isLast = items.last == item;
        return Expanded(
          child: isLast
              ? _AppStatItemWidget(item: item)
              : Row(
                  children: [
                    Expanded(child: _AppStatItemWidget(item: item)),
                    Container(
                      width: 1,
                      height: 32,
                      color: context.cDivider,
                    ),
                  ],
                ),
        );
      }).toList(),
    );
  }
}

class AppStatItem {
  const AppStatItem({
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
    this.appIcon,
  });

  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;
  final String? appIcon;
}

class _AppStatItemWidget extends StatelessWidget {
  const _AppStatItemWidget({required this.item});
  final AppStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.icon != null)
              Icon(item.icon, size: 14,
                  color: item.valueColor ?? context.cTextPrimary),
            if (item.appIcon != null)
              AppIcon(item.appIcon!, size: 14,
                  color: item.valueColor ?? context.cTextPrimary),
            if (item.icon != null || item.appIcon != null)
              const SizedBox(width: 4),
            Text(
              item.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: item.valueColor ?? context.cTextPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            color: context.cTextTertiary,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
