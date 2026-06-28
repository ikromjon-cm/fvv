import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({
    super.key,
    required this.onDismiss,
    this.title,
    this.message,
  });

  final VoidCallback onDismiss;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: EdgeInsets.all(context.spLG),
      gradient: context.gPrimary,
      radius: context.radiusXL,
      shadows: [
        BoxShadow(
          color: context.cPrimary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: context.cPrimary.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'AVTORY ga xush kelibsiz!',
                  style: context.headingMedium(color: Colors.white),
                ),
                SizedBox(height: context.cardGap),
                Text(
                  message ??
                      'Yo\'l yordami. Bir necha daqiqada.\nYordamni his qiling.',
                  style: context.bodySmall(
                      color: Colors.white.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('close',
                  size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
