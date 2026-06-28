import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/design_tokens.dart';

class DsShimmerBox extends StatelessWidget {
  const DsShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.cBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class DsShimmerCircle extends StatelessWidget {
  const DsShimmerCircle({
    super.key,
    required this.radius,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: context.cBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

class DsShimmerSurface extends StatelessWidget {
  const DsShimmerSurface({
    super.key,
    this.width,
    this.height,
    this.radius = 16,
    this.padding,
    this.margin,
    this.child,
  });

  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(context.spLG),
      decoration: BoxDecoration(
        color: context.cBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class DsShimmer extends StatelessWidget {
  const DsShimmer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark ? context.cFieldFill : context.cBorder,
      highlightColor: context.isDark ? context.cBorder : context.cSurface,
      child: child,
    );
  }
}

class DsListSkeleton extends StatelessWidget {
  const DsListSkeleton({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return DsShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: context.spLG),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) =>
            SizedBox(height: context.spMD),
        itemBuilder: (_, __) => DsShimmerSurface(
          height: 80,
          padding: EdgeInsets.all(context.spMD),
        ),
      ),
    );
  }
}

class DsCardSkeleton extends StatelessWidget {
  const DsCardSkeleton({
    super.key,
    this.height = 120,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return DsShimmer(
      child: DsShimmerSurface(
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: context.spMD),
      ),
    );
  }
}

class DsProfileSkeleton extends StatelessWidget {
  const DsProfileSkeleton({super.key});


  @override
  Widget build(BuildContext context) {
    return DsShimmer(
      child: Column(
        children: [
          DsShimmerSurface(
            height: 180,
            margin: EdgeInsets.fromLTRB(
                context.spLG, context.spLG, context.spLG, context.spMD),
            padding: EdgeInsets.all(context.spXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DsShimmerCircle(radius: 32),
                const SizedBox(height: 12),
                DsShimmerBox(width: 160, height: 16),
                const SizedBox(height: 8),
                DsShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
          DsShimmerSurface(
            height: 100,
            margin: EdgeInsets.fromLTRB(
                context.spLG, 0, context.spLG, context.spMD),
          ),
          DsShimmerSurface(
            height: 200,
            margin: EdgeInsets.fromLTRB(
                context.spLG, 0, context.spLG, context.spMD),
          ),
        ],
      ),
    );
  }
}
