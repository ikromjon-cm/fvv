import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/responsive/responsive.dart';
import '../../core/router/app_router.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/glass.dart';

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(41.2995, 69.2401);
  LatLng? _currentPosition;
  List<Map<String, dynamic>> _mechanics = [];
  Map<String, dynamic>? _selectedMechanic;
  bool _loading = true;
  bool _locationDenied = false;
  bool _locating = false;
  Timer? _locTimer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initLocation();
    _startPeriodicLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _locTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicLocation() {
    _locTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final pos = await LocationService.current();
      if (!mounted || !pos.real) return;
      setState(() => _currentPosition = LatLng(pos.lat, pos.lng));
    });
  }

  Future<void> _initLocation() async {
    setState(() => _loading = true);
    final pos = await LocationService.current();
    if (!mounted) return;
    final latLng = LatLng(pos.lat, pos.lng);
    setState(() {
      _currentPosition = latLng;
      if (pos.real) _center = latLng;
      _locationDenied = !pos.real && latLng.latitude == 41.2995;
      _loading = false;
    });
    if (pos.real) {
      _mapController.move(latLng, 14);
    }
    _loadMechanics();
  }

  Future<void> _loadMechanics() async {
    try {
      final raw = await ApiService.getNearbyMechanics(
          lat: _center.latitude, lng: _center.longitude);
      if (mounted) {
        setState(() =>
            _mechanics = raw.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.current();
    if (!mounted) return;
    if (pos.real) {
      final latLng = LatLng(pos.lat, pos.lng);
      setState(() => _currentPosition = latLng);
      _mapController.move(latLng, 15);
      _loadMechanics();
    }
    setState(() => _locating = false);
  }

  List<Marker> _buildMarkers() {
    return _mechanics
        .where((m) => m['lat'] != null && m['lng'] != null)
        .map((m) => Marker(
              point: LatLng(
                  (m['lat'] as num).toDouble(), (m['lng'] as num).toDouble()),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _onMechanicTap(m),
                child: _MechanicMapMarker(
                  name: '${m['name'] ?? ''} ${m['surname'] ?? ''}'.trim(),
                  available: m['is_available'] == true,
                  isVerified: m['is_verified'] == true,
                  selected: _selectedMechanic == m,
                ),
              ),
            ))
        .toList();
  }

  void _onMechanicTap(Map<String, dynamic> m) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMechanic = m);
  }

  void _openChatWith(dynamic mechId, String mechName) async {
    final encoded = Uri.encodeComponent(mechName);
    if (mechId == null) {
      context.push('${AppRoutes.chat}?mechanic=$encoded&requestId=demo');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXL)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon('chat_bubble_outline_rounded',
                    size: 28, color: DesignTokens.primary),
              ),
              const SizedBox(height: 16),
              Text(
                mechName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: context.cTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Mexanik bilan chat ochish uchun so'rov yuboriladi.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: context.cTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _PremiumBtn(
                  label: 'Yuborish',
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Bekor qilish',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: context.cTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      final req = await ApiService.createRequest({
        'service_type': 'other',
        'mechanic': mechId,
        'driver_lat': _center.latitude,
        'driver_lng': _center.longitude,
        'description': "Xabar orqali bog'lanish",
      });
      final reqId = req['id'];
      if (!mounted) return;
      context.push('${AppRoutes.chat}?mechanic=$encoded&requestId=$reqId');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat ochib bo'lmadi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onTap: (_, __) {
                if (_selectedMechanic != null) {
                  setState(() => _selectedMechanic = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.avtory.app',
              ),
              MarkerLayer(markers: [
                if (_currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 60,
                    height: 60,
                    child: _UserLocationMarker(
                      pulse: _pulseAnim.value,
                    ),
                  ),
                ..._buildMarkers(),
              ]),
            ],
          ),
          if (_loading)
            _buildLoadingOverlay()
          else if (_locationDenied)
            _buildPermissionOverlay()
          else ...[
            _buildSearchBar(),
            _buildFilterChips(),
            _buildControls(),
            _buildSosButton(),
            if (_selectedMechanic != null) _buildBottomSheet(),
            _buildBackButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: context.cScaffold,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: DesignTokens.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Xarita yuklanmoqda...',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: context.cTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionOverlay() {
    return Container(
      color: context.cScaffold,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacing4XL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon('my_location_rounded',
                    size: 44, color: DesignTokens.primary),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              Text(
                'Joylashuv ruxsati kerak',
                style: TextStyle(
                  fontSize: DesignTokens.headlineMedium,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: context.cTextPrimary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSM),
              Text(
                'Atrofdagi mexaniklarni ko\'rish uchun\njoylashuv ruxsatini yoqing.',
                style: TextStyle(
                  fontSize: DesignTokens.bodyMedium,
                  fontFamily: 'Inter',
                  color: context.cTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spacing2XL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await LocationService.openSettings();
                    },
                    icon: const AppIcon('settings_rounded', size: 18),
                    label: const Text('Sozlamalar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMD),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingXL,
                        vertical: DesignTokens.spacingMD,
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingMD),
                  OutlinedButton.icon(
                    onPressed: _initLocation,
                    icon: const AppIcon('refresh', size: 18),
                    label: const Text('Qayta urinish'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      side: BorderSide(
                          color: DesignTokens.primary.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMD),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingXL,
                        vertical: DesignTokens.spacingMD,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      child: GestureDetector(
        onTap: () {
          final uri = GoRouterState.of(context).uri.toString();
          if (uri != '/home') context.pop();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.glassFillStrong,
            shape: BoxShape.circle,
            border: Border.all(color: context.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
              ),
            ],
          ),
          child: const AppIcon('arrow_back_ios_new',
              size: 16, color: DesignTokens.primary),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 56,
      left: 16,
      right: 16,
      child: GlassCard(
        radius: context.radiusFull,
        strong: true,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 48,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search mechanics, workshops or services',
              hintStyle: context.bodyMedium(color: context.cTextTertiary),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AppIcon('search_rounded',
                    size: 20, color: context.cTextTertiary),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AppIcon('tune_rounded',
                    size: 18, color: context.cTextSecondary),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(context.radiusFull),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) {
              context.push(
                  '${AppRoutes.nearbyMechanics}?q=${Uri.encodeComponent(v)}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 112,
      left: 16,
      right: 16,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(label: 'Nearest', selected: false),
            const SizedBox(width: 8),
            _FilterChip(label: 'Verified', selected: false),
            const SizedBox(width: 8),
            _FilterChip(label: 'Available', selected: true),
            const SizedBox(width: 8),
            _FilterChip(label: 'Battery', selected: false),
            const SizedBox(width: 8),
            _FilterChip(label: 'Tire', selected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      right: 16,
      bottom: _selectedMechanic != null ? 340 : 40,
      child: Column(
        children: [
          _ControlBtn(
            icon: 'my_location_rounded',
            loading: _locating,
            onTap: _locating ? null : _goToMyLocation,
          ),
          const SizedBox(height: 10),
          _ControlBtn(
            icon: 'add_rounded',
            onTap: () {
              _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(3, 19),
              );
            },
          ),
          const SizedBox(height: 10),
          _ControlBtn(
            icon: 'remove_circle_outline',
            onTap: () {
              _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(3, 19),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return Positioned(
      left: 16,
      bottom: _selectedMechanic != null ? 340 : 40,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _pulseAnim.value,
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: context.gEmergency,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignTokens.emergency.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SOS — yordam kelmoqda')),
                );
              },
              child: const Center(
                child: AppIcon('sos_rounded',
                    size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    final m = _selectedMechanic!;
    final name =
        '${m['name'] ?? ''} ${m['surname'] ?? ''}'.trim();
    final mechName = name.isEmpty ? 'Mexanik' : name;
    final available = m['is_available'] == true;
    final rating = (m['avg_rating'] as num?)?.toDouble() ?? 0;
    final reviews = m['total_reviews'] as int? ?? 0;
    final dist = (m['distance_km'] as num?)?.toDouble();
    final eta = m['eta_minutes'] as int?;
    final isVerified = m['is_verified'] == true;
    final services =
        (m['services'] as List?)?.cast<String>() ?? [];
    final mechId = m['mechanic_id'] ?? m['id'];
    final avatar = m['avatar'] as String?;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: context.cSurface,
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusXL),
            border: Border.all(color: context.cBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isVerified
                                      ? DesignTokens.verified
                                      : context.cBorder,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.primary
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: _MechanicAvatarSmall(
                                avatar: avatar,
                                name: mechName,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: -2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: available
                                      ? DesignTokens.success
                                      : DesignTokens
                                          .lightTextTertiary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: context.cSurface,
                                      width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (available
                                              ? DesignTokens
                                                  .success
                                              : DesignTokens
                                                  .lightTextTertiary)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isVerified)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: DesignTokens.verified,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const AppIcon('verified',
                                      size: 10,
                                      color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      mechName,
                                      style: TextStyle(
                                        fontSize:
                                            DesignTokens.titleLarge,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
                                        color: context.cTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (available
                                              ? DesignTokens
                                                  .success
                                              : DesignTokens
                                                  .lightTextTertiary)
                                          .withValues(alpha: 0.10),
                                      borderRadius:
                                          BorderRadius.circular(
                                              DesignTokens
                                                  .radiusFull),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration:
                                              BoxDecoration(
                                            color: available
                                                ? DesignTokens
                                                    .success
                                                : DesignTokens
                                                    .lightTextTertiary,
                                            shape:
                                                BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          available
                                              ? "Bo'sh"
                                              : 'Band',
                                          style: TextStyle(
                                            fontSize: DesignTokens
                                                .labelSmall,
                                            fontWeight:
                                                FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: available
                                                ? DesignTokens
                                                    .success
                                                : DesignTokens
                                                    .lightTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      ...List.generate(5, (i) {
                                        final filled =
                                            rating >= i + 0.5;
                                        return Padding(
                                          padding: const EdgeInsets
                                              .only(
                                              right: 1),
                                          child: AppIcon(
                                            filled
                                                ? 'star_rounded'
                                                : 'star_outline',
                                            size: 13,
                                            color: filled
                                                ? DesignTokens
                                                    .star
                                                : context
                                                    .cTextTertiary,
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating > 0
                                            ? rating
                                                .toStringAsFixed(1)
                                            : '—',
                                        style: TextStyle(
                                          fontSize: DesignTokens
                                              .labelSmall,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontFamily: 'Inter',
                                          color: context
                                              .cTextPrimary,
                                        ),
                                      ),
                                      if (reviews > 0) ...[
                                        const SizedBox(width: 2),
                                        Text(
                                          '($reviews)',
                                          style: TextStyle(
                                            fontSize: DesignTokens
                                                .labelSmall,
                                            fontFamily: 'Inter',
                                            color: context
                                                .cTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Spacer(),
                                  if (dist != null)
                                    Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        AppIcon(
                                            'location_on_rounded',
                                            size: 13,
                                            color: context
                                                .cTextTertiary),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${dist.toStringAsFixed(1)} km',
                                          style: TextStyle(
                                            fontSize: DesignTokens
                                                .labelSmall,
                                            fontWeight:
                                                FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: context
                                                .cTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (dist != null && eta != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal: 2),
                                      child: Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: DesignTokens
                                              .labelSmall,
                                          fontFamily: 'Inter',
                                          color: context
                                              .cTextTertiary,
                                        ),
                                      ),
                                    ),
                                  if (eta != null)
                                    Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        AppIcon('timer_outlined',
                                            size: 13,
                                            color: DesignTokens
                                                .success),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$eta min',
                                          style: TextStyle(
                                            fontSize: DesignTokens
                                                .labelSmall,
                                            fontWeight:
                                                FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: DesignTokens
                                                .success,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (services.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: services.take(4).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignTokens.primary
                                  .withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusFull),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: DesignTokens.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetBtn(
                            icon: 'person_outline_rounded',
                            label: 'Profile',
                            isPrimary: false,
                            onTap: () {
                              setState(
                                  () => _selectedMechanic = null);
                              if (mechId != null) {
                                context.push('/mechanic/$mechId');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SheetBtn(
                            icon: 'phone_outlined',
                            label: 'Call',
                            isPrimary: false,
                            color: DesignTokens.success,
                            onTap: () {
                              final phone =
                                  m['phone'] as String?;
                              if (phone != null &&
                                  phone.isNotEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Calling $phone')),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _SheetBtn(
                            icon: 'chat_bubble_outline_rounded',
                            label: 'Message',
                            isPrimary: true,
                            onTap: () {
                              setState(() =>
                                  _selectedMechanic = null);
                              _openChatWith(mechId, mechName);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker({required this.pulse});
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DesignTokens.primary.withValues(alpha: 0.10 * pulse),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: DesignTokens.primary.withValues(alpha: 0.15 * pulse),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: DesignTokens.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MechanicMapMarker extends StatelessWidget {
  const _MechanicMapMarker({
    required this.name,
    this.available = true,
    this.isVerified = false,
    this.selected = false,
  });

  final String name;
  final bool available;
  final bool isVerified;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        available ? DesignTokens.success : DesignTokens.lightTextTertiary;
    final size = selected ? 52.0 : 44.0;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: DesignTokens.animNormal,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? DesignTokens.primary : statusColor,
              width: selected ? 3.5 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (selected ? DesignTokens.primary : statusColor)
                    .withValues(alpha: selected ? 0.3 : 0.2),
                blurRadius: selected ? 16 : 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: selected ? 20 : 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: selected ? DesignTokens.primary : statusColor,
              ),
            ),
          ),
        ),
        if (isVerified)
          Positioned(
            top: -2,
            right: -4,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: DesignTokens.verified,
                shape: BoxShape.circle,
              ),
              child: const AppIcon('verified',
                  size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _MechanicAvatarSmall extends StatelessWidget {
  const _MechanicAvatarSmall(
      {this.avatar, required this.name});
  final String? avatar;
  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: DesignTokens.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: DesignTokens.primary,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.animFast,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: selected
            ? DesignTokens.primary
            : context.glassFillStrong,
        borderRadius:
            BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: selected
              ? DesignTokens.primary
              : context.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          color: selected
              ? Colors.white
              : context.cTextPrimary,
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    this.loading = false,
    this.onTap,
  });

  final String icon;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: GlassCard(
        radius: 22,
        circle: true,
        strong: true,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 44,
          height: 44,
          child: loading
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DesignTokens.primary,
                    ),
                  ),
                )
              : AppIcon(icon,
                  size: 22, color: DesignTokens.primary),
        ),
      ),
    );
  }
}

class _SheetBtn extends StatefulWidget {
  const _SheetBtn({
    required this.icon,
    required this.label,
    required this.isPrimary,
    this.color,
    this.onTap,
  });

  final String icon;
  final String label;
  final bool isPrimary;
  final Color? color;
  final VoidCallback? onTap;

  @override
  State<_SheetBtn> createState() => _SheetBtnState();
}

class _SheetBtnState extends State<_SheetBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
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
    final btnColor = widget.color ?? DesignTokens.primary;
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              HapticFeedback.lightImpact();
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusSM),
                gradient: widget.isPrimary
                    ? DesignTokens.primaryGradient
                    : null,
                color: widget.isPrimary ? null : context.cFieldFill,
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: btnColor.withValues(alpha: 0.3)),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: DesignTokens.primary
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(widget.icon,
                        size: 16,
                        color: widget.isPrimary
                            ? Colors.white
                            : btnColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: widget.isPrimary
                            ? Colors.white
                            : btnColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumBtn extends StatelessWidget {
  const _PremiumBtn({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        gradient: DesignTokens.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
