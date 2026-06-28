import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
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
    final l = AppLocalizations.of(context);
    final items = [
      _NavItem(
        icon: isMechanic ? 'dashboard_outlined' : 'home_outlined',
        activeIcon: isMechanic ? 'dashboard_rounded' : 'home_rounded',
        label: l.t('home'),
      ),
      _NavItem(
        icon: 'chat_bubble_outline_rounded',
        activeIcon: 'chat_bubble_rounded',
        label: l.t('messages'),
      ),
      if (isMechanic)
        _NavItem(
          icon: 'history_rounded',
          activeIcon: 'history_rounded',
          label: l.t('history'),
        )
      else
        _NavItem(
          icon: 'engineering_outlined',
          activeIcon: 'engineering_rounded',
          label: l.t('mechanics'),
        ),
      _NavItem(
        icon: 'location_on_outlined',
        activeIcon: 'location_on_rounded',
        label: l.t('map'),
      ),
      _NavItem(
        icon: 'person_outline_rounded',
        activeIcon: 'person_rounded',
        label: l.t('profile'),
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: context.cPrimary.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.glassFillStrong,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: context.glassBorder),
          ),
          child: Builder(
            builder: (context) => Row(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Stack(
                            key: ValueKey('${e.key}_$active'),
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: active
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0x381A56CC),
                                            Color(0x337C5CFC)
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: AppIcon(
                                  active ? e.value.activeIcon : e.value.icon,
                                  color: active
                                      ? context.cPrimary
                                      : context.cTextGray,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                            color:
                                active ? context.cPrimary : context.cTextGray,
                            fontFamily: 'Inter',
                          ),
                          child: Text(e.value.label,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        ],
                      ),
                    ),
                  ),
                  );
                }).toList(),
            ),
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
