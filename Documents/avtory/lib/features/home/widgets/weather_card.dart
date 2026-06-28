import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    this.temperature,
    this.condition,
    this.icon,
    this.isLoading = false,
  });

  final int? temperature;
  final String? condition;
  final String? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontal, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.cPrimary.withAlpha(15),
            context.cPrimaryDark.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.radiusLG),
        border: Border.all(
          color: context.cPrimary.withAlpha(25),
        ),
      ),
      child: Row(
        children: [
          AppIcon('device_thermostat_rounded',
              size: 20, color: context.cPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature != null ? '$temperature°C' : 'Ob-havo',
                  style: context.bodyMedium(color: context.cTextPrimary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                if (condition != null)
                  Text(
                    condition!,
                    style: context.bodySmall(color: context.cTextTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (temperature != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.cSurface.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tez kunda',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: context.cTextTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontal, vertical: 12),
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius: BorderRadius.circular(context.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.cBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: context.cBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
