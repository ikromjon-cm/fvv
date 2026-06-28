import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';

class IncomingRequestCard extends StatefulWidget {
  const IncomingRequestCard({
    super.key,
    required this.driverName,
    required this.problemType,
    this.problemIcon,
    this.distance = '',
    this.etaMinutes = 3,
    this.reward = '',
    this.timeAgo = '',
    this.onAccept,
    this.onDecline,
    this.onCall,
    this.onChat,
  });

  final String driverName;
  final String problemType;
  final String? problemIcon;
  final String distance;
  final int etaMinutes;
  final String reward;
  final String timeAgo;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  @override
  State<IncomingRequestCard> createState() => _IncomingRequestCardState();
}

class _IncomingRequestCardState extends State<IncomingRequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _urgencyController;
  late Animation<double> _urgencyAnim;

  @override
  void initState() {
    super.initState();
    _urgencyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _urgencyAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _urgencyController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _urgencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.etaMinutes <= 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(
          color: isUrgent
              ? context.cEmergency.withValues(alpha: 0.3)
              : DesignTokens.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? context.cEmergency : DesignTokens.primary)
                .withValues(alpha: isUrgent ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isUrgent
                          ? DesignTokens.emergencyGradient
                          : DesignTokens.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(
                        'person_rounded',
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isUrgent)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: AnimatedBuilder(
                        animation: _urgencyAnim,
                        builder: (_, child) => Transform.scale(
                          scale: 1.0 + 0.2 * _urgencyAnim.value,
                          child: child,
                        ),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: DesignTokens.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: AppIcon(
                              'bolt_rounded',
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                          Flexible(
                            child: Text(
                              widget.driverName,
                              style: context.headingSmall(color: context.cTextPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.timeAgo.isNotEmpty) ...[
                            SizedBox(width: context.spSM - 2),
                            Text(
                              widget.timeAgo,
                              style: context.labelSmall(color: context.cTextTertiary),
                            ),
                          ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: isUrgent
                              ? context.cEmergency
                              : DesignTokens.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.problemType,
                          style: context.labelLarge(color: isUrgent
                              ? context.cEmergency
                              : context.cPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.reward.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.cSuccess.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    widget.reward,
                    style: context.labelSmall(color: context.cSuccess).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.distance.isNotEmpty) ...[
                AppIcon(
                  'location_on_outlined',
                  size: 13,
                  color: context.cTextTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.distance,
                  style: context.labelSmall(color: context.cTextSecondary),
                ),
                const SizedBox(width: 16),
              ],
              AppIcon(
                'access_time_rounded',
                size: 13,
                color: isUrgent
                    ? context.cEmergency
                    : context.cTextTertiary,
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _urgencyAnim,
                builder: (_, child) => Text(
                  isUrgent
                      ? 'Tezlik kerak!'
                      : '~${widget.etaMinutes} daqiqa',
                  style: (isUrgent
                      ? context.labelSmall(color: context.cEmergency)
                      : context.labelSmall(color: context.cTextSecondary)
                  ).copyWith(
                    fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w400,
                    color: isUrgent
                        ? Color.lerp(
                            context.cEmergency,
                            context.cDanger,
                            _urgencyAnim.value,
                          )
                        : null,
                  ),
                ),
                child: null,
              ),
              const Spacer(),
              if (widget.onCall != null)
                GestureDetector(
                  onTap: widget.onCall,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSM,
                      ),
                    ),
                    child: AppIcon(
                      'phone_outlined',
                      size: 14,
                      color: context.cTextSecondary,
                    ),
                  ),
                ),
              if (widget.onChat != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onChat,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSM,
                      ),
                    ),
                    child: AppIcon(
                      'chat_outlined',
                      size: 14,
                      color: context.cTextSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onDecline?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                      border: Border.all(color: context.cBorder),
                    ),
                    child: Center(
                      child: Text(
                        'Rad etish',
                        style: context.labelLarge(color: context.cTextSecondary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onAccept?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isUrgent
                          ? DesignTokens.emergencyGradient
                          : DesignTokens.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUrgent
                                  ? DesignTokens.emergency
                                  : DesignTokens.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Qabul qilish',
                        style: context.labelLarge(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
