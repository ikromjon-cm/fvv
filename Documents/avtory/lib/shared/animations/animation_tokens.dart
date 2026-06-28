import 'package:flutter/material.dart';

class MotionTokens {
  MotionTokens._();

  // ─── Durations ───
  static const Duration ultraFast = Duration(milliseconds: 75);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // ─── Interaction Durations ───
  static const Duration press = Duration(milliseconds: 100);
  static const Duration lift = Duration(milliseconds: 150);
  static const Duration enter = Duration(milliseconds: 200);
  static const Duration exit = Duration(milliseconds: 150);
  static const Duration stagger = Duration(milliseconds: 50);
  static const Duration pulse = Duration(milliseconds: 2000);

  // ─── Easing Curves ───
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve emphatic = Curves.fastOutSlowIn;
  static const Curve spring = Curves.easeOutBack;
  static const Curve bounce = Curves.elasticOut;
  static const Curve linear = Curves.linear;

  // ─── Press Scale ───
  static const double pressScaleDefault = 0.97;
  static const double pressScaleSmall = 0.95;
  static const double pressScaleLarge = 0.98;

  // ─── Elevation Animation ───
  static const double elevationDelta = 4;

  // ─── Opacity Thresholds ───
  static const double disabledOpacity = 0.38;
  static const double loadingOpacity = 0.7;
  static const double overlayOpacity = 0.12;

  // ─── Slide Offsets ───
  static const Offset slideUp = Offset(0, 0.08);
  static const Offset slideDown = Offset(0, -0.08);
  static const Offset slideLeft = Offset(0.08, 0);
  static const Offset slideRight = Offset(-0.08, 0);

  // ─── Scale Thresholds ───
  static const double scaleEnterMin = 0.92;
  static const double scaleEnterMax = 1.0;
  static const double scaleExitMin = 1.0;
  static const double scaleExitMax = 1.08;

  // ─── Shimmer ───
  static const double shimmerOpacityLow = 0.3;
  static const double shimmerOpacityHigh = 0.7;

  // ─── Haptic ───
  static const bool useHaptic = true;
}

extension MotionTokensX on BuildContext {
  // ─── Duration Shortcuts ───
  Duration get dUltraFast => MotionTokens.ultraFast;
  Duration get dFast => MotionTokens.fast;
  Duration get dNormal => MotionTokens.normal;
  Duration get dMedium => MotionTokens.medium;
  Duration get dSlow => MotionTokens.slow;
  Duration get dExtraSlow => MotionTokens.extraSlow;
  Duration get dPress => MotionTokens.press;
  Duration get dLift => MotionTokens.lift;
  Duration get dEnter => MotionTokens.enter;
  Duration get dExit => MotionTokens.exit;
  Duration get dPulse => MotionTokens.pulse;

  // ─── Curve Shortcuts ───
  Curve get cStandard => MotionTokens.standard;
  Curve get cAccelerate => MotionTokens.accelerate;
  Curve get cDecelerate => MotionTokens.decelerate;
  Curve get cEmphatic => MotionTokens.emphatic;
  Curve get cSpring => MotionTokens.spring;
  Curve get cBounce => MotionTokens.bounce;

  // ─── Tween Helpers ───
  Tween<double> scaleIn() =>
      Tween(begin: MotionTokens.scaleEnterMin, end: MotionTokens.scaleEnterMax);
  Tween<double> scaleOut() =>
      Tween(begin: MotionTokens.scaleExitMin, end: MotionTokens.scaleExitMax);
  Tween<double> fadeIn() => Tween(begin: 0.0, end: 1.0);
  Tween<Offset> slideIn(Offset offset) => Tween(begin: offset, end: Offset.zero);
}
