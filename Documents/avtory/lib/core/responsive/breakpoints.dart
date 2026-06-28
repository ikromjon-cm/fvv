import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double compact = 0;
  static const double medium = 360;
  static const double expanded = 400;
  static const double large = 600;
  static const double extraLarge = 840;
  static const double desktop = 1024;
  static const double wide = 1440;

  static bool isCompact(double width) => width < medium;
  static bool isMedium(double width) => width >= medium && width < expanded;
  static bool isExpanded(double width) => width >= expanded && width < large;
  static bool isLarge(double width) => width >= large && width < extraLarge;
  static bool isExtraLarge(double width) => width >= extraLarge && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
  static bool isTablet(double width) => width >= large && width < desktop;
  static bool isPhone(double width) => width < large;
}

extension BreakpointsX on BuildContext {
  double get widthPx => MediaQuery.of(this).size.width;
  double get heightPx => MediaQuery.of(this).size.height;

  bool get isCompact => Breakpoints.isCompact(widthPx);
  bool get isMedium => Breakpoints.isMedium(widthPx);
  bool get isExpanded => Breakpoints.isExpanded(widthPx);
  bool get isLarge => Breakpoints.isLarge(widthPx);
  bool get isExtraLarge => Breakpoints.isExtraLarge(widthPx);
  bool get isDesktop => Breakpoints.isDesktop(widthPx);
  bool get isTablet => Breakpoints.isTablet(widthPx);
  bool get isPhone => Breakpoints.isPhone(widthPx);

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
}
