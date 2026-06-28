import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../shared/widgets/app_icon.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal * 1.5, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: (iconColor ?? context.cPrimary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon,
                  size: iconSize * 0.45, color: iconColor ?? context.cPrimary),
            ),
            SizedBox(height: context.sectionGap),
            Text(
              title,
              style: context.headingMedium(color: context.cTextPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: context.cardGap),
              Text(
                subtitle!,
                style: context.bodyMedium(color: context.cTextSecondary).copyWith(height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: context.sectionGap),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.cPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel!,
                    style: context.labelLarge(color: context.cPrimary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
