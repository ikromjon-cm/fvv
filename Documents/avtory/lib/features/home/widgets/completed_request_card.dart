import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/ds_card.dart';

class CompletedRequestCard extends StatelessWidget {
  const CompletedRequestCard({
    super.key,
    required this.mechanicName,
    this.problemType,
    this.totalDuration,
    this.onRate,
    this.onViewHistory,
    this.onReturnHome,
  });

  final String mechanicName;
  final String? problemType;
  final String? totalDuration;
  final VoidCallback? onRate;
  final VoidCallback? onViewHistory;
  final VoidCallback? onReturnHome;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: EdgeInsets.all(context.sp2XL),
      radius: context.radiusXL,
      shadows: context.shadowMD,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withAlpha(40),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Xizmat yakunlandi!',
            style: context.headingMedium(color: context.cTextPrimary)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '$mechanicName tomonidan xizmat\nmuvaffaqiyatli yakunlandi',
            style: context.bodySmall(color: context.cTextSecondary),
            textAlign: TextAlign.center,
          ),
          if (totalDuration != null) ...[
            SizedBox(height: context.cardGap),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Xizmat davomiyligi: $totalDuration',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
          SizedBox(height: context.sectionGap),
          Row(
            children: [
              if (onRate != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onRate,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A56CC),
                            Color(0xFF4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A56CC)
                                .withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Baholash',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (onRate != null && onViewHistory != null)
                const SizedBox(width: 10),
              if (onViewHistory != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onViewHistory,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A56CC).withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Tarix',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A56CC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (onReturnHome != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onReturnHome,
              child: const Text(
                'Bosh sahifaga qaytish',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CancelledRequestCard extends StatelessWidget {
  const CancelledRequestCard({
    super.key,
    this.reason,
    this.onCreateNew,
    this.onContactSupport,
  });

  final String? reason;
  final VoidCallback? onCreateNew;
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: EdgeInsets.all(context.sp2XL),
      radius: context.radiusXL,
      shadows: context.shadowMD,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 40,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'So\'rov bekor qilindi',
            style: context.headingMedium(color: context.cTextPrimary)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            reason ?? 'So\'rovingiz bekor qilindi.\nYangi so\'rov yaratishingiz mumkin.',
            style: context.bodySmall(color: context.cTextSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.sectionGap),
          Row(
            children: [
              if (onCreateNew != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onCreateNew,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A56CC),
                            Color(0xFF4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A56CC)
                                .withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Yangi so\'rov',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (onCreateNew != null && onContactSupport != null)
                const SizedBox(width: 10),
              if (onContactSupport != null)
                Expanded(
                  child: GestureDetector(
                    onTap: onContactSupport,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A56CC).withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Yordam',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A56CC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
