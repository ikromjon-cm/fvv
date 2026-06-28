import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/photo_picker.dart';
import '../../../data/local/app_storage.dart';
import '../../../data/models/request_model.dart';
import '../../../services/api_service.dart';
import '../../../services/location_service.dart';
import '../../../shared/components/buttons/app_buttons.dart';
import '../../../shared/widgets/app_icon.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen(
      {super.key, required this.requestId, this.mechanicName = ''});
  final String requestId;
  final String mechanicName;

  @override
  State<RequestStatusScreen> createState() =>
      _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  RequestStatus _status = RequestStatus.pending;
  String _mechanicName = '';
  String _mechanicPhone = '';
  String _driverName = '';
  String _driverPhone = '';
  String _role = 'driver';
  bool _advancing = false;
  Timer? _pollTimer;
  Timer? _locTimer;
  int? _numericId;

  double? _mechLiveLat;
  double? _mechLiveLng;
  double? _driverLat;
  double? _driverLng;
  String _driverAddress = '';
  String? _photo;
  int? _agreedPrice;
  String _workDescription = '';
  int? _etaMinutes;

  static String _fmtPrice(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }

  bool get _isMechanic => _role == 'mechanic';
  bool get _jobActive =>
      _status == RequestStatus.accepted ||
      _status == RequestStatus.onWay ||
      _status == RequestStatus.arrived;

  @override
  void initState() {
    super.initState();
    _mechanicName = widget.mechanicName;
    _numericId = int.tryParse(widget.requestId);
    _loadRole();
    _fetchStatus();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _fetchStatus());
  }

  Future<void> _loadRole() async {
    final r = await AppStorage.getRole();
    if (mounted && r != null) setState(() => _role = r);
  }

  Future<void> _fetchStatus() async {
    final id = _numericId;
    if (id == null) return;
    try {
      final data = await ApiService.getRequest(id);
      if (!mounted) return;
      final statusStr = data['status'] as String? ?? 'pending';
      final newStatus = RequestStatus.fromString(statusStr);
      final mechName = data['mechanic_name'] as String? ?? _mechanicName;
      final mechPhone = data['mechanic_phone'] as String? ?? '';
      final drvName = data['driver_name'] as String? ?? _driverName;
      final drvPhone = data['driver_phone'] as String? ?? '';
      setState(() {
        _status = newStatus;
        if (mechName.isNotEmpty) _mechanicName = mechName;
        if (mechPhone.isNotEmpty) _mechanicPhone = mechPhone;
        if (drvName.isNotEmpty) _driverName = drvName;
        if (drvPhone.isNotEmpty) _driverPhone = drvPhone;
        _mechLiveLat =
            (data['mechanic_live_lat'] as num?)?.toDouble();
        _mechLiveLng =
            (data['mechanic_live_lng'] as num?)?.toDouble();
        _driverLat = (data['driver_lat'] as num?)?.toDouble();
        _driverLng = (data['driver_lng'] as num?)?.toDouble();
        _driverAddress =
            data['driver_address'] as String? ?? _driverAddress;
        _photo = data['photo'] as String?;
        _agreedPrice = (data['agreed_price'] as num?)?.toInt();
        _workDescription = data['work_description'] as String? ??
            _workDescription;
        _etaMinutes = (data['eta_minutes'] as num?)?.toInt();
      });
      _syncLocationSharing();
      if (newStatus == RequestStatus.completed ||
          newStatus == RequestStatus.cancelled) {
        _pollTimer?.cancel();
      }
    } catch (_) {}
  }

  void _syncLocationSharing() {
    final shouldShare = _isMechanic && _jobActive;
    if (shouldShare && _locTimer == null) {
      _sendLocation();
      _locTimer =
          Timer.periodic(const Duration(seconds: 10), (_) => _sendLocation());
    } else if (!shouldShare && _locTimer != null) {
      _locTimer?.cancel();
      _locTimer = null;
    }
  }

  Future<void> _sendLocation() async {
    final id = _numericId;
    if (id == null) return;
    try {
      final pos = await LocationService.current();
      await ApiService.updateMechanicLocation(id, pos.lat, pos.lng);
    } catch (_) {}
  }

  void _sos() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusXL)),
        child: Padding(
          padding: EdgeInsets.all(context.sp2XL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: DesignTokens.emergencyGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.cDanger
                          .withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const AppIcon('sos_rounded',
                    color: Colors.white, size: 28),
              ),
              SizedBox(height: context.spLG),
              Text(
                'Favqulodda qo\'ng\'iroq',
                style: context.headingMedium(),
              ),
              SizedBox(height: context.sp2XL),
              SizedBox(
                width: double.infinity,
                child: AppDangerButton(
                  label: '112',
                  onPressed: () {
                    Navigator.pop(context);
                    dialPhone('112');
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Bekor qilish',
                  style: context.bodyMedium(color: context.cTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _advance(String newStatus) async {
    final id = _numericId;
    if (id == null || _advancing) return;

    int? price;
    String? workDesc;
    if (newStatus == 'completed') {
      final report = await _askCompletionReport();
      if (report == null) return;
      price = report.$1;
      workDesc = report.$2;
    }

    setState(() => _advancing = true);
    try {
      await ApiService.updateStatus(id, newStatus,
          agreedPrice: price, workDescription: workDesc);
      await _fetchStatus();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Future<(int?, String?)?> _askCompletionReport() async {
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    return showDialog<(int?, String?)>(
      context: context,
      builder: (dctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusXL)),
        child: Padding(
          padding: EdgeInsets.all(context.sp2XL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ishni yakunlash',
                style: context.headingMedium(),
              ),
              SizedBox(height: context.spLG),
              Text(
                'Yakuniy narx',
                style: context.labelLarge(color: context.cTextSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '150 000',
                  suffixText: "so'm",
                  filled: true,
                  fillColor: dctx.cFieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: context.spLG),
              Text(
                'Bajarilgan ish tavsifi',
                style: context.labelLarge(color: context.cTextSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Nima qilindi?",
                  filled: true,
                  fillColor: dctx.cFieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: context.spXL),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Yakunlash',
                  onPressed: () {
                    final price = int.tryParse(priceCtrl.text
                        .trim()
                        .replaceAll(' ', ''));
                    Navigator.pop(
                        dctx, (price, descCtrl.text.trim()));
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dctx),
                child: Text(
                  'Bekor qilish',
                  style: context.bodyMedium(color: context.cTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _locTimer?.cancel();
    super.dispose();
  }

  static const _steps = [
    (RequestStatus.pending, 'So\'rov yuborildi', 'send_rounded',
        DesignTokens.primary),
    (RequestStatus.accepted, 'Qabul qilindi', 'check_circle_rounded',
        DesignTokens.success),
    (RequestStatus.onWay, 'Yo\'lda', 'near_me_rounded',
        DesignTokens.primary),
    (RequestStatus.arrived, 'Yetib keldi', 'location_on_rounded',
        DesignTokens.success),
  ];

  int get _currentStepIndex => _steps.indexWhere((s) => s.$1 == _status);

  void _cancel() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusXL)),
        child: Padding(
          padding: EdgeInsets.all(context.sp2XL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.cDanger
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: AppIcon('close_rounded',
                    size: 28, color: context.cDanger),
              ),
              SizedBox(height: context.spLG),
              Text(
                'So\'rovni bekor qilish',
                style: context.headingMedium(),
              ),
              SizedBox(height: context.sp2XL),
              SizedBox(
                width: double.infinity,
                child: AppDangerButton(
                  label: 'Ha, bekor qilish',
                  onPressed: () async {
                    Navigator.pop(context);
                    final id = _numericId;
                    if (id != null) {
                      try {
                        await ApiService.cancelRequest(id);
                      } catch (_) {}
                    }
                    await AppStorage.addHistoryItem({
                      'type': "Bekor qilindi",
                      'mechanicName':
                          _mechanicName.isNotEmpty
                              ? _mechanicName
                              : 'Mexanik',
                      'status': 'cancelled',
                      'date': _todayLabel(),
                      'price': '--',
                      'rating': 0.0,
                    });
                    if (mounted) context.go(AppRoutes.home);
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Yo\'q',
                  style: context.bodyMedium(color: context.cTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _todayLabel() {
    final d = DateTime.now();
    const m = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      appBar: AppBar(
        title: const Text('So\'rov holati'),
        backgroundColor: context.cScaffold,
        leading: IconButton(
          icon: const AppIcon('arrow_back_ios_new', size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_jobActive)
            Semantics(
              button: true,
              label: 'SOS favqulodda qo\'ng\'iroq',
              child: GestureDetector(
                onTap: _sos,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: DesignTokens.emergencyGradient,
                    borderRadius: BorderRadius.circular(
                        DesignTokens.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: context.cDanger
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon('sos_rounded',
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'SOS',
                        style: context.bodySmall(color: Colors.white)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.spXL),
              child: Column(
                children: [
                  _premiumTimeline(),
                  SizedBox(height: context.sp2XL),
                  if (!_isMechanic &&
                      _jobActive &&
                      _mechLiveLat != null &&
                      _mechLiveLng != null) ...[
                    _liveMap(),
                    SizedBox(height: context.sp2XL),
                  ],
                  if (_isMechanic && _jobActive) ...[
                    _driverMap(),
                    SizedBox(height: context.sp2XL),
                  ],
                  if (decodeDataUrl(_photo) != null) ...[
                    _photoCard(),
                    SizedBox(height: context.sp2XL),
                  ],
                  if (!_isMechanic &&
                      _status == RequestStatus.arrived) ...[
                    AppPrimaryButton(
                      label: 'Yakunlash va baholash',
                      onPressed: () => context.push(
                        '/rating/${widget.requestId}?mechanic=${Uri.encodeComponent(_mechanicName)}',
                      ),
                    ),
                  ],
                  if (_status == RequestStatus.completed) ...[
                    _completedCard(),
                  ],
                ],
              ),
            ),
          ),
          _bottomBar(),
          SafeArea(bottom: true, child: _bottomAction()),
        ],
      ),
    );
  }

  Widget _bottomAction() {
    if (_isMechanic) {
      String? label;
      String? next;
      switch (_status) {
        case RequestStatus.accepted:
          label = "Yo'lga chiqdim";
          next = 'on_way';
        case RequestStatus.onWay:
          label = 'Yetib keldim';
          next = 'arrived';
        case RequestStatus.arrived:
          label = 'Ishni yakunladim';
          next = 'completed';
        default:
          return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(context.spLG, 0, context.spLG, context.spSM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPrimaryButton(
              label: label,
              isLoading: _advancing,
              onPressed: _advancing ? null : () => _advance(next!),
            ),
            SizedBox(height: context.spSM),
            SizedBox(
              width: double.infinity,
              child: AppOutlinedButton(
                label: 'Bekor qilish',
                onPressed: _advancing ? null : _cancel,
                color: DesignTokens.danger,
              ),
            ),
          ],
        ),
      );
    }
    if (_status == RequestStatus.pending ||
        _status == RequestStatus.accepted ||
        _status == RequestStatus.onWay) {
      return Padding(
        padding: EdgeInsets.fromLTRB(context.spLG, 0, context.spLG, context.spSM),
        child: AppDangerButton(
          label: 'Bekor qilish',
          onPressed: _cancel,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _premiumTimeline() {
    return Container(
      padding: EdgeInsets.all(context.spXL),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusXL),
        border: Border.all(color: context.cBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _status == RequestStatus.completed
                      ? context.cSuccess
                      : context.cPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.spSM),
              Text(
                _status == RequestStatus.completed
                    ? 'Bajarildi'
                    : 'So\'rov holati',
                style: context.headingSmall(),
              ),
            ],
          ),
          SizedBox(height: context.spXL),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isDone = i <= _currentStepIndex;
            final isActive = i == _currentStepIndex;
            final isLast = i == _steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: DesignTokens.animSlow,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: isDone
                            ? (step.$4 == DesignTokens.primary
                                ? DesignTokens.primaryGradient
                                : LinearGradient(
                                    colors: [
                                      step.$4,
                                      step.$4
                                    ]))
                            : null,
                        color: isDone
                            ? null
                            : context.cFieldFill,
                        shape: BoxShape.circle,
                        border: isDone
                            ? null
                            : Border.all(
                                color: context.cBorder),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: step.$4
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isDone
                          ? Center(
                              child: step.$1 ==
                                      _status
                                  ? AnimatedBuilder(
                                      animation:
                                          const AlwaysStoppedAnimation<
                                                  double>(
                                              1),
                                      builder: (_, __) =>
                                          const AppIcon(
                                              'more_horiz_rounded',
                                              size: 16,
                                              color: Colors
                                                  .white),
                                    )
                                  : const AppIcon(
                                      'check',
                                      size: 16,
                                      color: Colors.white),
                            )
                          : const SizedBox(),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: DesignTokens.animSlow,
                        width: 2,
                        height: 44,
                        color: i < _currentStepIndex
                            ? step.$4
                            : context.cBorder,
                      ),
                  ],
                ),
                SizedBox(width: context.spLG),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: isLast ? 0 : 8.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: context.bodyMedium().copyWith(
                            fontWeight: isDone
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isDone
                                ? DesignTokens.lightTextPrimary
                                : DesignTokens.lightTextTertiary,
                          ),
                        ),
                        if (isActive &&
                            step.$1 ==
                                RequestStatus.onWay) ...[
                          SizedBox(height: context.spXS),
                          Row(
                            children: [
                              if (_etaMinutes != null) ...[
                                const AppIcon('timer_outlined',
                                    size: 14,
                                    color:
                                        DesignTokens.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '$_etaMinutes daqiqa',
                                  style: context.bodySmall(
                                      color: context.cPrimary,
                                    ).copyWith(
                                        fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (isActive &&
                            step.$1 ==
                                RequestStatus.pending) ...[
                          const SizedBox(height: 6),
                          const _PendingDots(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _liveMap() {
    final mech = LatLng(_mechLiveLat!, _mechLiveLng!);
    final hasDriver =
        _driverLat != null && _driverLng != null;
    final driver =
        hasDriver ? LatLng(_driverLat!, _driverLng!) : null;
    final center = driver != null
        ? LatLng((mech.latitude + driver.latitude) / 2,
            (mech.longitude + driver.longitude) / 2)
        : mech;

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: context.cSurface,
            child: Row(
              children: [
                const AppIcon('near_me_rounded',
                    size: 16, color: DesignTokens.primary),
                const SizedBox(width: 6),
                Text(
                  'Usta yo\'lda',
                  style: context.labelLarge(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'uz.avtory.app',
                ),
                if (driver != null)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: [mech, driver],
                      strokeWidth: 3,
                      color: context.cPrimary
                          .withValues(alpha: 0.5),
                    ),
                  ]),
                MarkerLayer(markers: [
                  Marker(
                    point: mech,
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.cPrimary,
                            width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: context.cPrimary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const AppIcon('build_rounded',
                          size: 22,
                          color: DesignTokens.primary),
                    ),
                  ),
                  if (driver != null)
                    Marker(
                      point: driver,
                      width: 38,
                      height: 38,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.cDanger,
                              width: 3),
                        ),
                        child: AppIcon(
                            'person_pin_circle',
                            size: 18,
                            color: context.cDanger),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverMap() {
    final hasDriver = _driverLat != null && _driverLng != null;
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: context.cSurface,
            child: Row(
              children: [
                AppIcon('person_pin_circle',
                    size: 16, color: context.cDanger),
                const SizedBox(width: 6),
                Text(
                  'Mijoz manzili',
                  style: context.labelLarge(),
                ),
              ],
            ),
          ),
          if (_driverAddress.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              color: context.cSurface,
              child: Text(
                _driverAddress.trim(),
                style: context.bodySmall(color: context.cTextSecondary),
              ),
            ),
          if (!hasDriver)
            Container(
              padding: EdgeInsets.all(context.spXL),
              color: context.cSurface,
              child: Row(
                children: [
                  AppIcon('location_off_outlined',
                      size: 24,
                      color:
                          context.cTextTertiary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _driverAddress.isNotEmpty
                          ? _driverAddress
                          : 'Mijoz lokatsiyasi mavjud emas',
                      style: context.bodyMedium(
                          color: context.cTextSecondary),
                    ),
                  ),
              ],
            ),
          )
          else ...[
            SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(_driverLat!, _driverLng!),
                  initialZoom: 15,
                  interactionOptions:
                      const InteractionOptions(
                          flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'uz.avtory.app',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point:
                          LatLng(_driverLat!, _driverLng!),
                      width: 46,
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.cDanger,
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: context.cDanger
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: AppIcon(
                            'person_pin_circle',
                            size: 22,
                            color: context.cDanger),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: context.spMD),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: AppPrimaryButton(
                label: "Yo'nalishni ochish",
                onPressed: () =>
                    navigateTo(_driverLat!, _driverLng!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _completedCard() {
    return Container(
      padding: EdgeInsets.all(context.spXL),
      decoration: BoxDecoration(
        color: context.cSuccess.withValues(alpha: 0.06),
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(
            color: context.cSuccess.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.cSuccess
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: AppIcon('check_circle',
                    size: 22, color: context.cSuccess),
              ),
              const SizedBox(width: 12),
              Text(
                'Xizmat bajarildi',
                style: context.headingSmall(),
              ),
            ],
          ),
          if (_agreedPrice != null) ...[
            SizedBox(height: context.spLG),
            Row(
              children: [
                AppIcon('payments_outlined',
                    size: 18,
                    color:
                        context.cTextSecondary),
                const SizedBox(width: 8),
                Text(
                  "${_fmtPrice(_agreedPrice!)} so'm",
                  style: context.headingSmall(color: context.cSuccess),
                ),
              ],
            ),
          ],
          if (_workDescription.trim().isNotEmpty) ...[
            SizedBox(height: context.spMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIcon('notes_rounded',
                    size: 18,
                    color:
                        context.cTextSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _workDescription.trim(),
                    style: context.bodyMedium(
                        color: context.cTextSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoCard() {
    final data = decodeDataUrl(_photo);
    if (data == null) return const SizedBox.shrink();
    final bytes = data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon('image_outlined',
                size: 16,
                color: context.cTextTertiary),
            const SizedBox(width: 6),
            Text(
              'Muammo rasmi',
              style: context.bodySmall(color: context.cTextSecondary),
            ),
          ],
        ),
        SizedBox(height: context.spMD),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(context.spLG),
              child: InteractiveViewer(
                  child: Image.memory(bytes)),
            ),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusLG),
            child: Image.memory(bytes,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    final otherName = _isMechanic
        ? (_driverName.isNotEmpty
            ? _driverName
            : 'Mijoz')
        : (_mechanicName.isNotEmpty
            ? _mechanicName
            : 'Mexanik');
    final otherPhone = _isMechanic ? _driverPhone : _mechanicPhone;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cSurface,
        border: Border(
            top: BorderSide(
                color: context.cBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                otherName.isNotEmpty
                    ? otherName[0].toUpperCase()
                    : 'M',
                style: context.headingSmall(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              otherName,
              style: context.bodyMedium().copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (otherPhone.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Semantics(
                button: true,
                label: 'Qo\'ng\'iroq qilish',
                child: IconButton(
                  icon: const AppIcon('phone_outlined',
                      size: 18, color: DesignTokens.primary),
                  onPressed: () => dialPhone(otherPhone),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          Semantics(
            button: true,
            label: 'Xabar yozish',
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const AppIcon('chat_outlined',
                    size: 18, color: DesignTokens.primary),
                onPressed: () => context.push(
                  '${AppRoutes.chat}?mechanic=${Uri.encodeComponent(otherName)}&requestId=${widget.requestId}',
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingDots extends StatefulWidget {
  const _PendingDots();

  @override
  State<_PendingDots> createState() => _PendingDotsState();
}

class _PendingDotsState extends State<_PendingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (i) {
            final opacity =
                ((_anim.value * 3 - i + 3) % 3).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Opacity(
                opacity: 0.3 + opacity * 0.7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: DesignTokens.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
