import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppColors {
  AppColors._();

  static const Color primary = DesignTokens.primary;
  static const Color primaryLight = DesignTokens.primaryLight;
  static const Color primaryDark = DesignTokens.primaryDark;

  static const Color darkBackground = DesignTokens.darkScaffold;
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color textGray = Color(0xFF94A3B8);
  static const Color borderGray = Color(0xFFE2E8F0);

  static const Color success = DesignTokens.success;
  static const Color warning = DesignTokens.warning;
  static const Color danger = DesignTokens.danger;

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF94A3B8);

  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffold = Color(0xFFF8F9FC);

  static const Color starColor = Color(0xFFFBBF24);
  static const Color availableBadge = Color(0xFF10B981);
  static const Color unavailableBadge = Color(0xFF94A3B8);

  static const LinearGradient primaryGradient = DesignTokens.primaryGradient;
  static const LinearGradient vibrantGradient = DesignTokens.primaryGradient;

  static const LinearGradient sheenGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color dScaffold = DesignTokens.darkScaffold;
  static const Color dSurface = DesignTokens.darkSurface;
  static const Color dElevated = DesignTokens.darkElevated;
  static const Color dTextPrimary = DesignTokens.darkTextPrimary;
  static const Color dTextSecondary = DesignTokens.darkTextSecondary;
  static const Color dTextGray = DesignTokens.darkTextTertiary;
  static const Color dTextDisabled = DesignTokens.darkTextTertiary;
  static const Color dBorder = DesignTokens.darkBorder;
  static const Color dFieldFill = DesignTokens.darkFieldFill;
}

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cScaffold => isDark ? AppColors.dScaffold : AppColors.scaffold;
  Color get cSurface => isDark ? AppColors.dSurface : AppColors.white;
  Color get cElevated => isDark ? AppColors.dElevated : AppColors.white;
  Color get cTextPrimary =>
      isDark ? AppColors.dTextPrimary : AppColors.textPrimary;
  Color get cTextSecondary =>
      isDark ? AppColors.dTextSecondary : AppColors.textSecondary;
  Color get cTextGray => isDark ? AppColors.dTextGray : AppColors.textGray;
  Color get cTextDisabled =>
      isDark ? AppColors.dTextDisabled : AppColors.textDisabled;
  Color get cBorder => isDark ? AppColors.dBorder : AppColors.borderGray;
  Color get cFieldFill => isDark ? AppColors.dFieldFill : AppColors.lightGray;

  Color get glassFill => isDark
      ? AppColors.dSurface.withValues(alpha: 0.82)
      : Colors.white.withValues(alpha: 0.82);

  Color get glassFillStrong => isDark
      ? AppColors.dSurface.withValues(alpha: 0.93)
      : Colors.white.withValues(alpha: 0.93);

  Color get glassBorder => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.7);
}
