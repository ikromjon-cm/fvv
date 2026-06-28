import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/accessibility/accessibility.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/local/app_storage.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/ds_card.dart';
import '../../../shared/widgets/ds_surface.dart';
import '../../../shared/widgets/searchable_picker.dart';
import '../../../shared/widgets/plate_picker.dart';

class ProfileCreateScreen extends StatefulWidget {
  const ProfileCreateScreen({super.key, required this.role});
  final String role;

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

const Map<String, String> kBrandLogos = {
  'Chevrolet': 'https://img.icons8.com/color/96/chevrolet.png',
  'Kia': 'https://img.icons8.com/color/96/kia.png',
  'Hyundai': 'https://img.icons8.com/color/96/hyundai.png',
  'Toyota': 'https://img.icons8.com/color/96/toyota.png',
  'BMW': 'https://img.icons8.com/color/96/bmw.png',
  'Mercedes-Benz': 'https://img.icons8.com/color/96/mercedes-benz.png',
  'Mercedes': 'https://img.icons8.com/color/96/mercedes-benz.png',
  'BYD': 'https://img.icons8.com/color/96/byd.png',
  'Volkswagen': 'https://img.icons8.com/color/96/volkswagen.png',
  'Nissan': 'https://img.icons8.com/color/96/nissan.png',
  'Chery': 'https://img.icons8.com/color/96/chery.png',
  'Daewoo': 'https://img.icons8.com/color/96/daewoo.png',
  'Lada': 'https://img.icons8.com/color/96/lada.png',
  'Audi': 'https://img.icons8.com/color/96/audi.png',
  'Ford': 'https://img.icons8.com/color/96/ford.png',
  'Honda': 'https://img.icons8.com/color/96/honda.png',
  'Mitsubishi': 'https://img.icons8.com/color/96/mitsubishi.png',
  'Renault': 'https://img.icons8.com/color/96/renault.png',
  'Peugeot': 'https://img.icons8.com/color/96/peugeot.png',
  'Mazda': 'https://img.icons8.com/color/96/mazda.png',
  'Land Rover': 'https://img.icons8.com/color/96/land-rover.png',
};

String _brandLogoUrl(Map<String, dynamic> brand) {
  final name = brand['name'] as String? ?? '';
  if (name.isEmpty) return '';
  final fromApi = (brand['logo'] as String?) ?? (brand['image'] as String?);
  if (fromApi != null && fromApi.isNotEmpty) return fromApi;
  final fromMap = kBrandLogos[name] ?? kBrandLogos[name.toLowerCase()];
  if (fromMap != null) return fromMap;
  for (final entry in kBrandLogos.entries) {
    if (name.toLowerCase().contains(entry.key.toLowerCase()) ||
        entry.key.toLowerCase().contains(name.toLowerCase())) {
      return entry.value;
    }
  }
  return '';
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _carNumberCtrl = TextEditingController();
  final _specialityCtrl = TextEditingController();
  bool _isLoading = false;
  final List<String> _selectedServices = [];

  List<Map<String, dynamic>> _brands = [];
  Map<String, dynamic>? _selectedBrand;
  String? _selectedModel;
  String? _modelImage;

  bool get _isDriver => widget.role == 'driver';

  bool get _isValid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_surnameCtrl.text.trim().isEmpty) return false;
    if (_isDriver) {
      return (_selectedBrand != null && _selectedModel != null) &&
          _carNumberCtrl.text.trim().isNotEmpty;
    }
    return _specialityCtrl.text.trim().isNotEmpty && _selectedServices.isNotEmpty;
  }

  static const _serviceOptions = [
    ('battery', 'Akkumulyator', 'battery_charging_full_rounded'),
    ('tire', 'Shina', 'tire_repair_rounded'),
    ('engine', 'Motor', 'engineering_rounded'),
    ('evacuation', 'Evakuator', 'car_repair_rounded'),
    ('gas', 'Gaz/Shlang', 'water_drop_rounded'),
    ('other', 'Boshqa', 'build_rounded'),
  ];

  @override
  void initState() {
    super.initState();
    if (_isDriver) _loadCatalogue();
  }

  Future<void> _loadCatalogue() async {
    try {
      final d = await ApiService.getCarCatalogue();
      if (mounted) {
        setState(() => _brands =
            (d['brands'] as List? ?? []).map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);
    try {
      if (_isDriver) {
        final modelName = '${_selectedBrand!['name']} $_selectedModel';
        final number = _carNumberCtrl.text.trim();
        await ApiService.updateDriverProfile({
          'name': _nameCtrl.text.trim(),
          'surname': _surnameCtrl.text.trim(),
          'car_model': modelName,
          'car_number': number,
        });
        try {
          await ApiService.addVehicle(modelName, number);
        } catch (_) {}
        await AppStorage.saveUserProfile(
          name: _nameCtrl.text.trim(),
          surname: _surnameCtrl.text.trim(),
          carModel: modelName,
          carNumber: number,
          carImage: _modelImage,
        );
        if (!mounted) return;
        context.go(AppRoutes.home);
      } else {
        await ApiService.updateMechanicProfile({
          'name': _nameCtrl.text.trim(),
          'surname': _surnameCtrl.text.trim(),
          'speciality': _specialityCtrl.text.trim(),
          'services': _selectedServices,
        });
        await AppStorage.saveMechanicProfile(
          name: _nameCtrl.text.trim(),
          surname: _surnameCtrl.text.trim(),
          speciality: _specialityCtrl.text.trim(),
          serviceTypes: _selectedServices,
        );
        if (!mounted) return;
        context.go(AppRoutes.mechanicSetup);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: DesignTokens.danger),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _carNumberCtrl.dispose();
    _specialityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cScaffold,
        title: Text(_isDriver ? 'Haydovchi profili' : 'Mexanik profili',
            style: context.headingSmall(color: context.cTextPrimary)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
        child: ListenableBuilder(
          listenable: Listenable.merge([_nameCtrl, _surnameCtrl, _carNumberCtrl, _specialityCtrl]),
          builder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.cardGap + context.spSM),
              Center(
                child: Stack(
                  children: [
                    AppSemantics.image(
                      label: 'Profil rasmi',
                      child: Container(
                        width: 104, height: 104,
                        decoration: BoxDecoration(
                          color: context.cFieldFill,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.cBorder, width: 2),
                        ),
                        child: AppIcon('person', size: 52, color: context.cTextTertiary),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Semantics(
                        button: true,
                        label: 'Rasm yuklash',
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: context.gPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.cPrimary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]),
                          child: const AppIcon('camera_alt', color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.spXL + context.spSM),
              DsSurface(
                padding: EdgeInsets.all(context.spLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Shaxsiy ma'lumotlar"),
                    SizedBox(height: context.cardGap),
                    _field('Ism *', _nameCtrl, hint: 'Akmal', textCapitalization: TextCapitalization.sentences),
                    SizedBox(height: context.cardGap),
                    _field('Familiya *', _surnameCtrl, hint: 'Karimov', textCapitalization: TextCapitalization.sentences),
                  ],
                ),
              ),
              SizedBox(height: context.cardGap),
              if (_isDriver) ...[
                DsSurface(
                  padding: EdgeInsets.all(context.spLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Avtomobil ma'lumotlari"),
                      SizedBox(height: context.cardGap),
                      _buildBrandPicker(),
                      SizedBox(height: context.cardGap),
                      if (_selectedBrand != null && _selectedBrand!['slug'] != 'other')
                        _buildModelPicker(),
                      SizedBox(height: context.cardGap),
                      PlatePicker(
                        initialValue: _carNumberCtrl.text.isNotEmpty ? _carNumberCtrl.text : null,
                        onChanged: (v) => _carNumberCtrl.text = v,
                      ),
                      if (_modelImage != null) ...[
                        SizedBox(height: context.cardGap),
                        _CarPreview(image: _modelImage),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                DsSurface(
                  padding: EdgeInsets.all(context.spLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Kasb ma\'lumotlari'),
                      SizedBox(height: context.cardGap),
                      _field('Mutaxassislik *', _specialityCtrl,
                          hint: 'Masalan: elektrik usta, shinachi, universal'),
                    ],
                  ),
                ),
                SizedBox(height: context.cardGap),
                DsSurface(
                  padding: EdgeInsets.all(context.spLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Xizmat turlari * (kamida 1 ta)'),
                      SizedBox(height: context.cardGap - context.spSM),
                      _serviceChips(),
                    ],
                  ),
                ),
              ],
              SizedBox(height: context.spXL + context.spSM),
              AppPrimaryButton(
                label: _isDriver ? 'Boshlash' : 'Davom etish',
                onPressed: _isValid ? _save : null,
                isLoading: _isLoading,
                trailingIcon: _isDriver ? null : 'arrow_forward_rounded',
              ),
              SizedBox(height: context.sp4XL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPicker() {
    final l = AppLocalizations.of(context);
    if (_brands.isEmpty) {
      return _field(l.t('carBrand'), TextEditingController(), hint: '...');
    }
    return _pickerField(
      label: l.t('carBrand'),
      value: _selectedBrand?['name'] as String?,
      onTap: () async {
        final picked = await showSearchablePicker<Map<String, dynamic>>(
          context: context,
          title: l.t('carBrand'),
          items: _brands,
          labelOf: (b) => b['name'] as String,
          imageOf: (b) => _brandLogoUrl(b),
        );
        if (picked != null) {
          setState(() {
            _selectedBrand = picked;
            _selectedModel = null;
            _modelImage = null;
          });
        }
      },
    );
  }

  Widget _buildModelPicker() {
    final l = AppLocalizations.of(context);
    final models = (_selectedBrand!['models'] as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    return _pickerField(
      label: l.t('carModel'),
      value: _selectedModel,
      onTap: () async {
        final picked = await showSearchablePicker<Map<String, dynamic>>(
          context: context,
          title: l.t('carModel'),
          items: models,
          labelOf: (m) => m['name'] as String,
          imageOf: (m) => (m['image'] as String?) ?? '',
        );
        if (picked != null) {
          setState(() {
            _selectedModel = picked['name'] as String?;
            final img = picked['image'] as String?;
            _modelImage = (img != null && img.isNotEmpty) ? img : null;
          });
        }
      },
    );
  }

  Widget _pickerField({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.labelLarge(color: context.cTextPrimary)),
        SizedBox(height: context.spXS),
        Semantics(
          button: true,
          label: '$label: ${value ?? "Tanlang..."}',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.cardGap + context.spXXS, vertical: 15),
              decoration: BoxDecoration(
                color: context.cFieldFill,
                borderRadius: BorderRadius.circular(context.radiusMD),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? 'Tanlang...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium(color: value != null ? context.cTextPrimary : context.cTextTertiary),
                    ),
                  ),
                  AppIcon('keyboard_arrow_down_rounded', color: context.cTextTertiary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: EdgeInsets.only(bottom: context.spXS),
    child: Text(t,
        style: context.headingSmall(color: context.cTextPrimary)),
  );

  Widget _field(String label, TextEditingController ctrl, {String hint = '', TextCapitalization textCapitalization = TextCapitalization.none}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.labelLarge(color: context.cTextPrimary)),
        SizedBox(height: context.spXS),
        TextField(
          controller: ctrl,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: context.cFieldFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radiusMD),
                borderSide: BorderSide(color: context.cPrimary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _serviceChips() {
    return Wrap(
      spacing: context.spSM,
      runSpacing: context.cardGap - context.spXXS,
      children: _serviceOptions.map((s) {
        final selected = _selectedServices.contains(s.$1);
        return Semantics(
          button: true,
          label: '${s.$2}${selected ? " (tanlangan)" : ""}',
          selected: selected,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedServices.remove(s.$1);
                } else {
                  _selectedServices.add(s.$1);
                }
              });
            },
            child: AnimatedContainer(
              duration: DesignTokens.animationFast,
              padding: EdgeInsets.symmetric(
                  horizontal: context.cardGap + context.spXXS,
                  vertical: context.cardGap - context.spXXS),
              decoration: BoxDecoration(
                color: selected ? context.cPrimary.withValues(alpha: 0.1) : context.cSurface,
                borderRadius: BorderRadius.circular(context.radiusLG),
                border: Border.all(
                  color: selected ? context.cPrimary : context.cBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.$3, style: context.headingSmall(color: context.cTextPrimary)),
                  SizedBox(width: context.spXS),
                  Text(s.$2,
                      style: context.bodyMedium(
                        color: selected ? context.cPrimary : context.cTextPrimary,
                      ).copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CarPreview extends StatelessWidget {
  const _CarPreview({this.image});
  final String? image;

  @override
  Widget build(BuildContext context) {
    return DsGradientCard(
      gradient: LinearGradient(
        colors: [
          context.cPrimary.withValues(alpha: 0.12),
          context.cPrimary.withValues(alpha: 0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      height: 100,
      showArrow: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.radiusLG),
        child: image != null && image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: image!,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const _Placeholder(),
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => Center(
        child: AppIcon('directions_car_rounded',
            size: 48, color: context.cPrimary.withValues(alpha: 0.55)),
      );
}
