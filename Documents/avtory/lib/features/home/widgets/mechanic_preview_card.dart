import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/components/cards/app_cards.dart';

enum MechanicStatus { online, offline, busy, arriving, unavailable }

class MechanicPreviewCard extends StatefulWidget {
  const MechanicPreviewCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.rating,
    this.reviewCount,
    this.distance,
    this.primaryService,
    this.arrivalTime,
    this.isVerified = false,
    this.isFavorite = false,
    this.isPremium = false,
    this.status = MechanicStatus.online,
    this.onCall,
    this.onFavorite,
    this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final double? rating;
  final int? reviewCount;
  final String? distance;
  final String? primaryService;
  final String? arrivalTime;
  final bool isVerified;
  final bool isFavorite;
  final bool isPremium;
  final MechanicStatus status;
  final VoidCallback? onCall;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  @override
  State<MechanicPreviewCard> createState() => _MechanicPreviewCardState();
}

class _MechanicPreviewCardState extends State<MechanicPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favCtrl;
  late Animation<double> _favScale;

  @override
  void initState() {
    super.initState();
    _favCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _favCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case MechanicStatus.online:
        return const Color(0xFF10B981);
      case MechanicStatus.offline:
        return const Color(0xFF94A3B8);
      case MechanicStatus.busy:
        return const Color(0xFFF59E0B);
      case MechanicStatus.arriving:
        return const Color(0xFF3B82F6);
      case MechanicStatus.unavailable:
        return const Color(0xFFEF4444);
    }
  }

  String get _statusLabel {
    switch (widget.status) {
      case MechanicStatus.online:
        return 'Online';
      case MechanicStatus.offline:
        return 'Offline';
      case MechanicStatus.busy:
        return 'Band';
      case MechanicStatus.arriving:
        return 'Kelmoqda';
      case MechanicStatus.unavailable:
        return 'Mavjud emas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnavailable = widget.status == MechanicStatus.unavailable;

    return GestureDetector(
      onTap: isUnavailable ? null : widget.onTap,
      child: AppCard(
        width: 210,
        padding: const EdgeInsets.all(14),
        radius: context.radiusLG,
        shadows: context.shadowSM,
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
                        border: Border.all(
                          color: widget.isVerified
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0),
                          width: widget.isVerified ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: widget.avatarUrl != null
                            ? Image.network(
                                widget.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarFallback(),
                              )
                            : _buildAvatarFallback(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isVerified)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: const AppIcon('verified',
                              size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onFavorite != null) {
                      widget.onFavorite!();
                    }
                    _favCtrl.forward().then((_) => _favCtrl.reverse());
                  },
                  child: AnimatedBuilder(
                    animation: _favScale,
                    builder: (_, __) {
                      return Transform.scale(
                        scale: _favCtrl.isAnimating
                            ? _favScale.value
                            : 1.0,
                        child: AppIcon(
                          widget.isFavorite
                              ? 'favorite'
                              : 'favorite_border',
                          size: 20,
                          color: widget.isFavorite
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF94A3B8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: context.bodyMedium(color: context.cTextPrimary)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
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
            ),
            if (widget.rating != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const AppIcon('star_rounded',
                      size: 14, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating!.toStringAsFixed(1),
                    style: context.labelLarge(color: context.cTextPrimary),
                  ),
                  if (widget.reviewCount != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.reviewCount})',
                      style: context.bodySmall(color: context.cTextTertiary),
                    ),
                  ],
                ],
              ),
            ],
            const Spacer(),
            Row(
              children: [
                if (widget.distance != null) ...[
                  const AppIcon('location_on',
                      size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text(
                    widget.distance!,
                    style: context.bodySmall(color: context.cTextTertiary),
                  ),
                ],
                const Spacer(),
                if (widget.arrivalTime != null) ...[
                  const AppIcon('access_time',
                      size: 11, color: Color(0xFF10B981)),
                  const SizedBox(width: 3),
                  Text(
                    widget.arrivalTime!,
                    style: context.bodySmall(color: const Color(0xFF10B981))
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            if (widget.onCall != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: isUnavailable ? null : widget.onCall,
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: isUnavailable
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1A56CC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon('phone_outlined',
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Qongiroq',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFEEF2FF),
      child: Center(
        child: Text(
          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'M',
          style: context.headingMedium(color: context.cPrimary),
        ),
      ),
    );
  }
}
