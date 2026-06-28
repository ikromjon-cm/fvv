import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';

class RatingSkeleton extends StatelessWidget {
  const RatingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _circleShimmer(context, 96),
          const SizedBox(height: 20),
          _boxShimmer(context, 180, 20, 4),
          const SizedBox(height: 8),
          _boxShimmer(context, 120, 14, 4),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _circleShimmer(context, 48),
            )),
          ),
          const SizedBox(height: 40),
          _boxShimmer(context, double.infinity, 80, DesignTokens.radiusMD),
          const SizedBox(height: 24),
          _boxShimmer(context, double.infinity, 56, DesignTokens.radiusMD),
        ],
      ),
    );
  }

  Widget _circleShimmer(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.cFieldFill,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _boxShimmer(BuildContext context, double w, double h, double r) {
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
