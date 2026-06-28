import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/components/cards/app_cards.dart';
import '../../../core/utils/phone.dart';

class AssignedMechanicCard extends StatelessWidget {
  const AssignedMechanicCard({
    super.key,
    required this.name,
    this.photoUrl,
    this.rating,
    this.reviewCount,
    this.primaryService,
    this.distance,
    this.isVerified = false,
    this.isOnline = false,
    this.workshopName,
    this.phoneNumber,
    this.onChat,
    this.onViewProfile,
  });

  final String name;
  final String? photoUrl;
  final double? rating;
  final int? reviewCount;
  final String? primaryService;
  final String? distance;
  final bool isVerified;
  final bool isOnline;
  final String? workshopName;
  final String? phoneNumber;
  final VoidCallback? onChat;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: context.radiusLG,
      shadows: context.shadowSM,
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isVerified
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallback())
                          : _buildFallback(),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  if (isVerified)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const AppIcon('verified',
                            size: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: context.bodyLarge(color: context.cTextPrimary)
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (workshopName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        workshopName!,
                        style: context.bodySmall(color: context.cTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const AppIcon('star_rounded',
                              size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: context.labelLarge(color: context.cTextPrimary),
                          ),
                          if (reviewCount != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($reviewCount)',
                              style: context.bodySmall(color: context.cTextTertiary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (primaryService != null)
                _buildInfoChip(
                    Icons.build_rounded, primaryService!),
              if (primaryService != null && distance != null)
                const SizedBox(width: 8),
              if (distance != null)
                _buildInfoChip(
                    Icons.location_on, distance!),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (phoneNumber != null) dialPhone(phoneNumber!);
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A56CC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon('phone_outlined',
                              size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Qo\'ng\'iroq',
                            style: TextStyle(
                              fontSize: 13,
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
              ),
              if (onChat != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onChat,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A56CC).withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon('chat_bubble_outline',
                                size: 16, color: Color(0xFF1A56CC)),
                            SizedBox(width: 6),
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF1A56CC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (onViewProfile != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onViewProfile,
              child: const Text(
                'Profilni ko\'rish',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Color(0xFF1A56CC),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Inter',
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFEEF2FF),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: Color(0xFF1A56CC),
          ),
        ),
      ),
    );
  }
}
