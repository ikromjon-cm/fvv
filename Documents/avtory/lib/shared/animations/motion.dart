import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'animation_tokens.dart';
import '../../core/constants/design_tokens.dart';

class Motion {
  Motion._();

  // ─── Haptic Feedback ───
  static Future<void> hapticLight() => HapticFeedback.lightImpact();
  static Future<void> hapticMedium() => HapticFeedback.mediumImpact();
  static Future<void> hapticHeavy() => HapticFeedback.heavyImpact();
  static Future<void> hapticSelection() => HapticFeedback.selectionClick();

  static Future<void> onPress() async {
    if (MotionTokens.useHaptic) await HapticFeedback.lightImpact();
  }

  static Future<void> onLongPress() async {
    if (MotionTokens.useHaptic) await HapticFeedback.heavyImpact();
  }

  static Future<void> onToggle() async {
    if (MotionTokens.useHaptic) await HapticFeedback.selectionClick();
  }

  // ─── Animated Builder Helpers ───
  static Widget buildScale(
    Animation<double> animation, {
    required Widget child,
  }) =>
      AnimatedBuilder(
        animation: animation,
        builder: (_, c) => Transform.scale(scale: animation.value, child: c),
        child: child,
      );

  static Widget buildFade(
    Animation<double> animation, {
    required Widget child,
  }) =>
      FadeTransition(opacity: animation, child: child);

  static Widget buildSlide(
    Animation<Offset> animation, {
    required Widget child,
  }) =>
      SlideTransition(position: animation, child: child);

  static Widget buildScaleFade(
    Animation<double> animation, {
    required Widget child,
  }) =>
      AnimatedBuilder(
        animation: animation,
        builder: (_, c) => Opacity(
          opacity: animation.value,
          child: Transform.scale(scale: animation.value, child: c),
        ),
        child: child,
      );

  static Widget buildShimmer({
    required BuildContext context,
    required Widget child,
    bool useDark = false,
  }) =>
      Shimmer.fromColors(
        baseColor: useDark ? context.cBorder : context.cBorder,
        highlightColor: useDark ? context.cFieldFill : context.cSurface,
        period: const Duration(milliseconds: 1500),
        child: child,
      );
}

// ─── Reusable Press Scale Capability ───
class PressScaleController {
  AnimationController? _ctrl;
  Animation<double>? _anim;

  void init(TickerProvider vsync, {double scale = MotionTokens.pressScaleDefault}) {
    _ctrl = AnimationController(
      vsync: vsync,
      duration: MotionTokens.press,
    );
    _anim = Tween(begin: 1.0, end: scale).animate(
      CurvedAnimation(parent: _ctrl!, curve: MotionTokens.decelerate),
    );
  }

  void dispose() {
    _ctrl?.dispose();
    _ctrl = null;
    _anim = null;
  }

  Animation<double> get animation => _anim!;
  bool get isInitialized => _ctrl != null;

  void onScaleDown() => _ctrl?.forward();
  void onScaleUp() => _ctrl?.reverse();
  void onScaleCancel() => _ctrl?.reverse();

  Widget wrap(Widget child) => AnimatedBuilder(
        animation: _anim!,
        builder: (_, c) => Transform.scale(scale: _anim!.value, child: c),
        child: child,
      );

  GestureDetector wrapGesture({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTapDown: onTap != null ? (_) => onScaleDown() : null,
      onTapUp: onTap != null ? (_) => _onTapAction(onTap) : null,
      onTapCancel: onTap != null ? onScaleCancel : null,
      onLongPress: onLongPress != null
          ? () async {
              await Motion.onLongPress();
              onLongPress();
            }
          : null,
      child: wrap(child),
    );
  }

  void _onTapAction(VoidCallback callback) {
    onScaleUp();
    Motion.onPress();
    callback();
  }
}

// ─── Reusable Entrance Animation Widgets ───
class FadeInOnVisible extends StatefulWidget {
  const FadeInOnVisible({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
    this.offsetY = 12,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  @override
  State<FadeInOnVisible> createState() => _FadeInOnVisibleState();
}

class _FadeInOnVisibleState extends State<FadeInOnVisible>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - _anim.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class StaggeredFadeList extends StatelessWidget {
  const StaggeredFadeList({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 60),
    this.offsetY = 16,
  });

  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        return _StaggeredItem(
          index: index,
          duration: itemDuration,
          delay: staggerDelay,
          offsetY: offsetY,
          child: entry.value,
        );
      }).toList(),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({
    required this.index,
    required this.duration,
    required this.delay,
    required this.offsetY,
    required this.child,
  });

  final int index;
  final Duration duration;
  final Duration delay;
  final double offsetY;
  final Widget child;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - _anim.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class AnimatedCount extends StatefulWidget {
  const AnimatedCount({
    super.key,
    required this.target,
    this.duration = const Duration(milliseconds: 500),
    this.style,
  });

  final int target;
  final Duration duration;
  final TextStyle? style;

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _display = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() => _display = (_anim.value * widget.target).round()));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display.toString(),
      style: widget.style,
    );
  }
}
