import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.desktop,
  });

  final Widget Function(BuildContext context, double width) compact;
  final Widget Function(BuildContext context, double width)? medium;
  final Widget Function(BuildContext context, double width)? expanded;
  final Widget Function(BuildContext context, double width)? large;
  final Widget Function(BuildContext context, double width)? extraLarge;
  final Widget Function(BuildContext context, double width)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (desktop != null && w >= Breakpoints.desktop) return desktop!(context, w);
        if (extraLarge != null && w >= Breakpoints.extraLarge) return extraLarge!(context, w);
        if (large != null && w >= Breakpoints.large) return large!(context, w);
        if (expanded != null && w >= Breakpoints.expanded) return expanded!(context, w);
        if (medium != null && w >= Breakpoints.medium) return medium!(context, w);
        return compact(context, w);
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.compactColumns = 1,
    this.expandedColumns,
    this.spacing = 12,
    this.runSpacing = 12,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final List<Widget> children;
  final double compactColumns;
  final double? expandedColumns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final columns = context.isPhone
        ? compactColumns
        : (expandedColumns ?? compactColumns * 2);
    final effectiveColumns = columns.toInt().clamp(1, children.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (effectiveColumns - 1)) / effectiveColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({
    super.key,
    required this.child,
    required this.compact,
    this.expanded,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final EdgeInsets compact;
  final EdgeInsets? expanded;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    EdgeInsets padding;
    if (desktop != null && w >= Breakpoints.desktop) {
      padding = desktop!;
    } else if (tablet != null && w >= Breakpoints.large) {
      padding = tablet!;
    } else if (expanded != null && w >= Breakpoints.expanded) {
      padding = expanded!;
    } else {
      padding = compact;
    }
    return Padding(padding: padding, child: child);
  }
}

class ResponsiveSliverPadding extends StatelessWidget {
  const ResponsiveSliverPadding({super.key, required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.isPhone
            ? 16
            : context.isTablet
                ? 32
                : 48,
      ),
      sliver: sliver,
    );
  }
}

class ResponsiveList extends StatelessWidget {
  const ResponsiveList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.spacing = 12,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= Breakpoints.large;
        final columns = isWide ? 2 : 1;

        return ListView(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: context.isPhone ? 16 : 32,
                vertical: 8,
              ),
          children: [
            for (int i = 0; i < itemCount; i += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int j = 0; j < columns && i + j < itemCount; j++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: j > 0 ? spacing : 0,
                          bottom: spacing,
                        ),
                        child: itemBuilder(context, i + j),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
