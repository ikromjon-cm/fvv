import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';

class MechanicStatusCard extends StatefulWidget {
  const MechanicStatusCard({
    super.key,
    required this.isAvailable,
    this.onToggle,
    this.statusLabel,
    this.statusIcon,
  });

  final bool isAvailable;
  final ValueChanged<bool>? onToggle;
  final String? statusLabel;
  final String? statusIcon;

  @override
  State<MechanicStatusCard> createState() => _MechanicStatusCardState();
}

class _MechanicStatusCardState extends State<MechanicStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.isAvailable;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isAvailable
            ? const LinearGradient(
                colors: [DesignTokens.success, Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  context.cSurface,
                  context.cSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? DesignTokens.success : context.cTextTertiary)
                .withValues(alpha: isAvailable ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAvailable
                    ? Colors.white.withValues(alpha: 0.2)
                    : context.cFieldFill,
                boxShadow: isAvailable
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: 0.3 * _pulseController.value,
                          ),
                          blurRadius: 12 + 8 * _pulseController.value,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AppIcon(
                  widget.statusIcon ?? (isAvailable ? 'check_circle_rounded' : 'pause_circle_outline'),
                  size: 26,
                  color: isAvailable ? Colors.white : context.cTextTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.statusLabel ?? (isAvailable ? "Bo'shman" : 'Bandman'),
                  style: (isAvailable
                      ? TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                          color: Colors.white,
                        )
                      : context.headingMedium(color: context.cTextPrimary)).copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: context.spXXS),
                Text(
                  isAvailable
                      ? "Yangi so'rovlarni qabul qilish mumkin"
                      : "Hozir so'rov qabul qilinmaydi",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: isAvailable
                        ? Colors.white.withValues(alpha: 0.8)
                        : context.cTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isAvailable ? Colors.white.withValues(alpha: 0.25) : context.cBorder,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  top: 2,
                  left: isAvailable ? 26 : 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAvailable ? Colors.white : context.cTextTertiary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isAvailable
                        ? const AppIcon('check', size: 14, color: DesignTokens.success)
                        : const AppIcon('close', size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
