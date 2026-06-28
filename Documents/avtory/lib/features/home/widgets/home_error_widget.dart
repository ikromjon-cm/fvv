import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';

class HomeErrorWidget extends StatelessWidget {
  const HomeErrorWidget({
    super.key,
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('error_outline_rounded',
                  size: 36, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 20),
            Text(
              message ?? 'Xatolik yuz berdi',
              style: context.headingSmall(color: context.cTextPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Iltimos, qayta urinib ko\'ring',
              style: context.bodySmall(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.sectionGap),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal * 1.75),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56CC),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A56CC).withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon('refresh',
                          size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Qayta urinish',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
