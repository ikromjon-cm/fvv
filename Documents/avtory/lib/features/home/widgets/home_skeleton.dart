import 'package:flutter/material.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/responsive/adaptive_spacing.dart';

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildAppBarSkeleton(),
              SizedBox(height: context.sectionGap),
              _buildCardSkeleton(190),
              SizedBox(height: context.sectionGap),
              _buildSearchSkeleton(),
              SizedBox(height: context.sectionGap),
              _buildActionGridSkeleton(),
              const SizedBox(height: 28),
              _buildProblemGridSkeleton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer(double width, double height, [double radius = 8]) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.cBorder.withAlpha((80 * _anim.value).round()),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildAppBarSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildShimmer(44, 44, 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmer(120, 14),
              const SizedBox(height: 6),
              _buildShimmer(80, 10),
            ],
          ),
          const Spacer(),
          _buildShimmer(44, 44, 22),
          const SizedBox(width: 8),
          _buildShimmer(44, 44, 22),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildShimmer(double.infinity, height, 20),
    );
  }

  Widget _buildSearchSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildShimmer(double.infinity, 54, 16),
    );
  }

  Widget _buildActionGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (_) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: _ == 0 ? 0 : 6, right: _ == 2 ? 0 : 6),
            child: _buildShimmer(double.infinity, 100, 18),
          ),
        )),
      ),
    );
  }

  Widget _buildProblemGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmer(100, 18),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => _buildShimmer(double.infinity, double.infinity, 16),
          ),
        ],
      ),
    );
  }
}
