import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../shared/components/buttons/app_buttons.dart';
import '../../shared/widgets/app_icon.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key, required this.lat, required this.lng});
  final double lat;
  final double lng;

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final _controller = MapController();
  late LatLng _center = LatLng(widget.lat, widget.lng);
  List<Map<String, dynamic>> _mechanics = [];
  Timer? _debounce;
  bool _locating = false;
  Timer? _locTimer;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadMechanics();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final pos = await LocationService.current();
      if (!mounted || !pos.real) return;
      setState(() {
        _currentPosition = LatLng(pos.lat, pos.lng);
        _center = LatLng(pos.lat, pos.lng);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _locTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMechanics() async {
    try {
      final raw = await ApiService.getNearbyMechanics(
          lat: _center.latitude, lng: _center.longitude);
      if (mounted) {
        setState(() =>
            _mechanics = raw.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (_) {}
  }

  void _scheduleReload() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _loadMechanics);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.current();
    if (!mounted) return;
    if (pos.real) {
      _center = LatLng(pos.lat, pos.lng);
      _controller.move(_center, 15);
      _loadMechanics();
    }
    setState(() => _locating = false);
  }

  List<Marker> _mechanicMarkers() {
    return _mechanics
        .where((m) => m['lat'] != null && m['lng'] != null)
        .map((m) => Marker(
              point: LatLng((m['lat'] as num).toDouble(),
                  (m['lng'] as num).toDouble()),
              width: 42,
              height: 42,
              child: GestureDetector(
                onTap: () => _mechanicSheet(m),
                child: _MechMarker(
                  name: '${m['name'] ?? ''} ${m['surname'] ?? ''}'.trim(),
                  available: m['is_available'] == true,
                  isVerified: m['is_verified'] == true,
                ),
              ),
            ))
        .toList();
  }

  void _mechanicSheet(Map<String, dynamic> m) {
    final l = AppLocalizations.of(context);
    final name = '${m['name'] ?? ''} ${m['surname'] ?? ''}'.trim();
    final mechName = name.isEmpty ? 'Mexanik' : name;
    final workshop = (m['workshop_name'] as String?)?.trim() ?? '';
    final rating = (m['avg_rating'] as num?)?.toDouble() ?? 0;
    final dist = (m['distance_km'] as num?)?.toDouble();
    final mechId = m['mechanic_id'] ?? m['id'];
    final isAvailable = m['is_available'] == true;
    final isVerified = m['is_verified'] == true;
    final eta = m['eta_minutes'] as int?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: sheetCtx.cSurface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: sheetCtx.cBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary
                            .withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isVerified
                              ? DesignTokens.verified
                              : sheetCtx.cBorder,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mechName.isNotEmpty
                              ? mechName[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: DesignTokens.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? DesignTokens.success
                              : DesignTokens.lightTextTertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: sheetCtx.cSurface,
                              width: 2.5),
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
                            child: Text(mechName,
                                style: AppTextStyles.h3,
                                overflow:
                                    TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isAvailable
                                      ? DesignTokens.success
                                      : DesignTokens
                                          .lightTextTertiary)
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAvailable ? "Bo'sh" : "Band",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable
                                      ? DesignTokens.success
                                      : DesignTokens
                                          .lightTextTertiary,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                      if (workshop.isNotEmpty)
                        Text(workshop,
                            style: AppTextStyles.caption.copyWith(
                                color:
                                    sheetCtx.cTextSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const AppIcon('star_rounded',
                              size: 14,
                              color: DesignTokens.star),
                          const SizedBox(width: 2),
                          Text(
                            rating > 0
                                ? rating.toStringAsFixed(1)
                                : '--',
                            style: AppTextStyles.caption),
                          if (dist != null) ...[
                            const SizedBox(width: 10),
                            const AppIcon('location_on_rounded',
                                size: 13,
                                color: DesignTokens.primary),
                            const SizedBox(width: 2),
                            Text('${dist.toStringAsFixed(1)} km',
                                style:
                                    AppTextStyles.caption),
                          ],
                          if (eta != null) ...[
                            const SizedBox(width: 6),
                            Text('$eta min',
                                style: AppTextStyles.caption
                                    .copyWith(
                                        color: DesignTokens
                                            .success)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: l.t('viewMechanic'),
              onPressed: () {
                Navigator.pop(sheetCtx);
                if (mechId != null) {
                  context.push('/mechanic/$mechId');
                }
              },
              trailingIcon: 'arrow_forward_rounded',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.cScaffold,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
              },
              onMapEvent: (evt) {
                if (evt is MapEventMoveEnd) _scheduleReload();
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
                    width: 30,
                    height: 30,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.primary
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ..._mechanicMarkers(),
              ]),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.glassFillStrong,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: context.glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const AppIcon('arrow_back_ios_new',
                          size: 18,
                          color: DesignTokens.primary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: _mechanics.isEmpty
                          ? context.cFieldFill
                          : context.glassFillStrong,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: context.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon('build_rounded',
                            size: 15,
                            color: _mechanics.isNotEmpty
                                ? DesignTokens.success
                                : context.cTextTertiary),
                        const SizedBox(width: 6),
                        Text(
                          _mechanics.isNotEmpty
                              ? '${_mechanics.length} ${l.t('mechanicsNearby')}'
                              : l.t('noMechanics'),
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.cTextPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 40,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _locating ? null : _goToMyLocation,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.glassFillStrong,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: context.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: _locating
                        ? const Center(
                            child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)))
                        : const AppIcon('my_location_rounded',
                            size: 22,
                            color: DesignTokens.primary),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _controller.move(
                      _controller.camera.center,
                      (_controller.camera.zoom + 1).clamp(3, 19),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.glassFillStrong,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: context.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const AppIcon('add_rounded',
                        size: 22,
                        color: DesignTokens.primary),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _controller.move(
                      _controller.camera.center,
                      (_controller.camera.zoom - 1).clamp(3, 19),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.glassFillStrong,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: context.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const AppIcon('remove_circle_outline',
                        size: 22,
                        color: DesignTokens.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MechMarker extends StatelessWidget {
  const _MechMarker({
    required this.name,
    this.available = true,
    this.isVerified = false,
  });

  final String name;
  final bool available;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final c =
        available ? DesignTokens.success : DesignTokens.lightTextTertiary;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: c, width: 3),
            boxShadow: [
              BoxShadow(
                  color: c.withValues(alpha: 0.3), blurRadius: 8),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                color: c,
              ),
            ),
          ),
        ),
        if (isVerified)
          Positioned(
            top: -2,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: DesignTokens.verified,
                shape: BoxShape.circle,
              ),
              child: const AppIcon('verified',
                  size: 9, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
