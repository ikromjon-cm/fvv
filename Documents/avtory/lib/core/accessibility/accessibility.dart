import 'package:flutter/material.dart';

class AppSemantics {
  AppSemantics._();

  static Widget button({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) =>
      Semantics(
        button: true,
        label: label,
        hint: hint,
        onTap: onTap,
        child: child,
      );

  static Widget image({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        image: true,
        label: label,
        child: child,
      );

  static Widget header({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        header: true,
        label: label,
        child: child,
      );

  static Widget link({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        link: true,
        label: label,
        child: child,
      );

  static Widget list({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        label: label,
        child: child,
      );

  static Widget listItem({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        button: true,
        label: label,
        child: child,
      );

  static Widget checkbox({
    required Widget child,
    required String label,
    required bool value,
  }) =>
      MergeSemantics(
        child: Semantics(
          label: label,
          value: value.toString(),
          child: child,
        ),
      );

  static Widget slider({
    required Widget child,
    required String label,
    required double value,
  }) =>
      Semantics(
        slider: true,
        label: label,
        value: value.toStringAsFixed(0),
        child: child,
      );

  static Widget badge({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        label: label,
        child: ExcludeSemantics(
          child: child,
        ),
      );

  static Widget icon({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        label: label,
        excludeSemantics: true,
        child: child,
      );

  static Widget liveRegion({
    required Widget child,
    required String label,
  }) =>
      Semantics(
        liveRegion: true,
        label: label,
        child: child,
      );

  static Widget hidden(Widget child) => ExcludeSemantics(child: child);

  static const double minTouchTarget = 44.0;

  static Widget touchTarget({
    required Widget child,
    required VoidCallback? onTap,
    double minSize = minTouchTarget,
  }) {
    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
        child: child,
      ),
    );
  }

  static EdgeInsets ensureTouchTarget({
    required EdgeInsets existing,
    double minSize = minTouchTarget,
    double currentWidth = 0,
    double currentHeight = 0,
  }) {
    final hPad = currentWidth < minSize
        ? (minSize - currentWidth) / 2 + existing.horizontal / 2
        : existing.horizontal / 2;
    final vPad = currentHeight < minSize
        ? (minSize - currentHeight) / 2 + existing.vertical / 2
        : existing.vertical / 2;
    return EdgeInsets.symmetric(
      horizontal: hPad.clamp(existing.left, double.infinity),
      vertical: vPad.clamp(existing.top, double.infinity),
    );
  }
}

class AccessibilitySettings {
  AccessibilitySettings._();

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;

  static double textScaleFactor(BuildContext context) =>
      MediaQuery.of(context).textScaler.textScaleFactor;

  static bool highContrast(BuildContext context) =>
      MediaQuery.of(context).highContrast;

  static Brightness brightness(BuildContext context) =>
      MediaQuery.of(context).platformBrightness;

  static bool isAccessibilityFontScale(BuildContext context) =>
      textScaleFactor(context) > 1.2;

  static bool isLargeFontScale(BuildContext context) =>
      textScaleFactor(context) > 1.5;
}

extension AccessibilityX on BuildContext {
  bool get reduceMotion => AccessibilitySettings.reduceMotion(this);
  double get textScale => AccessibilitySettings.textScaleFactor(this);
  bool get highContrast => AccessibilitySettings.highContrast(this);
  bool get isAccessibilityFontScale =>
      AccessibilitySettings.isAccessibilityFontScale(this);
  bool get isLargeFontScale =>
      AccessibilitySettings.isLargeFontScale(this);

  Duration get animDurationSafe =>
      reduceMotion ? Duration.zero : const Duration(milliseconds: 250);
}
