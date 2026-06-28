import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: DesignTokens.displayLarge,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: DesignTokens.displayMedium,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: DesignTokens.displaySmall,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.25,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: DesignTokens.headlineLarge,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: DesignTokens.headlineMedium,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: DesignTokens.headlineSmall,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: DesignTokens.titleLarge,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: DesignTokens.titleMedium,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: DesignTokens.titleSmall,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    height: 1.45,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: DesignTokens.bodyLarge,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    height: 1.55,
  );

  static const TextStyle body = TextStyle(
    fontSize: DesignTokens.bodyMedium,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: DesignTokens.bodySmall,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: DesignTokens.labelLarge,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.3,
    letterSpacing: 0.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: DesignTokens.labelMedium,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: DesignTokens.labelSmall,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    height: 1.3,
    letterSpacing: 0.5,
  );

  // Deprecated — keep for backward compatibility during migration
  static const TextStyle h1 = displayMedium;
  static const TextStyle h2 = headlineLarge;
  static const TextStyle h3 = headlineSmall;
  static const TextStyle bodyMedium = titleMedium;
  static const TextStyle caption = bodySmall;
  static const TextStyle button = labelLarge;
  static const TextStyle logo = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    fontFamily: 'Inter',
  );
}
