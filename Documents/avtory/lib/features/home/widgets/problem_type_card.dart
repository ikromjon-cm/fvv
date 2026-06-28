import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/components/cards/app_cards.dart';

enum ProblemCardState { normal, pressed, disabled }

class ProblemTypeCard extends StatefulWidget {
  const ProblemTypeCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.responseTime,
    this.color,
    this.isPopular = false,
    this.state = ProblemCardState.normal,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String? description;
  final String? responseTime;
  final Color? color;
  final bool isPopular;
  final ProblemCardState state;
  final VoidCallback onTap;

  @override
  State<ProblemTypeCard> createState() => _ProblemTypeCardState();
}

class _ProblemTypeCardState extends State<ProblemTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? DesignTokens.primary;
    final isDisabled = widget.state == ProblemCardState.disabled;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _ctrl.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _ctrl.reverse();
              HapticFeedback.lightImpact();
              widget.onTap();
            },
      onTapCancel: isDisabled ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AppCard(
          padding: const EdgeInsets.all(16),
          radius: context.radiusLG,
          shadows: context.shadowSM,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? context.cBorder
                          : color.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(widget.icon,
                        size: 22,
                        color: isDisabled
                            ? context.cTextTertiary
                            : color),
                  ),
                  SizedBox(height: context.cardGap),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: isDisabled
                          ? context.cTextTertiary
                          : context.cTextPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: context.bodySmall(
                          color: isDisabled
                              ? const Color(0xFFCBD5E1)
                              : context.cTextTertiary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (widget.responseTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const AppIcon('timer_outlined',
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          widget.responseTime!,
                          style: context.labelSmall(
                              color: context.cTextTertiary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (widget.isPopular)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: DesignTokens.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Mashhur',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
