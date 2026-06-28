import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/adaptive_spacing.dart';
import '../../core/responsive/adaptive_typography.dart';
import '../../shared/widgets/app_icon.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message,
    this.onRetry,
    this.icon = 'wifi_off_rounded',
  });

  final String? message;
  final VoidCallback? onRetry;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal * 1.5, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.cDanger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, size: 36, color: context.cDanger),
            ),
            SizedBox(height: context.sectionGap),
            Text(
              message ?? 'Xatolik yuz berdi',
              style: context.headingSmall(color: context.cTextPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Internet aloqasini tekshiring va qayta urinib k\u{00f6}ring.',
              style: context.bodySmall(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.sectionGap),
              SizedBox(
                width: 180,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: AppIcon('refresh_rounded', size: 20, color: context.cPrimary),
                  label: Text(
                    'Qayta urinish',
                    style: context.labelLarge(color: context.cPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.cPrimary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
