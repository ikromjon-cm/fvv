import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';

class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _buildShimmerCard(context),
        childCount: itemCount,
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(context, 44, 44, DesignTokens.radiusFull),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, 120, 14, 4),
                    const SizedBox(height: 6),
                    _shimmerBox(context, 80, 10, 4),
                  ],
                ),
              ),
              _shimmerBox(context, 80, 28, DesignTokens.radiusFull),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(context, 160, 10, 4),
          const SizedBox(height: 10),
          Row(
            children: [
              _shimmerBox(context, 60, 10, 4),
              const SizedBox(width: 12),
              _shimmerBox(context, 50, 10, 4),
              const Spacer(),
              _shimmerBox(context, 40, 10, 4),
            ],
          ),
        ],
      ),
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
