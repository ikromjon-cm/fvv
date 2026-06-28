import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/accessibility/accessibility.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/performance/performance.dart';
import '../../core/responsive/responsive.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/searchable_picker.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/plate_picker.dart';
import '../../shared/widgets/ds_dialog.dart';
import '../../shared/widgets/ds_card.dart';
import '../../shared/widgets/ds_badge.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _brands = [];
  Map<String, String> _modelImages = {};

  @override
  void initState() {
    super.initState();
    _load();
    _loadCatalogue();
  }

  Future<void> _load() async {
    try {
      final raw = await ApiService.getVehicles();
      if (mounted) {
        setState(() {
          _items = raw.map((e) => e as Map<String, dynamic>).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError(e);
      }
    }
  }

  Future<void> _loadCatalogue() async {
    try {
      final d = await ApiService.getCarCatalogue();
      if (mounted) {
        final brands = (d['brands'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final images = <String, String>{};
        for (final b in brands) {
          final brandName = b['name'] as String? ?? '';
          final models = b['models'] as List? ?? [];
          for (final m in models) {
            final m2 = m as Map<String, dynamic>;
            final modelName = m2['name'] as String? ?? '';
            final img = m2['image'] as String? ?? '';
            if (modelName.isNotEmpty && img.isNotEmpty) {
              images['$brandName $modelName'] = img;
            }
          }
        }
        setState(() {
          _brands = brands;
          _modelImages = images;
        });
      }
    } catch (_) {}
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(e is ApiException
              ? e.message
              : "Xatolik yuz berdi.")),
    );
  }

  Future<void> _add() async {
    String plateNumber = '';
    final otherModelCtrl = TextEditingController();
    Map<String, dynamic>? brand;
    String? model;
    String? modelImage;
    bool saving = false;

    Widget field(BuildContext ctx,
        {required String hint,
        String? value,
        VoidCallback? onTap,
        bool enabled = true}) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: enabled
                ? ctx.cFieldFill
                : ctx.cBorder.withValues(alpha: 0.4),
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusMD),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium(
                    color: value != null
                        ? context.cTextPrimary
                        : context.cTextTertiary,
                  ),
                ),
              ),
              AppIcon('keyboard_arrow_down_rounded',
                  size: 20, color: context.cTextTertiary),
            ],
          ),
        ),
      );
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final isOther =
              brand != null && brand!['slug'] == 'other';
          final hasCatalogue = _brands.isNotEmpty;
          return Padding(
            padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (ctx, scrollCtrl) => Container(
                padding: const EdgeInsets.fromLTRB(
                    24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: sheetCtx.cSurface,
                  borderRadius:
                      const BorderRadius.vertical(
                          top: Radius.circular(
                              DesignTokens.radius2XL)),
                ),
                child: ListView(
                  controller: scrollCtrl,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sheetCtx.cBorder,
                          borderRadius:
                              BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DesignTokens.primary
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMD),
                          ),
                          child: const AppIcon(
                              'directions_car_rounded',
                              size: 24,
                              color: DesignTokens.primary),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Avtomobil qo\'shish',
                          style: context.headingMedium(color: context.cTextPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _CarPreview(image: modelImage),
                    const SizedBox(height: 24),
                    Text(
                      'Brend',
                      style: context.labelLarge(color: context.cTextSecondary),
                    ),
                    const SizedBox(height: 8),
                    if (hasCatalogue)
                      field(sheetCtx,
                          hint: 'Brendni tanlang',
                          value: brand?['name'] as String?,
                          onTap: () async {
                            final picked =
                                await showSearchablePicker<
                                    Map<String, dynamic>>(
                              context: sheetCtx,
                              title: 'Brend',
                              items: _brands,
                              labelOf: (b) =>
                                  b['name'] as String,
                            );
                            if (picked != null) {
                              setSheetState(() {
                                brand = picked;
                                model = null;
                                modelImage = null;
                              });
                            }
                          })
                    else
                      TextField(
                        controller: otherModelCtrl,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Brend nomi',
                          filled: true,
                          fillColor: sheetCtx.cFieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMD),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    if (hasCatalogue && !isOther) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Model',
                      style: context.labelLarge(color: context.cTextSecondary),
                    ),
                    const SizedBox(height: 8),
                    field(sheetCtx,
                        hint: 'Modelni tanlang',
                        value: model,
                        enabled: brand != null,
                          onTap: () async {
                            final models =
                                (brand!['models'] as List? ??
                                        [])
                                    .map((e) =>
                                        e as Map<String, dynamic>)
                                    .toList();
                            final picked =
                                await showSearchablePicker<
                                    Map<String, dynamic>>(
                              context: sheetCtx,
                              title: 'Model',
                              items: models,
                              labelOf: (m) =>
                                  m['name'] as String,
                              imageOf: (m) =>
                                  (m['image'] as String?) ??
                                  '',
                            );
                            if (picked != null) {
                              setSheetState(() {
                                model =
                                    picked['name'] as String?;
                                final img =
                                    picked['image'] as String?;
                                modelImage =
                                    (img != null && img.isNotEmpty)
                                        ? img
                                        : null;
                              });
                            }
                          }),
                    ],
                    if (isOther) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Model',
                      style: context.labelLarge(color: context.cTextSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                        controller: otherModelCtrl,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Model nomi',
                          filled: true,
                          fillColor: sheetCtx.cFieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMD),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Davlat raqami',
                      style: context.labelLarge(color: context.cTextSecondary),
                    ),
                    const SizedBox(height: 8),
                    PlatePicker(
                        onChanged: (v) => plateNumber = v),
                    const SizedBox(height: 28),
                    AppPrimaryButton(
                      label: 'Saqlash',
                      isLoading: saving,
                      onPressed: () async {
                        final String fullModel;
                        if (!hasCatalogue) {
                          fullModel =
                              otherModelCtrl.text.trim();
                        } else if (isOther) {
                          fullModel =
                              otherModelCtrl.text.trim();
                        } else {
                          if (brand == null || model == null) {
                            return;
                          }
                          fullModel =
                              '${brand!['name']} $model';
                        }
                        if (fullModel.isEmpty) return;
                        setSheetState(() => saving = true);
                        try {
                          await ApiService.addVehicle(
                              fullModel, plateNumber);
                          if (sheetCtx.mounted) {
                            Navigator.pop(sheetCtx, true);
                          }
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (mounted) _showError(e);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (ok == true) await _load();
  }

  void _delete(int id) {
    DsConfirmationSheet.show(
      context,
      icon: 'delete_outline_rounded',
      title: "O'chirish",
      description: "Bu avtomobil butunlay o'chiriladi.",
      confirmLabel: "O'chirish",
      isDestructive: true,
      isConfirmLoading: true,
      onConfirm: () async {
        try {
          await ApiService.deleteVehicle(id);
          if (mounted) {
            Navigator.of(context).pop();
            await _load();
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            _showError(e);
          }
        }
      },
    );
  }

  Future<void> _makeDefault(int id) async {
    try {
      await ApiService.setDefaultVehicle(id);
      await AppStorage.setDefaultVehicleId(id.toString());
      await _load();
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: Text(l.t('myVehicles')),
        backgroundColor: context.cScaffold,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: DesignTokens.primary,
        elevation: 4,
        child: const AppIcon('add', color: Colors.white),
      ),
      body: _loading
          ? _buildSkeleton()
          : _items.isEmpty
              ? _buildEmptyState()
              : _buildVehicleList(),
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(context.screenHorizontal, 16, context.screenHorizontal, 96),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: context.cardGap),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
              border: Border.all(color: context.cBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: context.cFieldFill,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 14, decoration: BoxDecoration(
                        color: context.cFieldFill,
                        borderRadius: BorderRadius.circular(4),
                      )),
                      const SizedBox(height: 8),
                      Container(width: 140, height: 11, decoration: BoxDecoration(
                        color: context.cFieldFill,
                        borderRadius: BorderRadius.circular(4),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const AppIcon('directions_car_rounded',
                  size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Avtomobillar yo\'q',
              style: context.headingMedium(color: context.cTextPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Avtomobil qo\'shib, tez yordam oling',
              style: context.bodyMedium(color: context.cTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Avtomobil qo\'shish',
              onPressed: _add,
              width: 220,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return RefreshIndicator(
      color: context.cPrimary,
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(context.screenHorizontal, 16, context.screenHorizontal, 96),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: context.cardGap),
        itemBuilder: (_, i) => _VehicleCard(
          vehicle: _items[i],
          modelImages: _modelImages,
          onMakeDefault: _makeDefault,
          onDelete: _delete,
        ),
      ),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.modelImages,
    required this.onMakeDefault,
    required this.onDelete,
  });

  final Map<String, dynamic> vehicle;
  final Map<String, String> modelImages;
  final Future<void> Function(int id) onMakeDefault;
  final void Function(int id) onDelete;

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final isDefault = v['is_default'] as bool? ?? false;
    final model = v['model'] as String? ?? '';
    final number = v['number'] as String? ?? '';
    final brand = model.split(' ').first;
    final modelName = model.replaceFirst('$brand ', '');
    final id = v['id'] as int;
    final img = widget.modelImages[model];

    return AppSemantics.listItem(
      label: '$brand $modelName $number',
      child: GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        _ctrl.reverse();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: DsCard(
            radius: context.radiusXL,
            shadows: context.shadowMD,
            hasBorder: true,
            borderColor: isDefault ? context.cPrimary.withValues(alpha: 0.3) : context.cBorder,
            color: context.cCard,
            padding: EdgeInsets.all(context.screenHorizontal),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.radiusMD),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.cFieldFill,
                    ),
                    child: img != null && img.isNotEmpty
                        ? ImagePerformance.network(
                            url: img,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : _CarIconPlaceholder(isDefault: isDefault),
                  ),
                ),
                SizedBox(width: context.spMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        brand,
                        style: context.headingSmall(color: context.cTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (modelName.isNotEmpty) ...[
                        SizedBox(height: context.spXXS + 1),
                        Text(
                          modelName,
                          style: context.labelLarge(color: context.cTextSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (number.isNotEmpty) ...[
                        SizedBox(height: context.spSM - 2),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.spSM + 2, vertical: context.spXXS + 1),
                          decoration: BoxDecoration(
                            color: context.cPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(context.radiusSM),
                          ),
                          child: Text(
                            number,
                            style: context.labelSmall(color: context.cPrimary).copyWith(letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDefault)
                      DsBadge(
                        label: 'Asosiy',
                        variant: DsBadgeVariant.primary,
                        icon: 'check_circle_rounded',
                        fontSize: 10,
                      )
                    else
                      AppSemantics.button(
                        label: 'Asosiy qilish',
                        child: GestureDetector(
                          onTap: () => widget.onMakeDefault(id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: context.cFieldFill,
                              borderRadius: BorderRadius.circular(context.radiusFull),
                            ),
                            child: Text(
                              'Asosiy qilish',
                              style: context.labelSmall(color: context.cTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: context.spSM - 2),
                    AppSemantics.button(
                      label: 'O\'chirish',
                      child: GestureDetector(
                        onTap: () => widget.onDelete(id),
                        child: Container(
                          padding: EdgeInsets.all(context.spSM),
                          decoration: BoxDecoration(
                            color: context.cDanger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(context.radiusSM),
                          ),
                          child: AppIcon('delete_outline',
                              size: 18, color: context.cDanger),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _CarPreview extends StatelessWidget {
  const _CarPreview({this.image});
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignTokens.primary.withValues(alpha: 0.06),
              DesignTokens.primary.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(DesignTokens.radiusLG),
          border: Border.all(
              color: DesignTokens.primary.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: (image != null && image!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: image!,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    const _CarIconPlaceholder(isDefault: false),
                placeholder: (_, __) =>
                    const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2)),
              )
            : const _CarIconPlaceholder(isDefault: false),
      ),
    );
  }
}

class _CarIconPlaceholder extends StatelessWidget {
  const _CarIconPlaceholder({required this.isDefault});
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: isDefault ? DesignTokens.primaryGradient : null,
        color: isDefault ? null : context.cFieldFill,
      ),
      child: AppIcon('directions_car_rounded',
          color: isDefault ? Colors.white : context.cTextTertiary,
          size: 32),
    );
  }
}
