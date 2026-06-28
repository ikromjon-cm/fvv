import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.headingMedium(color: context.cTextPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: context.bodySmall(color: context.cTextTertiary),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            SizedBox(width: context.spMD),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: context.labelLarge(color: context.cPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
