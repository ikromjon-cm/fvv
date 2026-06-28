import 'package:flutter/material.dart';
import 'animation_tokens.dart';

enum PageTransitionType {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  sharedAxisX,
  sharedAxisY,
  sharedAxisZ,
}

class MotionPageTransitions {
  MotionPageTransitions._();

  static Widget _build<T>({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required PageTransitionType type,
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: MotionTokens.emphatic,
      reverseCurve: MotionTokens.decelerate,
    );

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: curved, child: child);

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.06),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.94,
            end: 1.0,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.sharedAxisX:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(secondaryAnimation.value * 0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.sharedAxisY:
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, secondaryAnimation.value * 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case PageTransitionType.sharedAxisZ:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 1.0 - secondaryAnimation.value * 0.03,
            end: 1.0,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
    }
  }

  static Route<T> fade<T>(Widget page) => _create(PageTransitionType.fade, page);
  static Route<T> slideUp<T>(Widget page) => _create(PageTransitionType.slideUp, page);
  static Route<T> slideDown<T>(Widget page) => _create(PageTransitionType.slideDown, page);
  static Route<T> slideLeft<T>(Widget page) => _create(PageTransitionType.slideLeft, page);
  static Route<T> slideRight<T>(Widget page) => _create(PageTransitionType.slideRight, page);
  static Route<T> scale<T>(Widget page) => _create(PageTransitionType.scale, page);
  static Route<T> sharedAxisX<T>(Widget page) => _create(PageTransitionType.sharedAxisX, page);
  static Route<T> sharedAxisY<T>(Widget page) => _create(PageTransitionType.sharedAxisY, page);
  static Route<T> sharedAxisZ<T>(Widget page) => _create(PageTransitionType.sharedAxisZ, page);

  static Route<T> _create<T>(PageTransitionType type, Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, secondaryAnimation) => _build(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: page,
        type: type,
      ),
      transitionDuration: MotionTokens.medium,
      reverseTransitionDuration: MotionTokens.fast,
    );
  }

  static Future<T?> push<T>(BuildContext context, Widget page, {PageTransitionType type = PageTransitionType.slideUp}) {
    return Navigator.of(context).push<T>(_create(type, page));
  }
}

class MotionRouteTransition extends PageRouteBuilder {
  MotionRouteTransition({
    required this.page,
    this.transitionType = PageTransitionType.slideUp,
    super.settings,
  }) : super(
          pageBuilder: (_, animation, secondaryAnimation) =>
              MotionPageTransitions._build(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: page,
            type: transitionType,
          ),
          transitionDuration: MotionTokens.medium,
          reverseTransitionDuration: MotionTokens.fast,
        );

  final Widget page;
  final PageTransitionType transitionType;
}
