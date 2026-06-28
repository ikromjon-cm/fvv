import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/app_storage.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key, this.isSetup = false});
  final bool isSetup;

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final _workshopCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  bool _isGettingLocation = false;
  bool _isSaving = false;
  bool _is247 = false;
  int _startHour = 8;
  int _endHour = 20;
  int _experience = 3;
  int _radius = 15;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getMechanicProfile();
      if (mounted) {
        setState(() {
          _lat = (data['lat'] as num?)?.toDouble();
          _lng = (data['lng'] as num?)?.toDouble();
          _workshopCtrl.text = data['workshop_name'] as String? ?? '';
          _addressCtrl.text = data['address'] as String? ?? '';
          _is247 = data['is_24_7'] as bool? ?? false;
          _startHour = data['start_hour'] as int? ?? 8;
          _endHour = data['end_hour'] as int? ?? 20;
          _experience = data['experience_years'] as int? ?? 3;
          _radius = data['service_radius_km'] as int? ?? 15;
        });
      }
    } catch (_) {
      final loc = await AppStorage.getMechanicLocation();
      final hours = await AppStorage.getWorkHours();
      final profile = await AppStorage.getMechanicProfile();
      if (mounted) {
        setState(() {
          _lat = loc['lat'] as double?;
          _lng = loc['lng'] as double?;
          _workshopCtrl.text = loc['workshopName'] as String? ?? '';
          _addressCtrl.text = loc['address'] as String? ?? '';
          _is247 = hours['isAlways'] as bool? ?? false;
          _startHour = hours['startHour'] as int? ?? 8;
          _endHour = hours['endHour'] as int? ?? 20;
          _experience = profile['experience'] as int? ?? 3;
        });
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Joylashuv xizmati o'chirilgan. Iltimos, yoqing.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Joylashuv ruxsati rad etildi.");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError("Joylashuv ruxsati bloklangan. Sozlamalarga o'ting.");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        if (_addressCtrl.text.isEmpty) {
          _addressCtrl.text = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joylashuv muvaffaqiyatli aniqlandi'),
            backgroundColor: context.cSuccess,
          ),
        );
      }
    } catch (e) {
      _showError('Joylashuvni aniqlab bo\'lmadi: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.cDanger),
    );
  }

  Future<void> _save() async {
    if (_lat == null || _lng == null) {
      _showError("Iltimos, avval joylashuvni aniqlang.");
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.saveMechanicWorkshop({
        'lat': _lat,
        'lng': _lng,
        'workshop_name': _workshopCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'is_24_7': _is247,
        'start_hour': _startHour,
        'end_hour': _endHour,
        'service_radius_km': _radius,
      });
      await AppStorage.saveMechanicLocation(
        lat: _lat!,
        lng: _lng!,
        workshopName: _workshopCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      await AppStorage.saveWorkHours(isAlways: _is247, startHour: _startHour, endHour: _endHour);
      if (widget.isSetup) await AppStorage.markSetupDone();
      if (!mounted) return;
      if (widget.isSetup) {
        context.go('/mechanic-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ustaxona ma'lumotlari saqlandi"), backgroundColor: context.cSuccess),
        );
        context.pop();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _workshopCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        backgroundColor: context.cSurface,
        title: Text(widget.isSetup ? 'Joylashuv va ustaxona' : "Ustaxona ma'lumotlari"),
        leading: widget.isSetup
            ? null
            : IconButton(
                icon: AppIcon('arrow_back_ios_new', size: 20),
                onPressed: () => context.pop(),
              ),
        automaticallyImplyLeading: !widget.isSetup,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Joylashuv'),
            const SizedBox(height: 12),
            _locationCard(),
            const SizedBox(height: 20),
            _sectionTitle('Ustaxona'),
            const SizedBox(height: 12),
            _label("Ustaxona nomi"),
            const SizedBox(height: 6),
            _field(_workshopCtrl, hint: "Masalan: Akmal Usta Ustaxonasi"),
            const SizedBox(height: 12),
            _label("Manzil"),
            const SizedBox(height: 6),
            _field(_addressCtrl, hint: "Ko'cha, mahalla, tuman"),
            const SizedBox(height: 20),
            _sectionTitle('Ish vaqti'),
            const SizedBox(height: 12),
            _workHoursCard(),
            const SizedBox(height: 20),
            _sectionTitle('Tajriba (yil)'),
            const SizedBox(height: 12),
            _experienceCard(),
            const SizedBox(height: 32),
            AppPrimaryButton(
              label: widget.isSetup ? 'Sozlashni yakunlash' : 'Saqlash',
              onPressed: _save,
              isLoading: _isSaving,
              trailingIcon: widget.isSetup ? 'check_rounded' : null,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _lat != null ? context.cSuccess.withValues(alpha: 0.4) : context.cBorder,
        ),
      ),
      child: Column(
        children: [
          if (_lat != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cSuccess.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon('location_on', color: context.cSuccess, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Joylashuv aniqlandi',
                          style: AppTextStyles.bodyMedium.copyWith(color: context.cSuccess)),
                      Text(
                        '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cEmergency.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon('location_off', color: context.cEmergency, size: 24),
                ),
                const SizedBox(width: 12),
                Text('Joylashuv aniqlanmagan',
                    style: AppTextStyles.body.copyWith(color: context.cTextSecondary)),
              ],
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGettingLocation ? null : _getLocation,
              icon: _isGettingLocation
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const AppIcon('my_location_rounded', size: 18),
              label: Text(_isGettingLocation ? 'Aniqlanmoqda...' : 'GPS bilan aniqlash'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.cPrimary,
                side: BorderSide(color: context.cPrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workHoursCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppIcon('access_time_rounded', color: context.cPrimary, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text('24/7 ishlash', style: AppTextStyles.bodyMedium)),
              Switch(
                value: _is247,
                onChanged: (v) => setState(() => _is247 = v),
                activeThumbColor: context.cPrimary,
              ),
            ],
          ),
          if (!_is247) ...[
            const Divider(height: 20),
            Row(
              children: [
                Expanded(child: _hourPicker('Boshlanish', _startHour, (v) => setState(() => _startHour = v))),
                const SizedBox(width: 16),
                Expanded(child: _hourPicker('Tugash', _endHour, (v) => setState(() => _endHour = v))),
              ],
            ),
          ],
          const Divider(height: 20),
          Row(
            children: [
              AppIcon('my_location_rounded', color: context.cPrimary, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text('Xizmat radiusi', style: AppTextStyles.bodyMedium)),
              Text('$_radius km',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.cPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
          Text('Shu masofadagi haydovchilarga ko\'rinasiz',
              style: AppTextStyles.caption.copyWith(color: context.cTextSecondary)),
          Slider(
            value: _radius.toDouble().clamp(1, 50),
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: context.cPrimary,
            label: '$_radius km',
            onChanged: (v) => setState(() => _radius = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _hourPicker(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.cFieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              items: List.generate(24, (i) => DropdownMenuItem(
                    value: i,
                    child: Text('${i.toString().padLeft(2, '0')}:00'),
                  )),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _experienceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_experience yil', style: AppTextStyles.h2.copyWith(color: context.cPrimary)),
              Text(_experienceLabel, style: AppTextStyles.caption),
            ],
          ),
          Slider(
            value: _experience.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: context.cPrimary,
            inactiveColor: context.cBorder,
            label: '$_experience yil',
            onChanged: (v) => setState(() => _experience = v.round()),
          ),
        ],
      ),
    );
  }

  String get _experienceLabel => switch (_experience) {
        <= 2 => 'Yangi usta',
        <= 5 => "O'rta darajali",
        <= 10 => 'Tajribali usta',
        _ => 'Yuqori darajali',
      };

  Widget _sectionTitle(String t) => Text(t, style: AppTextStyles.h3);
  Widget _label(String t) => Text(t, style: AppTextStyles.caption.copyWith(color: context.cTextPrimary, fontWeight: FontWeight.w500));
  Widget _field(TextEditingController c, {String hint = ''}) => TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: context.cFieldFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cPrimary, width: 1.5)),
        ),
      );
}
