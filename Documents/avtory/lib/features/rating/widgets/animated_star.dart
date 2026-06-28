import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../shared/widgets/app_icon.dart';

class AnimatedStar extends StatefulWidget {
  const AnimatedStar({
    super.key,
    this.size = 48,
    this.filled = false,
    this.onTap,
  });

  final double size;
  final bool filled;
  final VoidCallback? onTap;

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _rotateAnim = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled && !oldWidget.filled) {
      _controller.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.filled) {
          HapticFeedback.mediumImpact();
        }
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final showAnim = widget.filled;
          return Transform.scale(
            scale: showAnim ? _scaleAnim.value : 1.0,
            child: Transform.rotate(
              angle: showAnim ? _rotateAnim.value : 0,
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
              color: widget.filled
                  ? context.cRatingGold.withValues(alpha: 0.1)
                  : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.filled)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.star.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              AppIcon(
                widget.filled ? 'star_rounded' : 'star_border_rounded',
                size: widget.size * 0.6,
                color: widget.filled
                    ? DesignTokens.star
                    : context.cTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
