import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/problem_icons.dart';
import '../../../data/models/problem_category.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';

class MechanicServicesScreen extends StatefulWidget {
  const MechanicServicesScreen({super.key, this.isSetup = false});
  final bool isSetup;

  @override
  State<MechanicServicesScreen> createState() => _MechanicServicesScreenState();
}

class _MechanicServicesScreenState extends State<MechanicServicesScreen> {
  bool _loading = true;
  bool _saving = false;
  List<ProblemCategory> _categories = [];
  List<ProblemGroup> _groups = [];
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cat = await ApiService.getProblemCategories();
      final mine = await ApiService.getMechanicServices();
      if (!mounted) return;
      setState(() {
        _categories = (cat['categories'] as List? ?? [])
            .map((e) => ProblemCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        _groups = (cat['groups'] as List? ?? [])
            .map((e) => ProblemGroup.fromJson(e as Map<String, dynamic>))
            .toList();
        _selected
          ..clear()
          ..addAll((mine['services'] as List? ?? []).map((e) => e.toString()));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).t('pickAtLeastOne')),
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.saveMechanicServices(_selected.toList());
      if (!mounted) return;
      if (widget.isSetup) {
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Saqlandi'), backgroundColor: context.cSuccess));
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.locale.languageCode;
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cSurface,
        title: Text(l.t('myServices')),
        leading: widget.isSetup
            ? null
            : IconButton(
                icon: AppIcon('arrow_back_ios_new', size: 20),
                onPressed: () => context.pop()),
        automaticallyImplyLeading: !widget.isSetup,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: context.cPrimary.withValues(alpha: 0.06),
                  padding: EdgeInsets.all(context.spMD),
                  child: Row(
                    children: [
                      AppIcon('info_outline',
                          color: context.cPrimary, size: 18),
                      SizedBox(width: context.spSM),
                      Expanded(
                        child: Text(l.t('pickServicesHint'),
                            style: context.bodySmall(color: context.cPrimary)),
                      ),
                      Text('${_selected.length}',
                          style: context.titleMedium(color: context.cPrimary)
                              .copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(context.spMD, context.spSM, context.spMD, context.sp2XL),
                    children: [
                      for (final g in _groups) ..._groupSection(g, locale),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(context.spMD, 0, context.spMD, context.sp3XL),
                  child: AppPrimaryButton(
                    label: widget.isSetup ? 'Keyingisi' : l.t('save'),
                    isLoading: _saving,
                    onPressed: _save,
                    trailingIcon: widget.isSetup ? 'arrow_forward_rounded' : null,
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _groupSection(ProblemGroup g, String locale) {
    final items = _categories.where((c) => c.group == g.slug).toList();
    if (items.isEmpty) return const [];
    final color = problemColor(g.slug);
    return [
      Padding(
        padding: EdgeInsets.fromLTRB(context.spXXS, context.spLG, context.spXXS, context.spSM),
        child: Text(g.name(locale),
            style: context.titleMedium(color: color)
                .copyWith(fontWeight: FontWeight.w700)),
      ),
      Wrap(
        spacing: context.spSM,
        runSpacing: context.spSM,
        children: items.map((c) {
          final on = _selected.contains(c.slug);
          return FilterChip(
            selected: on,
            showCheckmark: false,
            avatar: AppIcon(problemIcon(c.icon),
                size: 18, color: on ? Colors.white : color),
            label: Text(c.name(locale)),
            labelStyle: context.labelLarge(color: on ? Colors.white : context.cTextPrimary)
                .copyWith(fontWeight: on ? FontWeight.w600 : FontWeight.w500),
            backgroundColor: context.cSurface,
            selectedColor: color,
            side: BorderSide(
                color: on ? color : context.cBorder, width: on ? 0 : 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radiusMD)),
            onSelected: (v) => setState(() {
              if (v) {
                _selected.add(c.slug);
              } else {
                _selected.remove(c.slug);
              }
            }),
          );
        }).toList(),
      ),
    ];
  }
}
