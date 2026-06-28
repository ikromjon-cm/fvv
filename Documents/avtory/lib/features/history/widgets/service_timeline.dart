import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_badge.dart';

class ServiceTimeline extends StatelessWidget {
  const ServiceTimeline({
    super.key,
    required this.stages,
    this.connectorColor,
    this.dotSize = 12,
    this.lineWidth = 2,
  });

  final List<TimelineStage> stages;
  final Color? connectorColor;
  final double dotSize;
  final double lineWidth;

  static List<TimelineStage> buildStages({
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
  }) {
    return [
      TimelineStage(
        icon: 'add_circle_outline',
        label: 'So\'rov yuborildi',
        timestamp: createdAt,
        isCompleted: true,
      ),
      TimelineStage(
        icon: 'handyman_outlined',
        label: 'Mexanik qabul qildi',
        timestamp: acceptedAt,
        isCompleted: acceptedAt != null,
      ),
      TimelineStage(
        icon: 'near_me_rounded',
        label: 'Mexanik yo\'lga chiqdi',
        timestamp: null,
        isCompleted: acceptedAt != null,
        isActive: acceptedAt != null && arrivedAt == null,
      ),
      TimelineStage(
        icon: 'place_rounded',
        label: 'Mexanik yetib keldi',
        timestamp: arrivedAt,
        isCompleted: arrivedAt != null,
      ),
      TimelineStage(
        icon: 'build_rounded',
        label: 'Xizmat boshlandi',
        timestamp: arrivedAt,
        isCompleted: arrivedAt != null,
        isActive: arrivedAt != null && completedAt == null,
      ),
      TimelineStage(
        icon: 'check_circle_rounded',
        label: 'Xizmat yakunlandi',
        timestamp: completedAt,
        isCompleted: completedAt != null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < stages.length; i++) ...[
          _TimelineRow(
            stage: stages[i],
            dotSize: dotSize,
            lineWidth: lineWidth,
            isFirst: i == 0,
            isLast: i == stages.length - 1,
            connectorColor: connectorColor ?? context.cPrimary,
          ),
        ],
      ],
    );
  }
}

class TimelineStage {
  const TimelineStage({
    required this.icon,
    required this.label,
    this.timestamp,
    this.isCompleted = false,
    this.isActive = false,
  });

  final String icon;
  final String label;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isActive;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stage,
    required this.dotSize,
    required this.lineWidth,
    required this.isFirst,
    required this.isLast,
    this.connectorColor,
  });

  final TimelineStage stage;
  final double dotSize;
  final double lineWidth;
  final bool isFirst;
  final bool isLast;
  final Color? connectorColor;

  @override
  Widget build(BuildContext context) {
    final primaryColor = connectorColor ?? context.cPrimary;
    final dotColor = stage.isCompleted
        ? primaryColor
        : stage.isActive
            ? context.cWarning
            : context.cTextTertiary.withValues(alpha: 0.3);
    final textColor = stage.isCompleted || stage.isActive
        ? context.cTextPrimary
        : context.cTextTertiary.withValues(alpha: 0.5);
    final iconColor = stage.isCompleted
        ? Colors.white
        : stage.isActive
            ? Colors.white
            : context.cTextTertiary.withValues(alpha: 0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: lineWidth,
                    height: 12,
                    color: stage.isCompleted
                        ? dotColor.withValues(alpha: 0.3)
                        : context.cDivider,
                  )
                else
                  const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: dotSize + 8,
                  height: dotSize + 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: stage.isActive
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppIcon(
                      stage.icon,
                      size: dotSize * 0.55,
                      color: iconColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      color: stage.isCompleted
                          ? dotColor.withValues(alpha: 0.3)
                          : context.cDivider,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: context.spMD),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isFirst ? context.spSM : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.label,
                    style: context.labelLarge(color: textColor).copyWith(
                      fontWeight: stage.isCompleted || stage.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (stage.timestamp != null) ...[
                    SizedBox(height: context.spXXS),
                    Text(
                      _formatTimestamp(stage.timestamp!),
                      style: context.labelSmall(color: context.cTextTertiary),
                    ),
                  ],
                  if (stage.isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: DsBadge(
                        label: 'Jarayonda',
                        variant: DsBadgeVariant.warning,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diff.inDays == 0) return time;
    if (diff.inDays == 1) return 'Kecha $time';
    return '${dt.day}.${dt.month}.${dt.year} $time';
  }
}
