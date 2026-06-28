import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import 'app_icon.dart';
import 'ds_chip.dart';

class DsFilterOption {
  const DsFilterOption({
    required this.value,
    required this.label,
    this.icon,
    this.selected = false,
  });

  final String value;
  final String label;
  final String? icon;
  final bool selected;
}

class DsFilterSection {
  const DsFilterSection({
    required this.label,
    required this.options,
    this.multiSelect = false,
  });

  final String label;
  final List<DsFilterOption> options;
  final bool multiSelect;
}

class DsFilterSheet extends StatelessWidget {
  const DsFilterSheet({
    super.key,
    required this.title,
    required this.sections,
    this.onApply,
    this.onClear,
  });

  final String title;
  final List<DsFilterSection> sections;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  static Future<List<DsFilterSection>?> show(
    BuildContext context, {
    required String title,
    required List<DsFilterSection> sections,
    VoidCallback? onApply,
    VoidCallback? onClear,
  }) {
    return showModalBottomSheet<List<DsFilterSection>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DsFilterSheet(
        title: title,
        sections: sections,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedValues = <String>{};
    for (final section in sections) {
      for (final option in section.options) {
        if (option.selected) {
          selectedValues.add(option.value);
        }
      }
    }

    List<DsFilterSection> buildResult() {
      return sections.map((section) {
        return DsFilterSection(
          label: section.label,
          options: section.options.map((option) {
            return DsFilterOption(
              value: option.value,
              label: option.label,
              icon: option.icon,
              selected: selectedValues.contains(option.value),
            );
          }).toList(),
          multiSelect: section.multiSelect,
        );
      }).toList();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radius2XL)),
      ),
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          void onChipTap(DsFilterSection section, DsFilterOption option) {
            setInnerState(() {
              if (section.multiSelect) {
                if (selectedValues.contains(option.value)) {
                  selectedValues.remove(option.value);
                } else {
                  selectedValues.add(option.value);
                }
              } else {
                for (final o in section.options) {
                  selectedValues.remove(o.value);
                }
                selectedValues.add(option.value);
              }
            });
          }

          void handleClear() {
            setInnerState(() {
              selectedValues.clear();
            });
            onClear?.call();
          }

          void handleApply() {
            onApply?.call();
            Navigator.of(context).pop(buildResult());
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.spLG, context.spLG, context.spLG, 0),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Yopish',
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.cFieldFill,
                            borderRadius:
                                BorderRadius.circular(context.radiusMD),
                          ),
                          child: AppIcon('close_rounded',
                              size: 20, color: context.cTextSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: context.spMD),
                    Expanded(
                      child: Text(
                        title,
                        style:
                            context.headingSmall(color: context.cTextPrimary),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Filtrlarni tozalash',
                      child: GestureDetector(
                        onTap: handleClear,
                        child: Text(
                          'Tozalash',
                          style: context.labelLarge(color: context.cPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (sections.isNotEmpty)
                Flexible(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(context.spLG, context.spXL,
                        context.spLG, context.spMD),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: sections.map((section) {
                      return Semantics(
                        container: true,
                        label: section.label,
                        child: Padding(
                          padding: EdgeInsets.only(top: context.spLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                section.label,
                                style: context.titleMedium(
                                    color: context.cTextPrimary),
                              ),
                              SizedBox(height: context.spSM),
                              Wrap(
                                spacing: context.spSM,
                                runSpacing: context.spXS,
                                children: section.options.map((option) {
                                  final isSelected =
                                      selectedValues.contains(option.value);
                                  return DsChip(
                                    label: option.label,
                                    isSelected: isSelected,
                                    icon: option.icon,
                                    onTap: () =>
                                        onChipTap(section, option),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(context.spLG, 0, context.spLG,
                    MediaQuery.of(context).padding.bottom + context.spSM),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: handleApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.cPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Amalda qilish',
                      style: context
                          .labelLarge(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }
}
