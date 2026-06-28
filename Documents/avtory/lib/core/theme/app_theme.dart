import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scaffold: DesignTokens.lightScaffold,
        surface: DesignTokens.lightSurface,
        elevated: DesignTokens.lightElevated,
        card: DesignTokens.lightCard,
        textPrimary: DesignTokens.lightTextPrimary,
        textSecondary: DesignTokens.lightTextSecondary,
        border: DesignTokens.lightBorder,
        divider: DesignTokens.lightDivider,
        fieldFill: DesignTokens.lightFieldFill,
        hint: DesignTokens.lightTextTertiary,
        overlay: DesignTokens.lightOverlay,
        snackBg: DesignTokens.lightElevated,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scaffold: DesignTokens.darkScaffold,
        surface: DesignTokens.darkSurface,
        elevated: DesignTokens.darkElevated,
        card: DesignTokens.darkCard,
        textPrimary: DesignTokens.darkTextPrimary,
        textSecondary: DesignTokens.darkTextSecondary,
        border: DesignTokens.darkBorder,
        divider: DesignTokens.darkDivider,
        fieldFill: DesignTokens.darkFieldFill,
        hint: DesignTokens.darkTextTertiary,
        overlay: DesignTokens.darkOverlay,
        snackBg: DesignTokens.darkElevated,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color elevated,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color divider,
    required Color fieldFill,
    required Color hint,
    required Color overlay,
    required Color snackBg,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseTypography =
        isDark ? Typography.material2021().white : Typography.material2021().black;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.primary,
      brightness: brightness,
      primary: DesignTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: DesignTokens.primary.withValues(alpha: 0.12),
      onPrimaryContainer: DesignTokens.primary,
      secondary: DesignTokens.emergency,
      onSecondary: Colors.white,
      secondaryContainer: DesignTokens.emergency.withValues(alpha: 0.12),
      onSecondaryContainer: DesignTokens.emergency,
      tertiary: DesignTokens.premium,
      onTertiary: Colors.white,
      tertiaryContainer: DesignTokens.premium.withValues(alpha: 0.12),
      onTertiaryContainer: DesignTokens.premium,
      error: DesignTokens.danger,
      onError: Colors.white,
      errorContainer: DesignTokens.danger.withValues(alpha: 0.12),
      onErrorContainer: DesignTokens.danger,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: fieldFill,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: divider,
      shadow: isDark ? Colors.black : DesignTokens.lightTextPrimary,
      inverseSurface: isDark ? DesignTokens.lightSurface : DesignTokens.darkSurface,
      onInverseSurface: isDark ? DesignTokens.lightTextPrimary : DesignTokens.darkTextPrimary,
      inversePrimary: DesignTokens.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      textTheme: baseTypography.apply(
        fontFamily: 'Inter',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      primaryIconTheme: const IconThemeData(color: DesignTokens.primary),
      primaryTextTheme: baseTypography.apply(
        fontFamily: 'Inter',
        bodyColor: DesignTokens.primary,
        displayColor: DesignTokens.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Inter',
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: DesignTokens.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: DesignTokens.primary);
          }
          return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: DesignTokens.primary, size: 22);
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
          elevation: 0,
          textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
          elevation: 0,
          textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          side: BorderSide(color: DesignTokens.primary.withValues(alpha: 0.3)),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
          textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter'),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter'),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide:
              BorderSide(color: DesignTokens.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide:
              const BorderSide(color: DesignTokens.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          borderSide:
              const BorderSide(color: DesignTokens.danger, width: 1.5),
        ),
        hintStyle: TextStyle(
            color: hint,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400),
        labelStyle: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
        errorStyle: const TextStyle(
            color: DesignTokens.danger,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
        prefixStyle: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
        suffixStyle: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLG)),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.none,
      ),
      dividerTheme: DividerThemeData(
          color: divider, thickness: 1, space: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBg,
        contentTextStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
        actionTextColor: DesignTokens.primary,
        width: 320,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark
              ? DesignTokens.darkTextTertiary
              : DesignTokens.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DesignTokens.primary;
          return border;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: fieldFill,
        selectedColor: DesignTokens.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            color: textPrimary,
            fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(
            fontSize: 13,
            fontFamily: 'Inter',
            color: textSecondary,
            fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        iconTheme: IconThemeData(
            color: textSecondary, size: 18),
        checkmarkColor: DesignTokens.primary,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXL)),
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Inter'),
        contentTextStyle: TextStyle(
            fontSize: 14,
            color: textSecondary,
            fontFamily: 'Inter',
            height: 1.4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radius2XL)),
        ),
        dragHandleColor: border,
        dragHandleSize: const Size(40, 4),
        modalBarrierColor: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.2),
        modalElevation: 0,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
        elevation: 8,
        textStyle: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: textPrimary,
            fontWeight: FontWeight.w500),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: DesignTokens.primary,
                fontWeight: FontWeight.w600);
          }
          return TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: textPrimary,
              fontWeight: FontWeight.w500);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignTokens.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 2,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLG)),
        extendedTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter'),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: DesignTokens.primary,
        inactiveTrackColor: border,
        thumbColor: DesignTokens.primary,
        overlayColor: DesignTokens.primary.withValues(alpha: 0.12),
        valueIndicatorColor: DesignTokens.primary,
        valueIndicatorTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter'),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        tickMarkShape: const RoundSliderTickMarkShape(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DesignTokens.primary,
        linearTrackColor: border,
        circularTrackColor: border.withValues(alpha: 0.3),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DesignTokens.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: border),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DesignTokens.primary;
          return textSecondary;
        }),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldFill,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            borderSide:
                BorderSide(color: DesignTokens.primary, width: 1.5),
          ),
        ),
      ),
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD))),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD))),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLG)),
        hourMinuteTextColor: textPrimary,
        dialHandColor: DesignTokens.primary,
        dialBackgroundColor: fieldFill,
        entryModeIconColor: textSecondary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLG)),
        headerBackgroundColor: DesignTokens.primary,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStateProperty.all(DesignTokens.primary),
        todayBackgroundColor:
            WidgetStateProperty.all(DesignTokens.primary.withValues(alpha: 0.12)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return hint;
          return textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DesignTokens.primary;
          return Colors.transparent;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textPrimary;
        }),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: DesignTokens.danger,
        textColor: Colors.white,
        textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter'),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: textSecondary,
        collapsedIconColor: textSecondary,
        textColor: textPrimary,
        collapsedTextColor: textPrimary,
        shape: const Border(),
        collapsedShape: const Border(),
        clipBehavior: Clip.none,
        childrenPadding: EdgeInsets.only(left: DesignTokens.spaceLG),
        expandedAlignment: Alignment.topLeft,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            EdgeInsets.symmetric(horizontal: DesignTokens.spaceLG),
        titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: textPrimary),
        subtitleTextStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: textSecondary),
        leadingAndTrailingTextStyle: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: textSecondary),
        iconColor: textSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: surface,
        indicatorColor: DesignTokens.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: DesignTokens.primary);
          }
          return TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: textPrimary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: DesignTokens.primary);
          }
          return IconThemeData(color: textSecondary);
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: DesignTokens.primary.withValues(alpha: 0.12),
          selectedForegroundColor: DesignTokens.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.darkElevated
              : DesignTokens.darkTextPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        ),
        textStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: isDark
                ? DesignTokens.darkTextPrimary
                : DesignTokens.lightSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}
