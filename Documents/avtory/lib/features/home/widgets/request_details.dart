import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_typography.dart';
import '../../../shared/widgets/app_icon.dart';

class RequestDetails extends StatelessWidget {
  const RequestDetails({
    super.key,
    required this.problemType,
    this.vehicleInfo,
    this.plateNumber,
    this.requestTime,
    this.requestId,
    this.notes,
  });

  final String problemType;
  final String? vehicleInfo;
  final String? plateNumber;
  final String? requestTime;
  final String? requestId;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius: BorderRadius.circular(context.radiusLG),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: 'build_rounded',
            label: 'Muammo turi',
            value: problemType,
          ),
          if (vehicleInfo != null) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            _DetailRow(
              icon: 'directions_car_rounded',
              label: 'Avtomobil',
              value: vehicleInfo!,
            ),
          ],
          if (plateNumber != null) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            _DetailRow(
              icon: 'local_parking_rounded',
              label: 'Davlat raqami',
              value: plateNumber!,
            ),
          ],
          if (requestTime != null) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            _DetailRow(
              icon: 'access_time',
              label: 'Yaratilgan vaqt',
              value: requestTime!,
            ),
          ],
          if (notes != null) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            _DetailRow(
              icon: 'notes_rounded',
              label: 'Izoh',
              value: notes!,
            ),
          ],
          if (requestId != null) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            _DetailRow(
              icon: 'vpn_key_rounded',
              label: 'ID',
              value: '#$requestId',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.cPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(context.radiusSM),
          ),
        child: AppIcon(icon,
            size: 16, color: context.cPrimary),
        ),
        SizedBox(width: context.spMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.labelSmall(color: context.cTextTertiary)
                    .copyWith(letterSpacing: 0.3),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.bodySmall(color: context.cTextPrimary)
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
