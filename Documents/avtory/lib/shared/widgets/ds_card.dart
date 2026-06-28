import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../animations/motion.dart';
import 'app_icon.dart';

class DsCard extends StatefulWidget {
  const DsCard({
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
    this.enableHaptic = true,
    this.scaleAmount = 0.98,
    this.width,
    this.height,
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
  final bool enableHaptic;
  final double scaleAmount;
  final double? width;
  final double? height;

  @override
  State<DsCard> createState() => _DsCardState();
}

class _DsCardState extends State<DsCard>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this, scale: widget.scaleAmount);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isTappable => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
        border: widget.hasBorder
            ? Border.all(
                color: widget.borderColor ??
                    context.cBorder.withValues(alpha: 0.5))
            : null,
        boxShadow: widget.shadows ??
            (widget.elevation != null
                ? DesignTokens.elevationShadow(
                    widget.elevation!,
                    context.isDark
                        ? Colors.black
                        : DesignTokens.lightTextPrimary)
                : context.shadowSM),
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

class DsGradientCard extends StatelessWidget {
  const DsGradientCard({
    super.key,
    this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.appIcon,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF1A56CC), Color(0xFF4F46E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.onTap,
    this.showArrow = true,
    this.height,
    this.child,
  });

  final String? title;
  final String? subtitle;
  final String? value;
  final String? unit;
  final IconData? icon;
  final String? appIcon;
  final Gradient gradient;
  final VoidCallback? onTap;
  final bool showArrow;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: EdgeInsets.all(context.spLG),
      gradient: gradient,
      shadows: [
        BoxShadow(
          color: gradient.colors.first.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      onTap: onTap,
      radius: context.radiusLG,
      height: height,
      child: child ??
          Row(
            children: [
              if (icon != null || appIcon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(context.radiusMD),
                  ),
                  child: icon != null
                      ? Icon(icon, color: Colors.white, size: 22)
                      : AppIcon(appIcon!, color: Colors.white, size: 22),
                ),
                SizedBox(width: context.spMD),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontFamily: 'Inter',
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (unit != null)
                      Text(
                        unit!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
                if (showArrow) ...[
                  SizedBox(width: context.spSM),
                  Icon(Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.7), size: 20),
                ],
              ],
            ],
          ),
    );
  }
}

class DsStatsRow extends StatelessWidget {
  const DsStatsRow({
    super.key,
    required this.items,
  });

  final List<DsStatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final isLast = items.last == item;
        return Expanded(
          child: isLast
              ? _DsStatItemWidget(item: item)
              : Row(
                  children: [
                    Expanded(child: _DsStatItemWidget(item: item)),
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

class DsStatItem {
  const DsStatItem({
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

class _DsStatItemWidget extends StatelessWidget {
  const _DsStatItemWidget({required this.item});
  final DsStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.icon != null)
              Icon(item.icon, size: 14, color: item.valueColor ?? context.cTextPrimary),
            if (item.appIcon != null)
              AppIcon(item.appIcon!, size: 14, color: item.valueColor ?? context.cTextPrimary),
            if (item.icon != null || item.appIcon != null) const SizedBox(width: 4),
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
