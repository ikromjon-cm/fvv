import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../animations/motion.dart';
import 'app_icon.dart';

class DsChip extends StatefulWidget {
  const DsChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedIcon,
    this.selectedColor,
    this.showCount = false,
    this.count = 0,
    this.fontSize,
    this.padding,
    this.isLoading = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? icon;
  final String? selectedIcon;
  final Color? selectedColor;
  final bool showCount;
  final int count;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  @override
  State<DsChip> createState() => _DsChipState();
}

class _DsChipState extends State<DsChip>
    with SingleTickerProviderStateMixin {
  final PressScaleController _pressCtrl = PressScaleController();

  @override
  void initState() {
    super.initState();
    _pressCtrl.init(this, scale: 0.94);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? context.cPrimary;
    return _pressCtrl.wrapGesture(
      onTap: widget.onTap ?? () {},
      child: Semantics(
        button: true,
        label: widget.label,
        selected: widget.isSelected,
        child: AnimatedContainer(
          duration: DesignTokens.animNormal,
          curve: DesignTokens.easeOut,
          padding: widget.padding ??
              EdgeInsets.symmetric(
                  horizontal: context.spMD, vertical: context.spSM),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? selectedColor.withValues(alpha: 0.12)
                : context.cFieldFill,
            borderRadius: BorderRadius.circular(context.radiusFull),
            border: Border.all(
              color: widget.isSelected
                  ? selectedColor.withValues(alpha: 0.3)
                  : context.cBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: widget.isSelected
                        ? selectedColor
                        : context.cTextTertiary,
                  ),
                ),
                SizedBox(width: context.spXS),
              ] else if (widget.icon != null) ...[
                AppIcon(
                  widget.isSelected
                      ? (widget.selectedIcon ?? widget.icon!)
                      : widget.icon!,
                  size: widget.fontSize != null
                      ? widget.fontSize! + 2
                      : 15,
                  color: widget.isSelected
                      ? selectedColor
                      : context.cTextSecondary,
                ),
                SizedBox(width: context.spXS),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize ?? 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? selectedColor
                      : context.cTextPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              if (widget.showCount && widget.count > 0) ...[
                SizedBox(width: context.spXS),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.spXS,
                      vertical: context.spXXS),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? selectedColor
                        : context.cTextTertiary.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(context.radiusFull),
                  ),
                  child: Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.isSelected
                          ? Colors.white
                          : context.cTextTertiary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ],
        ),
      ),
      ),
    );
  }
}

class DsServiceChip extends StatelessWidget {
  const DsServiceChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final String? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? context.cPrimary;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: context.spSM, vertical: context.spXS),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.radiusSM),
        border: Border.all(color: chipColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: 12, color: chipColor),
            SizedBox(width: context.spXS),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: chipColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
