import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import 'app_icon.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isMechanic = false,
    this.notifBadge = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isMechanic;
  final int notifBadge;

  @override
  Widget build(BuildContext context) {
    final items = isMechanic
        ? [
            _NavItem(
              icon: 'dashboard_outlined',
              activeIcon: 'dashboard_rounded',
              label: 'Asosiy',
            ),
            _NavItem(
              icon: 'receipt_long_outlined',
              activeIcon: 'receipt_long_rounded',
              label: 'Buyurtmalar',
            ),
            _NavItem(
              icon: 'people_outline_rounded',
              activeIcon: 'people_rounded',
              label: 'Mijozlar',
            ),
            _NavItem(
              icon: 'location_on_outlined',
              activeIcon: 'location_on_rounded',
              label: 'Xarita',
            ),
            _NavItem(
              icon: 'person_outline_rounded',
              activeIcon: 'person_rounded',
              label: 'Profil',
            ),
          ]
        : [
            _NavItem(
              icon: 'home_outlined',
              activeIcon: 'home_rounded',
              label: 'Asosiy',
            ),
            _NavItem(
              icon: 'chat_bubble_outline_rounded',
              activeIcon: 'chat_bubble_rounded',
              label: 'Xabarlar',
            ),
            _NavItem(
              icon: 'engineering_outlined',
              activeIcon: 'engineering_rounded',
              label: 'Ustalar',
            ),
            _NavItem(
              icon: 'location_on_outlined',
              activeIcon: 'location_on_rounded',
              label: 'Xarita',
            ),
            _NavItem(
              icon: 'person_outline_rounded',
              activeIcon: 'person_rounded',
              label: 'Profil',
            ),
          ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: AnimatedContainer(
          duration: DesignTokens.animNormal,
          decoration: BoxDecoration(
            color: context.glassFillStrong,
            border: Border.all(color: context.glassBorder),
          ),
          child: Row(
            children: items.asMap().entries.map((e) {
              final active = e.key == currentIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  label: e.value.label,
                  selected: active,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(e.key),
                  child: AnimatedContainer(
                    duration: DesignTokens.animNormal,
                    curve: DesignTokens.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: DesignTokens.animNormal,
                          curve: DesignTokens.easeOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: active ? 14 : 8,
                            vertical: active ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? DesignTokens.primary.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AnimatedScale(
                            scale: active ? 1.15 : 1.0,
                            duration: DesignTokens.animNormal,
                            curve: DesignTokens.easeOut,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AppIcon(
                                  active ? e.value.activeIcon : e.value.icon,
                                  color: active
                                      ? DesignTokens.primary
                                      : context.cTextTertiary,
                                  size: 24,
                                ),
                                if (e.key == (isMechanic ? 2 : 1) && notifBadge > 0)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: DesignTokens.danger,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          notifBadge > 9 ? '9+' : '$notifBadge',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: DesignTokens.animNormal,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? DesignTokens.primary
                                : context.cTextTertiary,
                            fontFamily: 'Inter',
                          ),
                          child: Text(e.value.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String icon;
  final String activeIcon;
  final String label;
}
