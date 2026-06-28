import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon.dart';

class EtaCard extends StatefulWidget {
  const EtaCard({
    super.key,
    this.etaMinutes,
    this.isCalculating = false,
  });

  final int? etaMinutes;
  final bool isCalculating;

  @override
  State<EtaCard> createState() => _EtaCardState();
}

class _EtaCardState extends State<EtaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isCalculating) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(EtaCard old) {
    super.didUpdateWidget(old);
    if (widget.isCalculating && !old.isCalculating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isCalculating && old.isCalculating) {
      _ctrl.stop();
    }
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56CC), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56CC).withAlpha(80),
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
                const Text(
                  'Mexanik yetib keladi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.isCalculating
                      ? Row(
                          key: const ValueKey('calc'),
                          children: [
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, __) {
                                return Icon(
                                  Icons.more_horiz_rounded,
                                  size: 28,
                                  color: Colors.white.withAlpha(
                                      180 + (_ctrl.value * 75).round()),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Hisoblanmoqda',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '${widget.etaMinutes} min',
                          key: const ValueKey('eta'),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const AppIcon('access_time',
                size: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
