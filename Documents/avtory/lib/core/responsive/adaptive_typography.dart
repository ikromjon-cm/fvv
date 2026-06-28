import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AdaptiveTypography {
  AdaptiveTypography._();

  static double scale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.desktop) return 1.15;
    if (w >= Breakpoints.large) return 1.08;
    if (w >= Breakpoints.expanded) return 1.03;
    return 1.0;
  }
}

extension AdaptiveTypographyX on BuildContext {
  double get textScale => AdaptiveTypography.scale(this);

  double scaled(double size) => size * textScale;

  TextStyle headingLarge({Color? color}) => TextStyle(
        fontSize: scaled(22),
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: color,
        letterSpacing: -0.5,
      );

  TextStyle headingMedium({Color? color}) => TextStyle(
        fontSize: scaled(18),
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: color,
        letterSpacing: -0.3,
      );

  TextStyle headingSmall({Color? color}) => TextStyle(
        fontSize: scaled(16),
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle bodyLarge({Color? color}) => TextStyle(
        fontSize: scaled(15),
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle bodyMedium({Color? color}) => TextStyle(
        fontSize: scaled(14),
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle bodySmall({Color? color}) => TextStyle(
        fontSize: scaled(12),
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle labelLarge({Color? color}) => TextStyle(
        fontSize: scaled(13),
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle labelSmall({Color? color}) => TextStyle(
        fontSize: scaled(11),
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle labelMedium({Color? color}) => TextStyle(
        fontSize: scaled(12),
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle titleLarge({Color? color}) => TextStyle(
        fontSize: scaled(17),
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle titleMedium({Color? color}) => TextStyle(
        fontSize: scaled(15),
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: color,
      );

  TextStyle titleSmall({Color? color}) => TextStyle(
        fontSize: scaled(14),
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: color,
      );
}
