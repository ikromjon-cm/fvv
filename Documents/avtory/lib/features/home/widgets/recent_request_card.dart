import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/components/cards/app_cards.dart';

enum RequestStatus { pending, accepted, driving, working, completed, cancelled }

class RecentRequestCard extends StatelessWidget {
  const RecentRequestCard({
    super.key,
    required this.problemType,
    this.mechanicName,
    required this.status,
    this.time,
    this.date,
    this.onTap,
  });

  final String problemType;
  final String? mechanicName;
  final RequestStatus status;
  final String? time;
  final String? date;
  final VoidCallback? onTap;

  Color get _statusColor {
    switch (status) {
      case RequestStatus.pending:
        return const Color(0xFFF59E0B);
      case RequestStatus.accepted:
        return const Color(0xFF3B82F6);
      case RequestStatus.driving:
        return const Color(0xFF8B5CF6);
      case RequestStatus.working:
        return const Color(0xFF1A56CC);
      case RequestStatus.completed:
        return const Color(0xFF10B981);
      case RequestStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String get _statusLabel {
    switch (status) {
      case RequestStatus.pending:
        return 'Kutilmoqda';
      case RequestStatus.accepted:
        return 'Qabul qilindi';
      case RequestStatus.driving:
        return 'Kelmoqda';
      case RequestStatus.working:
        return 'Ishlamoqda';
      case RequestStatus.completed:
        return 'Yakunlandi';
      case RequestStatus.cancelled:
        return 'Bekor qilindi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        radius: context.radiusMD,
        shadows: context.shadowSM,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildStatusIcon(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problemType,
                    style: context.bodyMedium(color: context.cTextPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mechanicName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      mechanicName!,
                      style: context.bodySmall(color: context.cTextTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (time != null || date != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (time != null) ...[
                          const AppIcon('access_time',
                              size: 10, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 3),
                          Text(
                            time!,
                            style: context.bodySmall(color: context.cTextTertiary),
                          ),
                        ],
                        if (date != null) ...[
                          if (time != null) const SizedBox(width: 8),
                          Text(
                            date!,
                            style: context.bodySmall(color: context.cTextTertiary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const AppIcon('chevron_right',
                    size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case RequestStatus.pending:
        return const AppIcon('more_horiz',
            size: 20, color: Color(0xFFF59E0B));
      case RequestStatus.accepted:
        return const AppIcon('check_circle_outline',
            size: 20, color: Color(0xFF3B82F6));
      case RequestStatus.driving:
        return const AppIcon('near_me_rounded',
            size: 20, color: Color(0xFF8B5CF6));
      case RequestStatus.working:
        return const AppIcon('engineering_rounded',
            size: 20, color: Color(0xFF1A56CC));
      case RequestStatus.completed:
        return const AppIcon('check_circle',
            size: 20, color: Color(0xFF10B981));
      case RequestStatus.cancelled:
        return const AppIcon('close',
            size: 20, color: Color(0xFFEF4444));
    }
  }
}
