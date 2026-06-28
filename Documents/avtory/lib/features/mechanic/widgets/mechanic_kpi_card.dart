import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';

class MechanicKpiCard extends StatefulWidget {
  const MechanicKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = '',
    this.animate = true,
  });

  final String label;
  final String value;
  final String icon;
  final Color color;
  final String suffix;
  final bool animate;

  @override
  State<MechanicKpiCard> createState() => _MechanicKpiCardState();
}

class _MechanicKpiCardState extends State<MechanicKpiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.animate) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void didUpdateWidget(MechanicKpiCard old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
      ),
      child: DsCard(
        radius: context.radiusMD,
        hasBorder: true,
        padding: EdgeInsets.all(context.spMD + 2),
        shadows: context.shadowSM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.radiusSM),
              ),
              child: AppIcon(widget.icon, size: 18, color: widget.color),
            ),
            SizedBox(height: context.spSM + 2),
            Text(
              '${widget.value}${widget.suffix}',
              style: context.headingMedium(color: context.cTextPrimary).copyWith(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            SizedBox(height: context.spXXS),
            Text(
              widget.label,
              style: context.labelSmall(color: context.cTextSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
