import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';

class MechanicDashboardSkeleton extends StatelessWidget {
  const MechanicDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _statusCardShimmer(context)),
        SliverToBoxAdapter(child: SizedBox(height: context.spMD)),
        SliverToBoxAdapter(child: _statsRowShimmer(context)),
        SliverToBoxAdapter(child: SizedBox(height: context.spLG)),
        SliverToBoxAdapter(child: _earningsCardShimmer(context)),
        SliverToBoxAdapter(child: SizedBox(height: context.spLG)),
        SliverToBoxAdapter(child: _quickActionsShimmer(context)),
        SliverToBoxAdapter(child: SizedBox(height: context.spLG)),
        SliverToBoxAdapter(child: _sectionTitleShimmer(context)),
        SliverToBoxAdapter(child: SizedBox(height: context.spSM)),
        SliverToBoxAdapter(child: _requestCardShimmer(context)),
        SliverToBoxAdapter(child: const SizedBox(height: 12)),
        SliverToBoxAdapter(child: _requestCardShimmer(context)),
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

  Widget _statusCardShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.screenHorizontal, context.spSM, context.screenHorizontal, 0),
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spLG),
          child: Row(
            children: [
              _shimmerBox(context, 52, 52, 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _shimmerBox(context, 100, 18, 4),
                    const SizedBox(height: 6),
                    _shimmerBox(context, 140, 12, 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRowShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Row(
        children: [
          Expanded(child: _shimmerBox(context, double.infinity, 92, DesignTokens.radiusMD)),
          const SizedBox(width: 8),
          Expanded(child: _shimmerBox(context, double.infinity, 92, DesignTokens.radiusMD)),
          const SizedBox(width: 8),
          Expanded(child: _shimmerBox(context, double.infinity, 92, DesignTokens.radiusMD)),
        ],
      ),
    );
  }

  Widget _earningsCardShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        ),
        padding: EdgeInsets.all(context.spLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(context, 80, 12, 4),
            const SizedBox(height: 8),
            _shimmerBox(context, 120, 28, 4),
            const SizedBox(height: 8),
            _shimmerBox(context, 60, 12, 4),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(context, 100, 14, 4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _shimmerBox(context, double.infinity, 60, DesignTokens.radiusMD)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(context, double.infinity, 60, DesignTokens.radiusMD)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitleShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: _shimmerBox(context, 120, 14, 4),
    );
  }

  Widget _requestCardShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenHorizontal),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
          border: Border.all(color: context.cBorder),
        ),
        padding: EdgeInsets.all(context.spMD),
        child: Column(
          children: [
            Row(
              children: [
                _shimmerBox(context, 48, 48, 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(context, 100, 14, 4),
                      const SizedBox(height: 6),
                      _shimmerBox(context, 60, 10, 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _shimmerBox(context, 160, 10, 4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _shimmerBox(context, double.infinity, 40, DesignTokens.radiusMD)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _shimmerBox(context, double.infinity, 40, DesignTokens.radiusMD)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
