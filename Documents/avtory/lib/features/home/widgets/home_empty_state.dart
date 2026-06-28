import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    super.key,
    required this.onAddVehicle,
    this.title,
    this.message,
  });

  final VoidCallback onAddVehicle;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1A56CC).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const AppIcon('directions_car_rounded',
                  size: 56, color: Color(0xFF1A56CC)),
            ),
            SizedBox(height: context.sectionGap),
            Text(
              title ?? 'Avtomobil qo\'shing',
              style: context.headingMedium(color: context.cTextPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.cardGap),
            Text(
              message ??
                  'Xizmatlardan foydalanish uchun\nyour vehicle ma\'lumotlarini qo\'shing',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onAddVehicle,
              child: Container(
                height: 54,
                padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal * 2),
                decoration: BoxDecoration(
                  gradient: DesignTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A56CC).withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Avtomobil qo\'shish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
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
