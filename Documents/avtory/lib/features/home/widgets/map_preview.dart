import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../shared/widgets/app_icon.dart';

class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.center,
    this.mechanicPoints,
    this.onOpenFullMap,
    this.height = 160,
  });

  final LatLng center;
  final List<LatLng>? mechanicPoints;
  final VoidCallback? onOpenFullMap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
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
                    point: center,
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
                  if (mechanicPoints != null)
                    for (final p in mechanicPoints!)
                      Marker(
                        point: p,
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: DesignTokens.success,
                                width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: DesignTokens.success
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: AppIcon('person_pin_circle',
                                size: 14,
                                color: DesignTokens.success),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withAlpha(30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          if (onOpenFullMap != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onOpenFullMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.glassFillStrong,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: context.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon('open_with_rounded',
                          size: 14,
                          color: DesignTokens.primary),
                      SizedBox(width: 6),
                      Text(
                        'Full Map',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: DesignTokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
