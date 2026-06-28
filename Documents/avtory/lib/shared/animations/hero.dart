import 'package:flutter/material.dart';

class MotionHero extends StatelessWidget {
  const MotionHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder = false,
    this.placeholderPadding,
  });

  final String tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final bool flightShuttleBuilder;
  final EdgeInsetsGeometry? placeholderPadding;

  @override
  Widget build(BuildContext context) {
    Widget heroChild = placeholderPadding != null
        ? Padding(
            padding: placeholderPadding!,
            child: SizedBox(child: child),
          )
        : SizedBox(child: child);

    return Hero(
      tag: tag,
      createRectTween: createRectTween ??
          (Rect? begin, Rect? end) => RectTween(begin: begin, end: end),
      flightShuttleBuilder: flightShuttleBuilder ? _flightShuttleBuilder : null,
      placeholderBuilder: (context, size, child) => child,
      child: heroChild,
    );
  }

  static Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final hero = direction == HeroFlightDirection.push
        ? toHeroContext.widget
        : fromHeroContext.widget;
    return hero is Hero ? hero.child : const SizedBox.shrink();
  }

  static String forMechanicAvatar(String id) => 'mechanic_avatar_$id';
  static String forVehicleImage(String id) => 'vehicle_image_$id';
  static String forProfileImage(String id) => 'profile_image_$id';
  static String forServiceImage(String id) => 'service_image_$id';
  static String forNotification(String id) => 'notification_$id';
  static String forRequest(String id) => 'request_$id';
  static String forMapPreview(String id) => 'map_preview_$id';
}
