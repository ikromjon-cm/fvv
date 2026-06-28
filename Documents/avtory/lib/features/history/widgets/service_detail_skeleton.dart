import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';

class ServiceDetailSkeleton extends StatelessWidget {
  const ServiceDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(context, double.infinity, 180, DesignTokens.radiusLG),
          const SizedBox(height: 16),
          _shimmerBox(context, 100, 14, 4),
          const SizedBox(height: 12),
          _shimmerBox(context, double.infinity, 120, DesignTokens.radiusLG),
          const SizedBox(height: 16),
          _shimmerBox(context, 80, 14, 4),
          const SizedBox(height: 12),
          ...List.generate(4, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _timelineShimmerRow(context),
          )),
          const SizedBox(height: 16),
          _shimmerBox(context, double.infinity, 100, DesignTokens.radiusLG),
          const SizedBox(height: 24),
          _shimmerBox(context, double.infinity, 56, DesignTokens.radiusMD),
        ],
      ),
    );
  }

  Widget _timelineShimmerRow(BuildContext context) {
    return Row(
      children: [
        _shimmerBox(context, 40, 40, DesignTokens.radiusFull),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(context, 140, 12, 4),
              const SizedBox(height: 4),
              _shimmerBox(context, 60, 10, 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(BuildContext context, double w, double h, double r) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: context.cFieldFill,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
