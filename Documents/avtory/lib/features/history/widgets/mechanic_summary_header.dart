import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';
import '../../../shared/widgets/ds_badge.dart';

class MechanicSummaryHeader extends StatelessWidget {
  const MechanicSummaryHeader({
    super.key,
    this.avatarUrl,
    this.name = '--',
    this.rating = 0,
    this.experienceYears = 0,
    this.workshop = '',
    this.distanceKm,
    this.etaMinutes,
    this.isVerified = false,
    this.isPremiumPartner = false,
    this.onCall,
    this.onChat,
    this.onViewProfile,
  });

  final String? avatarUrl;
  final String name;
  final double rating;
  final int experienceYears;
  final String workshop;
  final double? distanceKm;
  final int? etaMinutes;
  final bool isVerified;
  final bool isPremiumPartner;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      radius: context.radiusLG,
      shadows: context.shadowSM,
      hasBorder: true,
      padding: EdgeInsets.all(context.spLG),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isVerified
                          ? context.gPrimary
                          : null,
                      border: isVerified
                          ? Border.all(color: Colors.transparent, width: 2)
                          : Border.all(
                              color: context.cBorder,
                              width: 1,
                            ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: context.cFieldFill,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: avatarUrl == null
                          ? AppIcon(
                              'person_rounded',
                              size: 28,
                              color: context.cTextTertiary,
                            )
                          : null,
                    ),
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.cSurface,
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(
                          'verified_rounded',
                          size: 14,
                          color: context.cVerified,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: context.headingSmall(color: context.cTextPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPremiumPartner) ...[
                          SizedBox(width: context.spSM - 2),
                          DsBadge(
                            label: 'PREMIUM',
                            variant: DsBadgeVariant.primary,
                            fontSize: 8,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: context.spXS),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final filled = rating >= i + 1;
                          final half = !filled && rating > i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 1),
                            child: AppIcon(
                              half
                                  ? 'star_half_rounded'
                                  : filled
                                      ? 'star_rounded'
                                      : 'star_border_rounded',
                              size: 12,
                              color: filled || half
                                  ? DesignTokens.star
                                  : context.cTextTertiary,
                            ),
                          );
                        }),
                        SizedBox(width: context.spXS),
                        Text(
                          rating.toStringAsFixed(1),
                          style: context.labelSmall(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (workshop.isNotEmpty || experienceYears > 0 || distanceKm != null) ...[
            SizedBox(height: context.spMD),
            Row(
              children: [
                if (workshop.isNotEmpty) ...[
                  AppIcon(
                    'store_outlined',
                    size: 13,
                    color: context.cTextTertiary,
                  ),
                  SizedBox(width: context.spXXS + 2),
                  Flexible(
                    child: Text(
                      workshop,
                      style: context.labelSmall(color: context.cTextSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: context.spMD),
                ],
                if (experienceYears > 0) ...[
                  AppIcon(
                    'work_outline',
                    size: 13,
                    color: context.cTextTertiary,
                  ),
                  SizedBox(width: context.spXXS + 2),
                  Text(
                    '$experienceYears yil',
                    style: context.labelSmall(color: context.cTextSecondary),
                  ),
                ],
                if (distanceKm != null) ...[
                  const Spacer(),
                  AppIcon(
                    'my_location_rounded',
                    size: 13,
                    color: context.cTextTertiary,
                  ),
                  SizedBox(width: context.spXXS + 2),
                  Text(
                    '${distanceKm!.toStringAsFixed(1)} km',
                    style: context.labelSmall(color: context.cTextSecondary),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: context.spMD),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: 'phone_outlined',
                  label: "Qo'ng'iroq",
                  onTap: onCall,
                ),
              ),
              SizedBox(width: context.spSM),
              Expanded(
                child: _ActionButton(
                  icon: 'chat_outlined',
                  label: 'Xabar',
                  onTap: onChat,
                ),
              ),
              if (onViewProfile != null) ...[
                SizedBox(width: context.spSM),
                Expanded(
                  child: _ActionButton(
                    icon: 'person_outline_rounded',
                    label: 'Profil',
                    onTap: onViewProfile,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.spSM),
        decoration: BoxDecoration(
          color: context.cFieldFill,
          borderRadius: BorderRadius.circular(context.radiusMD),
          border: Border.all(color: context.cBorder),
        ),
        child: Column(
          children: [
            AppIcon(icon, size: 18, color: context.cTextSecondary),
            SizedBox(height: context.spXXS),
            Text(
              label,
              style: context.labelSmall(color: context.cTextSecondary).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
