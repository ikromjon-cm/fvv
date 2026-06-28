import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class DesignTokens {
  DesignTokens._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF1A56CC);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF143E99);
  static const Color emergency = Color(0xFFF97316);
  static const Color emergencyLight = Color(0xFFFF8A3C);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color star = Color(0xFFFBBF24);
  static const Color verified = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A56CC), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Light Mode ───
  static const Color lightScaffold = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFF1F5F9);
  static const Color lightFieldFill = Color(0xFFF1F5F9);
  static const Color lightOverlay = Color(0x0A0F172A);

  // ─── Dark Mode ───
  static const Color darkScaffold = Color(0xFF0B1121);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkElevated = Color(0xFF1A2340);
  static const Color darkCard = Color(0xFF1A2340);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF1E293B);
  static const Color darkFieldFill = Color(0xFF1A2340);
  static const Color darkOverlay = Color(0x0AFFFFFF);

  // ─── Typography Scale ───
  static const double displayLarge = 34;
  static const double displayMedium = 28;
  static const double displaySmall = 22;
  static const double headlineLarge = 20;
  static const double headlineMedium = 18;
  static const double headlineSmall = 16;
  static const double titleLarge = 15;
  static const double titleMedium = 14;
  static const double titleSmall = 13;
  static const double bodyLarge = 15;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 13;
  static const double labelMedium = 11;
  static const double labelSmall = 10;

  // ─── Additional Semantic Colors ───
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color online = success;
  static const Color offline = Color(0xFF94A3B8);
  static const Color busy = warning;
  static const Color ratingGold = star;
  static const Color favoriteHeart = Color(0xFFEF4444);
  static const Color premium = Color(0xFF7C3AED);

  // ─── Additional Gradients ───
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Spacing ───
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 12;
  static const double spaceLG = 16;
  static const double spaceXL = 20;
  static const double space2XL = 24;
  static const double space3XL = 32;
  static const double space4XL = 48;
  static const double space5XL = 64;
  static const double space6XL = 80;
  static const double space7XL = 96;
  static const double space8XL = 128;

  // ─── Spacing Aliases ───
  static const double spacingXXS = spaceXXS;
  static const double spacingXS = spaceXS;
  static const double spacingSM = spaceSM;
  static const double spacingMD = spaceMD;
  static const double spacingLG = spaceLG;
  static const double spacingXL = spaceXL;
  static const double spacing2XL = space2XL;
  static const double spacing3XL = space3XL;
  static const double spacing4XL = space4XL;
  static const double spacing5XL = space5XL;
  static const double spacing6XL = space6XL;
  static const double spacing7XL = space7XL;
  static const double spacing8XL = space8XL;

  // ─── Border Radius ───
  static const double radiusNone = 0;
  static const double radiusXS = 4;
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radius2XL = 24;
  static const double radius3XL = 32;
  static const double radiusFull = 999;

  // ─── Elevation / Shadow Levels ───
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 4;
  static const double elevation4 = 8;
  static const double elevation5 = 16;

  // ─── Elevation / Shadows ───
  static List<BoxShadow> shadowSM(Color intensity) => [
        BoxShadow(
            color: intensity.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1)),
        BoxShadow(
            color: intensity.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1)),
      ];

  static List<BoxShadow> shadowMD(Color intensity) => [
        BoxShadow(
            color: intensity.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        BoxShadow(
            color: intensity.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1)),
      ];

  static List<BoxShadow> shadowLG(Color intensity) => [
        BoxShadow(
            color: intensity.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4)),
        BoxShadow(
            color: intensity.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2)),
      ];

  static List<BoxShadow> shadowXL(Color intensity) => [
        BoxShadow(
            color: intensity.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8)),
        BoxShadow(
            color: intensity.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4)),
      ];

  // ─── Color Aliases ───
  static const Color emerald = success;
  static const Color orange = emergency;

  // ─── Haptic ───
  static const bool useHaptic = true;

  // ─── Glass Effect ───
  static ImageFilter glassFilter(double blur) =>
      ImageFilter.blur(sigmaX: blur, sigmaY: blur);

  // ─── Elevation Shadow Builder ───
  static List<BoxShadow> elevationShadow(double elevation, Color color) {
    final alpha = (elevation / 16).clamp(0.0, 1.0);
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha * 0.12),
        blurRadius: elevation,
        offset: Offset(0, elevation * 0.5),
      ),
    ];
  }

  // ─── Animation ───
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration animationFast = animFast;
  static const Duration animationNormal = animNormal;
  static const Duration animationSlow = animSlow;
  static const Duration animVeryFast = Duration(milliseconds: 75);
  static const Duration animPulse = Duration(milliseconds: 2000);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve bounceOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

extension DesignTokensX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Semantic Colors ───
  Color get cScaffold =>
      isDark ? DesignTokens.darkScaffold : DesignTokens.lightScaffold;
  Color get cSurface =>
      isDark ? DesignTokens.darkSurface : DesignTokens.lightSurface;
  Color get cElevated =>
      isDark ? DesignTokens.darkElevated : DesignTokens.lightElevated;
  Color get cCard =>
      isDark ? DesignTokens.darkCard : DesignTokens.lightCard;
  Color get cTextPrimary =>
      isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
  Color get cTextSecondary => isDark
      ? DesignTokens.darkTextSecondary
      : DesignTokens.lightTextSecondary;
  Color get cTextTertiary => isDark
      ? DesignTokens.darkTextTertiary
      : DesignTokens.lightTextTertiary;
  Color get cBorder =>
      isDark ? DesignTokens.darkBorder : DesignTokens.lightBorder;
  Color get cDivider =>
      isDark ? DesignTokens.darkDivider : DesignTokens.lightDivider;
  Color get cFieldFill =>
      isDark ? DesignTokens.darkFieldFill : DesignTokens.lightFieldFill;
  Color get cOverlay =>
      isDark ? DesignTokens.darkOverlay : DesignTokens.lightOverlay;

  // ─── Legacy Color Aliases ───
  Color get cTextGray => cTextTertiary;
  Color get cTextDisabled => cTextTertiary;

  // ─── Brand Colors ───
  Color get cPrimary => DesignTokens.primary;
  Color get cPrimaryLight => DesignTokens.primaryLight;
  Color get cPrimaryDark => DesignTokens.primaryDark;
  Color get cEmergency => DesignTokens.emergency;
  Color get cEmergencyLight => DesignTokens.emergencyLight;
  Color get cSuccess => DesignTokens.success;
  Color get cSuccessLight => DesignTokens.successLight;
  Color get cDanger => DesignTokens.danger;
  Color get cDangerLight => DesignTokens.dangerLight;
  Color get cWarning => DesignTokens.warning;
  Color get cStar => DesignTokens.star;
  Color get cVerified => DesignTokens.verified;
  Color get cInfo => DesignTokens.info;
  Color get cOnline => DesignTokens.online;
  Color get cOffline => DesignTokens.offline;
  Color get cBusy => DesignTokens.busy;
  Color get cRatingGold => DesignTokens.ratingGold;
  Color get cFavorite => DesignTokens.favoriteHeart;
  Color get cPremium => DesignTokens.premium;

  // ─── Gradients ───
  LinearGradient get gPrimary => DesignTokens.primaryGradient;
  LinearGradient get gEmergency => DesignTokens.emergencyGradient;
  LinearGradient get gSuccess => DesignTokens.successGradient;
  LinearGradient get gPremium => DesignTokens.premiumGradient;

  // ─── Glass ───
  Color get glassFill => isDark
      ? DesignTokens.darkSurface.withValues(alpha: 0.82)
      : Colors.white.withValues(alpha: 0.82);
  Color get glassFillStrong => isDark
      ? DesignTokens.darkSurface.withValues(alpha: 0.93)
      : Colors.white.withValues(alpha: 0.93);
  Color get glassBorder => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.70);

  // ─── Shadows ───
  List<BoxShadow> get shadowSM =>
      DesignTokens.shadowSM(isDark ? Colors.black : DesignTokens.lightTextPrimary);
  List<BoxShadow> get shadowMD =>
      DesignTokens.shadowMD(isDark ? Colors.black : DesignTokens.lightTextPrimary);
  List<BoxShadow> get shadowLG =>
      DesignTokens.shadowLG(isDark ? Colors.black : DesignTokens.lightTextPrimary);
  List<BoxShadow> get shadowXL =>
      DesignTokens.shadowXL(isDark ? Colors.black : DesignTokens.lightTextPrimary);

  // ─── Border Radius Shortcuts ───
  double get radiusNone => DesignTokens.radiusNone;
  double get radiusXS => DesignTokens.radiusXS;
  double get radiusSM => DesignTokens.radiusSM;
  double get radiusMD => DesignTokens.radiusMD;
  double get radiusLG => DesignTokens.radiusLG;
  double get radiusXL => DesignTokens.radiusXL;
  double get radius2XL => DesignTokens.radius2XL;
  double get radius3XL => DesignTokens.radius3XL;
  double get radiusFull => DesignTokens.radiusFull;

  // ─── Spacing Shortcuts ───
  double get spXXS => DesignTokens.spaceXXS;
  double get spXS => DesignTokens.spaceXS;
  double get spSM => DesignTokens.spaceSM;
  double get spMD => DesignTokens.spaceMD;
  double get spLG => DesignTokens.spaceLG;
  double get spXL => DesignTokens.spaceXL;
  double get sp2XL => DesignTokens.space2XL;
  double get sp3XL => DesignTokens.space3XL;
  double get sp4XL => DesignTokens.space4XL;
  double get sp5XL => DesignTokens.space5XL;
  double get sp6XL => DesignTokens.space6XL;

  // ─── Animation Shortcuts ───
  Duration get dFast => DesignTokens.animFast;
  Duration get dNormal => DesignTokens.animNormal;
  Duration get dSlow => DesignTokens.animSlow;
  Duration get dVeryFast => DesignTokens.animVeryFast;
  Duration get dPulse => DesignTokens.animPulse;

  // ─── Gradient Builder ───
  LinearGradient gradient(Color a, Color b, {Alignment begin = Alignment.topLeft, Alignment end = Alignment.bottomRight}) =>
      LinearGradient(colors: [a, b], begin: begin, end: end);
}
