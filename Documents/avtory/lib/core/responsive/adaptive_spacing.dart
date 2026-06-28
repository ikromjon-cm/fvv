import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AdaptiveSpacing {
  AdaptiveSpacing._();

  static double screenHorizontal(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.desktop) return 48;
    if (w >= Breakpoints.large) return 32;
    if (w >= Breakpoints.expanded) return 20;
    return 16;
  }

  static double screenVertical(BuildContext context) {
    return 8;
  }

  static double cardGap(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.desktop) return 20;
    if (w >= Breakpoints.large) return 16;
    return 12;
  }

  static double sectionGap(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.desktop) return 40;
    if (w >= Breakpoints.large) return 32;
    return 24;
  }

  static double avatarSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.large) return 56;
    return 48;
  }

  static double cardMinHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Breakpoints.large) return 160;
    if (w >= Breakpoints.expanded) return 140;
    return 120;
  }

  static double bottomNavBottomInset(BuildContext context) =>
      MediaQuery.of(context).padding.bottom + 8;

  static double keyboardInset(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;
}

extension AdaptiveSpacingX on BuildContext {
  double get screenHorizontal => AdaptiveSpacing.screenHorizontal(this);
  double get screenVertical => AdaptiveSpacing.screenVertical(this);
  double get cardGap => AdaptiveSpacing.cardGap(this);
  double get sectionGap => AdaptiveSpacing.sectionGap(this);
  double get avatarSize => AdaptiveSpacing.avatarSize(this);
  double get cardMinHeight => AdaptiveSpacing.cardMinHeight(this);
  double get bottomNavInset => AdaptiveSpacing.bottomNavBottomInset(this);
  double get keyboardInset => AdaptiveSpacing.keyboardInset(this);
}
