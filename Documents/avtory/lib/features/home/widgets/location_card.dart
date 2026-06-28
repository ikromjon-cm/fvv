import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../services/location_service.dart';
import '../../../shared/widgets/app_icon.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({
    super.key,
    this.isGpsActive = false,
    this.lat,
    this.lng,
  });

  final bool isGpsActive;
  final double? lat;
  final double? lng;

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  String? _addressLine;
  bool _isLoadingAddress = false;
  bool _isUpdating = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  void didUpdateWidget(LocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      _fetchAddress();
    }
  }

  void _fetchAddress() {
    if (widget.lat != null && widget.lng != null && widget.isGpsActive) {
      _reverseGeocode(widget.lat!, widget.lng!);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _isLoadingAddress = true);
    try {
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat.toStringAsFixed(6),
          'lon': lng.toStringAsFixed(6),
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'avtory/1.0'},
        ),
      );
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>?;
      final address = data?['address'] as Map<String, dynamic>?;
      if (address != null) {
        final parts = <String>[];
        final region = address['region']?.toString();
        final state = address['state']?.toString();
        final county = address['county']?.toString();
        final city = address['city']?.toString();
        final town = address['town']?.toString();
        final village = address['village']?.toString();
        final road = address['road']?.toString();
        final suburb = address['suburb']?.toString();
        final neighbourhood = address['neighbourhood']?.toString();
        if (region != null && region.isNotEmpty) parts.add(region);
        if (state != null && state.isNotEmpty && state != region) {
          parts.add(state);
        }
        if (county != null && county.isNotEmpty) parts.add(county);
        final locality = city ?? town ?? village;
        if (locality != null && locality.isNotEmpty) parts.add(locality);
        if (suburb != null && suburb.isNotEmpty) parts.add(suburb);
        if (neighbourhood != null && neighbourhood.isNotEmpty) {
          parts.add(neighbourhood);
        }
        if (road != null && road.isNotEmpty) parts.add(road);
        setState(() {
          _addressLine = parts.isNotEmpty ? parts.join(', ') : null;
          _isLoadingAddress = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingAddress = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _updateLocation() async {
    setState(() => _isUpdating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isUpdating = false);
        return;
      }

      final pos = await LocationService.current();
      if (!mounted) return;

      if (pos.real) {
        _reverseGeocode(pos.lat, pos.lng);
      }

      setState(() {
        _isUpdating = false;
        _showSuccess = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showSuccess = false);
    } catch (_) {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGpsActive) {
      return _buildPermissionCard(context);
    }
    return _buildActiveCard(context);
  }

  Widget _buildPermissionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontal, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(context.radiusLG),
        border: Border.all(color: const Color(0xFFFFE2C4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppIcon('location_off',
                size: 20, color: Color(0xFFF97316)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS required',
                  style: context.bodyMedium(color: context.cTextPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enable location for nearby mechanics',
                  style: context.bodySmall(color: context.cTextSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await Geolocator.requestPermission();
              } catch (_) {}
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context) {
    final hasCoords = widget.lat != null && widget.lng != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radiusLG),
      child: Container(
        decoration: BoxDecoration(
          color: context.cCard,
          border: Border.all(color: context.cBorder),
          boxShadow: context.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (hasCoords) _buildMapPreview(context),
            _buildAddressRow(context),
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.screenHorizontal,
        16,
        context.screenHorizontal,
        12,
      ),
      child: Row(
        children: [
          AppIcon('my_location_rounded',
              size: 20, color: context.cSuccess),
          SizedBox(width: context.spSM),
          Text(
            'Joylashuv aniqlandi',
            style: context.bodyMedium(color: context.cTextPrimary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.cSuccess,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.cSuccess.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return SizedBox(
      height: 120,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.lat!, widget.lng!),
          initialZoom: 15,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.avtory.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.lat!, widget.lng!),
                width: 36,
                height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const AppIcon('navigation_rounded',
                      size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.screenHorizontal,
        12,
        context.screenHorizontal,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon('place_rounded',
                size: 16, color: context.cTextTertiary),
          ),
          SizedBox(width: context.spSM),
          Expanded(
            child: _isLoadingAddress
                ? Text(
                    'Manzil aniqlanmoqda...',
                    style: context.bodySmall(color: context.cTextTertiary),
                  )
                : Text(
                    _addressLine ?? 'Manzil aniqlanmoqda...',
                    style: context.bodySmall(color: context.cTextSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.screenHorizontal,
        0,
        context.screenHorizontal,
        16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedCrossFade(
          firstChild: _buildUpdateButton(context),
          secondChild: _buildSuccessBadge(context),
          crossFadeState: _showSuccess
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return GestureDetector(
      onTap: _isUpdating ? null : _updateLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.cPrimary.withAlpha(10),
          borderRadius: BorderRadius.circular(context.radiusSM),
          border: Border.all(color: context.cPrimary.withAlpha(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUpdating)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.cPrimary,
                ),
              )
            else
              AppIcon('my_location_rounded',
                  size: 16, color: context.cPrimary),
            SizedBox(width: context.spSM),
            Text(
              'Joylashuvni yangilash',
              style: context.labelMedium(color: context.cPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.cSuccess.withAlpha(15),
        borderRadius: BorderRadius.circular(context.radiusSM),
        border: Border.all(color: context.cSuccess.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon('check_circle_rounded',
              size: 18, color: context.cSuccess),
          SizedBox(width: context.spSM),
          Text(
            'Yangilandi',
            style: context.labelMedium(color: context.cSuccess),
          ),
        ],
      ),
    );
  }
}
