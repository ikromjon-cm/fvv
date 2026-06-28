import 'package:flutter/material.dart';

class ActiveRequestSkeleton extends StatefulWidget {
  const ActiveRequestSkeleton({super.key});

  @override
  State<ActiveRequestSkeleton> createState() => _ActiveRequestSkeletonState();
}

class _ActiveRequestSkeletonState extends State<ActiveRequestSkeleton>
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
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _shimmer(double.infinity, 80, 20),
              const SizedBox(height: 16),
              _shimmer(double.infinity, 60, 16),
              const SizedBox(height: 16),
              _shimmer(double.infinity, 160, 18),
              const SizedBox(height: 16),
              _shimmer(double.infinity, 200, 18),
              const SizedBox(height: 16),
              _shimmer(double.infinity, 64, 16),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmer(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0)
            .withAlpha((255 * _anim.value).round()),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
