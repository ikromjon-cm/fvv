import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';

class _ProblemItem {
  const _ProblemItem(this.slug, this.name, this.description, this.icon, this.color);
  final String slug;
  final String name;
  final String description;
  final String icon;
  final Color color;
}

class ProblemTypeScreen extends StatefulWidget {
  const ProblemTypeScreen({super.key});

  @override
  State<ProblemTypeScreen> createState() => _ProblemTypeScreenState();
}

class _ProblemTypeScreenState extends State<ProblemTypeScreen> {
  String? _selected;
  final _items = const [
    _ProblemItem('battery', 'Akkumulyator', 'Akkumulyator zaryadsiz yoki ishlamayapti', 'battery_charging_full_rounded', Color(0xFF3B82F6)),
    _ProblemItem('tire', "Shina yo'ildi", 'Shina teshilgan yoki yo\'ilgan', 'tire_repair_rounded', Color(0xFF10B981)),
    _ProblemItem('engine', 'Motor muammosi', "Dvigatel bilan bog'liq muammo", 'engineering_rounded', Color(0xFFF59E0B)),
    _ProblemItem('evacuation', 'Evakuator', 'Mashina tortib ketish kerak', 'car_repair_rounded', Color(0xFFEF4444)),
    _ProblemItem('gas', 'Gaz/Shlang', 'Gaz yoki shlang bilan bog\'liq muammo', 'water_drop_rounded', Color(0xFF8B5CF6)),
    _ProblemItem('other', 'Boshqa', 'Boshqa turdagi muammolar', 'more_horiz_rounded', Color(0xFF6B7280)),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: Text(l.t('selectProblem')),
        backgroundColor: context.cSurface,
        leading: IconButton(
          icon: AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingLG, DesignTokens.spacingMD, DesignTokens.spacingLG, 0),
            child: Text(
              'Qanday muammo yuz berdi?',
              style: AppTextStyles.h2.copyWith(color: context.cTextPrimary),
            ),
          ),
          SizedBox(height: DesignTokens.spacingSM),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMD),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProblemTile(
                item: _items[i],
                isSelected: _selected == _items[i].slug,
                onTap: () => setState(() => _selected = _items[i].slug),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingMD, 0, DesignTokens.spacingMD, 32),
            child: AppPrimaryButton(
              label: _selected != null ? 'Mexanik topish' : l.t('next'),
              onPressed: _selected != null
                  ? () => context.push('${AppRoutes.nearbyMechanics}?type=$_selected')
                  : null,
              trailingIcon: _selected != null ? 'search_rounded' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemTile extends StatelessWidget {
  const _ProblemTile({required this.item, required this.isSelected, required this.onTap});
  final _ProblemItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withValues(alpha: 0.06) : context.cSurface,
          border: Border.all(
            color: isSelected ? item.color : context.cBorder,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [BoxShadow(color: item.color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [item.color, item.color.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isSelected ? null : context.cFieldFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(
                item.icon,
                color: isSelected ? Colors.white : item.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? item.color : context.cTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTextStyles.caption.copyWith(color: context.cTextSecondary),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? item.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? item.color : context.cBorder,
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? const AppIcon('check_rounded', color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
