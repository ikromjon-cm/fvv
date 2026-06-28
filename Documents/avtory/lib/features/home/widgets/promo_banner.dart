import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    this.messages,
  });

  final List<String>? messages;

  @override
  Widget build(BuildContext context) {
    if (messages == null || messages!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontal, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A56CC).withAlpha(12),
            const Color(0xFF4F46E5).withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.radiusLG),
        border: Border.all(
          color: const Color(0xFF1A56CC).withAlpha(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56CC).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'i',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Color(0xFF1A56CC),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              messages!.first,
              style: context.bodyMedium(color: context.cTextPrimary)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
