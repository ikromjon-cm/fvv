import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/design_tokens.dart';
import '../../data/local/app_storage.dart';
import '../../services/api_service.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/app_icon.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _carModelCtrl = TextEditingController();
  final _carNumberCtrl = TextEditingController();
  final _specialityCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDriver = true;
  String _phone = '';
  List<String> _selectedServices = [];
  int _experience = 1;

  static const _serviceOptions = [
    ('battery', 'Akkumulyator'),
    ('tire', 'Shina'),
    ('engine', 'Motor/Dvigatel'),
    ('evacuation', 'Evakuator'),
    ('gas', 'Gaz/Shlang'),
    ('other', 'Boshqa'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final role = await AppStorage.getRole() ?? 'driver';
    _isDriver = role == 'driver';
    _phone = await AppStorage.getPhone() ?? '';

    try {
      if (_isDriver) {
        final data = await ApiService.getDriverProfile();
        _nameCtrl.text = data['name'] as String? ?? '';
        _surnameCtrl.text = data['surname'] as String? ?? '';
        _carModelCtrl.text = data['car_model'] as String? ?? '';
        _carNumberCtrl.text = data['car_number'] as String? ?? '';
        _phone = data['phone'] as String? ?? _phone;
      } else {
        final data = await ApiService.getMechanicProfile();
        _nameCtrl.text = data['name'] as String? ?? '';
        _surnameCtrl.text = data['surname'] as String? ?? '';
        _specialityCtrl.text = data['speciality'] as String? ?? '';
        _phone = data['phone'] as String? ?? _phone;
        _selectedServices = List<String>.from(data['services'] as List? ?? []);
        _experience = data['experience_years'] as int? ?? 1;
      }
    } catch (_) {
      if (_isDriver) {
        final profile = await AppStorage.getUserProfile();
        _nameCtrl.text = profile['name'] ?? '';
        _surnameCtrl.text = profile['surname'] ?? '';
        _carModelCtrl.text = profile['carModel'] ?? '';
        _carNumberCtrl.text = profile['carNumber'] ?? '';
      } else {
        final profile = await AppStorage.getMechanicProfile();
        _nameCtrl.text = profile['name'] as String? ?? '';
        _surnameCtrl.text = profile['surname'] as String? ?? '';
        _specialityCtrl.text = profile['speciality'] as String? ?? '';
        _selectedServices = List<String>.from(profile['services'] as List? ?? []);
        _experience = profile['experience'] as int? ?? 1;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      if (_isDriver) {
        await ApiService.updateDriverProfile({
          'name': _nameCtrl.text.trim(),
          'surname': _surnameCtrl.text.trim(),
          'car_model': _carModelCtrl.text.trim(),
          'car_number': _carNumberCtrl.text.trim(),
        });
        await AppStorage.saveUserProfile(
          name: _nameCtrl.text.trim(),
          surname: _surnameCtrl.text.trim(),
          carModel: _carModelCtrl.text.trim(),
          carNumber: _carNumberCtrl.text.trim(),
        );
      } else {
        await ApiService.updateMechanicProfile({
          'name': _nameCtrl.text.trim(),
          'surname': _surnameCtrl.text.trim(),
          'speciality': _specialityCtrl.text.trim(),
          'services': _selectedServices,
          'experience_years': _experience,
        });
        await AppStorage.saveMechanicProfile(
          name: _nameCtrl.text.trim(),
          surname: _surnameCtrl.text.trim(),
          speciality: _specialityCtrl.text.trim(),
          serviceTypes: _selectedServices,
          experienceYears: _experience,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil yangilandi'), backgroundColor: context.cSuccess),
      );
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: context.cDanger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _carModelCtrl.dispose();
    _carNumberCtrl.dispose();
    _specialityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: const Text('Profilni tahrirlash'),
        backgroundColor: context.cScaffold,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: DesignTokens.spacingXL),
                  _buildSectionHeader('Shaxsiy ma\'lumotlar'),
                  const SizedBox(height: DesignTokens.spacingMD),
                  _buildFieldRow('Ism', _nameCtrl, hint: 'Akmal'),
                  const SizedBox(height: DesignTokens.spacingMD),
                  _buildFieldRow('Familiya', _surnameCtrl, hint: 'Karimov'),
                  const SizedBox(height: DesignTokens.spacingMD),
                  _buildFieldRow('Telefon',
                      TextEditingController(text: _phone),
                      enabled: false, hint: ''),
                  if (_isDriver) ...[
                    const SizedBox(height: DesignTokens.spacingXL),
                    _buildSectionHeader('Avtomobil ma\'lumotlari'),
                    const SizedBox(height: DesignTokens.spacingMD),
                    _buildFieldRow('Model', _carModelCtrl, hint: 'Chevrolet Cobalt'),
                    const SizedBox(height: DesignTokens.spacingMD),
                    _buildFieldRow('Davlat raqami', _carNumberCtrl, hint: '01 A 123 AA'),
                  ] else ...[
                    const SizedBox(height: DesignTokens.spacingXL),
                    _buildSectionHeader('Usta ma\'lumotlari'),
                    const SizedBox(height: DesignTokens.spacingMD),
                    _buildFieldRow('Ixtisoslik', _specialityCtrl, hint: 'Avtomexanik, Elektrik...'),
                    const SizedBox(height: DesignTokens.spacingXL),
                    _buildSectionHeader('Xizmat turlari'),
                    const SizedBox(height: DesignTokens.spacingSM),
                    _buildServiceChips(),
                    const SizedBox(height: DesignTokens.spacingXL),
                    _buildSectionHeader('Tajriba'),
                    const SizedBox(height: DesignTokens.spacingSM),
                    _buildExperienceSlider(),
                  ],
                  const SizedBox(height: DesignTokens.spacingXL),
                  AppPrimaryButton(label: 'Saqlash', onPressed: _save, isLoading: _isSaving),
                  const SizedBox(height: DesignTokens.spacingXL),
                ],
              ),
            ),
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Column(
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: context.cFieldFill,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: context.cFieldFill,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
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
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _nameCtrl.text.isNotEmpty
                    ? _nameCtrl.text[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: DesignTokens.primary,
                shape: BoxShape.circle,
              ),
              child: const AppIcon('camera_alt',
                  color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: DesignTokens.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: DesignTokens.spacingSM),
        Text(
          title,
          style: TextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: context.cTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldRow(String label, TextEditingController ctrl,
      {String hint = '', bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: context.cTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: context.cTextTertiary,
            ),
            filled: true,
            fillColor: enabled ? context.cFieldFill : context.cBorder.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              borderSide: BorderSide(color: DesignTokens.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _serviceOptions.map((s) {
        final isSelected = _selectedServices.contains(s.$1);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isSelected) {
                _selectedServices.remove(s.$1);
              } else {
                _selectedServices.add(s.$1);
              }
            });
          },
          child: AnimatedContainer(
            duration: DesignTokens.animFast,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? DesignTokens.primaryGradient : null,
              color: isSelected ? null : context.cFieldFill,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
              border: Border.all(
                color: isSelected ? Colors.transparent : context.cBorder,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.cPrimary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              s.$2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.cTextPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tajriba',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: context.cTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  '$_experience yil',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: DesignTokens.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _experience.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: DesignTokens.primary,
            inactiveColor: context.cBorder,
            label: '$_experience yil',
            onChanged: (v) => setState(() => _experience = v.round()),
          ),
        ],
      ),
    );
  }
}
