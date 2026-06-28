import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';
import 'app_icon.dart';

enum GpsAccuracy { high, medium, low, none, denied }

class GpsIndicator extends StatelessWidget {
  const GpsIndicator({
    super.key,
    this.accuracy = GpsAccuracy.high,
    this.latitude,
    this.longitude,
    required this.isActive,
  });

  final GpsAccuracy accuracy;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  String get _label {
    if (!isActive) return "O'chirilgan";
    return switch (accuracy) {
      GpsAccuracy.high => 'Aniq',
      GpsAccuracy.medium => "O'rtacha",
      GpsAccuracy.low => 'Past',
      GpsAccuracy.none => "Yo'q",
      GpsAccuracy.denied => "Ruxsat yo'q",
    };
  }

  String get _icon {
    if (!isActive) return 'gps_off_rounded';
    return switch (accuracy) {
      GpsAccuracy.high => 'my_location_rounded',
      GpsAccuracy.medium => 'location_on_rounded',
      GpsAccuracy.low => 'gps_not_fixed_rounded',
      GpsAccuracy.none => 'gps_off_rounded',
      GpsAccuracy.denied => 'location_off_rounded',
    };
  }

  Color _color(BuildContext context) {
    if (!isActive) return context.cTextTertiary;
    return switch (accuracy) {
      GpsAccuracy.high => context.cSuccess,
      GpsAccuracy.medium => context.cWarning,
      GpsAccuracy.low => context.cEmergency,
      GpsAccuracy.none => context.cDanger,
      GpsAccuracy.denied => context.cTextTertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Semantics(
      liveRegion: true,
      label: _label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(_icon, size: 16, color: color),
          SizedBox(width: context.spXXS),
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
          if (latitude != null && longitude != null) ...[
            SizedBox(width: context.spXS),
            Text(
              '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 10,
                color: context.cTextTertiary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LocationStatusDot extends StatelessWidget {
  const LocationStatusDot({
    super.key,
    this.accuracy = GpsAccuracy.high,
    required this.isActive,
  });

  final GpsAccuracy accuracy;
  final bool isActive;

  Color _color(BuildContext context) {
    if (!isActive) return context.cTextTertiary;
    return switch (accuracy) {
      GpsAccuracy.high => context.cSuccess,
      GpsAccuracy.medium => context.cWarning,
      GpsAccuracy.low => context.cEmergency,
      GpsAccuracy.none => context.cDanger,
      GpsAccuracy.denied => context.cTextTertiary,
    };
  }

  String get _tooltip {
    if (!isActive) return "O'chirilgan";
    return switch (accuracy) {
      GpsAccuracy.high => 'Aniq',
      GpsAccuracy.medium => "O'rtacha",
      GpsAccuracy.low => 'Past',
      GpsAccuracy.none => "Yo'q",
      GpsAccuracy.denied => "Ruxsat yo'q",
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Tooltip(
      message: _tooltip,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
