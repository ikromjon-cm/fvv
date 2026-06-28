import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

/// A translucent "glass" surface.
///
/// NOTE: this intentionally does NOT use `BackdropFilter`/`ImageFilter.blur`.
/// Real-time blur renders as a black box on some Android devices under the
/// Impeller renderer (Flutter 3.x default). A translucent solid fill is
/// reliable on every device and still reads as glass over a map or gradient.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 18, // kept for API compatibility (unused)
    this.radius = 20,
    this.strong = false,
    this.circle = false,
    this.tint,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double radius;
  final bool strong;
  final bool circle;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = strong ? context.glassFillStrong : context.glassFill;
    final blended = tint != null
        ? Color.alphaBlend(tint!.withValues(alpha: 0.16), fill)
        : fill;
    final br = circle ? null : BorderRadius.circular(radius);
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: blended,
        shape: shape,
        borderRadius: br,
        border: Border.all(color: context.glassBorder),
        boxShadow: [
          BoxShadow(
            color: (tint ?? Colors.black)
                .withValues(alpha: context.isDark ? 0.30 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}
