import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';
import 'history_status_badge.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String? ?? 'pending';
    final mechanicName = item['mechanicName'] as String? ?? '--';
    final mechanicAvatar = item['mechanicAvatar'] as String?;
    final type = item['type'] as String? ?? 'Xizmat';
    final date = item['date'] as String? ?? '--';
    final price = item['price'] as String?;
    final rating = (item['rating'] as num?)?.toDouble() ?? 0.0;
    final vehicle = item['vehicle'] as String?;
    final plate = item['plate'] as String?;
    final distance = item['distance'] as String?;
    final duration = item['duration'] as String?;
    final isFavorite = item['isFavorite'] as bool? ?? false;
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';

    return DsCard(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      radius: context.radiusLG,
      shadows: context.shadowSM,
      hasBorder: true,
      borderColor: isCompleted
          ? context.cSuccess.withValues(alpha: 0.15)
          : isCancelled
              ? context.cDanger.withValues(alpha: 0.1)
              : context.cBorder,
      padding: EdgeInsets.all(context.spLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.cFieldFill,
                      border: Border.all(
                        color: isCompleted
                            ? context.cSuccess.withValues(alpha: 0.3)
                            : context.cBorder,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: context.cFieldFill,
                      backgroundImage: mechanicAvatar != null
                          ? NetworkImage(mechanicAvatar)
                          : null,
                      child: mechanicAvatar == null
                          ? AppIcon(
                              'person_rounded',
                              size: 22,
                              color: context.cTextTertiary,
                            )
                          : null,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.cSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const AppIcon(
                          'check_circle_rounded',
                          size: 12,
                          color: DesignTokens.success,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: context.spMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanicName,
                      style: context.headingSmall(color: context.cTextPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.spXXS),
                    Text(
                      type,
                      style: context.bodySmall(color: context.cTextSecondary),
                    ),
                  ],
                ),
              ),
              HistoryStatusBadge(status: status),
            ],
          ),
          if (vehicle != null || plate != null) ...[
            SizedBox(height: context.spSM),
            Row(
              children: [
                if (vehicle != null) ...[
                  AppIcon(
                    'directions_car_filled_rounded',
                    size: 13,
                    color: context.cTextTertiary,
                  ),
                  SizedBox(width: context.spXXS),
                  Text(
                    vehicle,
                    style: context.labelSmall(color: context.cTextSecondary),
                  ),
                ],
                if (plate != null) ...[
                  SizedBox(width: context.spMD),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      plate,
                      style: context.labelSmall(color: context.cTextSecondary).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: context.spSM),
          Row(
            children: [
              AppIcon(
                'calendar_today_outlined',
                size: 12,
                color: context.cTextTertiary,
              ),
              SizedBox(width: context.spXXS),
              Text(
                date,
                style: context.labelSmall(color: context.cTextTertiary),
              ),
              if (duration != null) ...[
                SizedBox(width: context.spMD),
                AppIcon(
                  'timer_outlined',
                  size: 12,
                  color: context.cTextTertiary,
                ),
                SizedBox(width: context.spXXS),
                Text(
                  duration,
                  style: context.labelSmall(color: context.cTextTertiary),
                ),
              ],
              if (distance != null) ...[
                SizedBox(width: context.spMD),
                AppIcon(
                  'my_location_rounded',
                  size: 12,
                  color: context.cTextTertiary,
                ),
                SizedBox(width: context.spXXS),
                Text(
                  distance,
                  style: context.labelSmall(color: context.cTextTertiary),
                ),
              ],
              const Spacer(),
              if (isFavorite)
                const AppIcon(
                  'favorite',
                  size: 14,
                  color: DesignTokens.danger,
                ),
            ],
          ),
          if (rating > 0 || isCompleted) ...[
            SizedBox(height: context.spSM),
            Row(
              children: [
                if (rating > 0)
                  ...List.generate(5, (i) {
                    final filled = rating >= i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: AppIcon(
                        filled ? 'star_rounded' : 'star_border_rounded',
                        size: 13,
                        color: filled
                            ? DesignTokens.star
                            : context.cTextTertiary,
                      ),
                    );
                  }),
                const Spacer(),
                if (price != null && price != '--')
                  Text(
                    price,
                    style: context.headingSmall(color: context.cSuccess),
                  ),
                if (rating == 0 && isCompleted)
                  Text(
                    'Baho bering',
                    style: context.labelLarge(color: context.cPrimary),
                  ),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Batafsil',
                style: context.labelLarge(color: context.cPrimary),
              ),
              SizedBox(width: context.spXXS),
              AppIcon(
                'chevron_right_rounded',
                size: 14,
                color: context.cPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
