import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';

class EmergencySosCard extends StatefulWidget {
  const EmergencySosCard({
    super.key,
    required this.onCall,
    this.headline,
    this.explanation,
    this.buttonLabel,
  });

  final VoidCallback onCall;
  final String? headline;
  final String? explanation;
  final String? buttonLabel;

  @override
  State<EmergencySosCard> createState() => _EmergencySosCardState();
}

class _EmergencySosCardState extends State<EmergencySosCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.radiusLG),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withAlpha(80),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const AppIcon('sos_rounded',
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                Text(
                  'Favqulodda',
                  style: context.labelSmall(color: Colors.white)
                      .copyWith(letterSpacing: 1),
                ),
                  ],
                ),
                SizedBox(height: context.cardGap),
                Text(
                  widget.headline ?? 'Favqulodda yordam',
                  style: context.headingMedium(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.explanation ??
                      'Jiddiy avariya yoki xavfli vaziyat?\nTez yordam xizmatiga qongiroq qiling',
                  style: context.bodySmall(
                      color: Colors.white.withValues(alpha: 0.75)),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              widget.onCall();
            },
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(60),
                        blurRadius: 12 + _pulseCtrl.value * 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon('phone_outlined',
                          size: 24, color: Color(0xFFEF4444)),
                      const SizedBox(height: 2),
                      Text(
                        widget.buttonLabel ?? '112',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
