import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';

class SearchingIndicator extends StatefulWidget {
  const SearchingIndicator({
    super.key,
    this.message,
    this.mechanicsCount,
  });

  final String? message;
  final int? mechanicsCount;

  @override
  State<SearchingIndicator> createState() => _SearchingIndicatorState();
}

class _SearchingIndicatorState extends State<SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(context.radiusXL),
        border: Border.all(
          color: const Color(0xFFF59E0B).withAlpha(40),
        ),
        boxShadow: context.shadowLG,
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        value: _ctrl.value,
                        color: const Color(0xFFF59E0B),
                        backgroundColor:
                            const Color(0xFFF59E0B).withAlpha(20),
                      ),
                    ),
                    Icon(
                      Icons.search_rounded,
                      size: 28,
                      color: const Color(0xFFF59E0B)
                          .withAlpha(180 + (_ctrl.value * 75).round()),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Mexanik qidirilmoqda',
            style: context.headingMedium(color: context.cTextPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            widget.message ?? 'Atrofdagi mexaniklar taklif\njo\'natilmoqda',
            style: context.bodySmall(color: context.cTextSecondary),
            textAlign: TextAlign.center,
          ),
          if (widget.mechanicsCount != null) ...[
            SizedBox(height: context.cardGap),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.mechanicsCount} ta mexanik topildi',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
