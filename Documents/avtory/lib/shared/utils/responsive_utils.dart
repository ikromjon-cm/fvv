import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static const double _mobile = 480;
  static const double _tablet = 768;
  static const double _desktop = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobile &&
      MediaQuery.of(context).size.width < _desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktop;

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < _tablet;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double safeTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static double keyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double responsiveValue(
      BuildContext context, double mobile, double tablet, double desktop) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static double hp(BuildContext context, double percent) =>
      height(context) * percent / 100;

  static double wp(BuildContext context, double percent) =>
      width(context) * percent / 100;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool hasNotch(BuildContext context) =>
      MediaQuery.of(context).padding.top > 24;
}
