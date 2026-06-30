import 'package:flutter/material.dart';
import 'package:trtravel/features/platform/services/platform_service.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, double width) mobile;
  final Widget Function(BuildContext context, double width)? tablet;
  final Widget Function(BuildContext context, double width)? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= PlatformService.desktopBreakpoint && desktop != null) {
          return desktop!(context, width);
        }
        if (width >= PlatformService.tabletBreakpoint && tablet != null) {
          return tablet!(context, width);
        }
        return mobile(context, width);
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing,
    this.runSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = PlatformService.gridColumns(width);
        final gap = spacing ?? PlatformService.gridSpacing(width);
        final runGap = runSpacing ?? PlatformService.gridSpacing(width);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding ?? PlatformService.responsivePadding(width),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: runGap,
            childAspectRatio: columns > 1 ? 1.2 : 1.5,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class ResponsiveSingleChild extends StatelessWidget {
  final Widget child;

  const ResponsiveSingleChild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Padding(
          padding: PlatformService.responsivePadding(width),
          child: child,
        );
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < PlatformService.tabletBreakpoint;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }

        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children
              .map((child) => Expanded(child: child))
              .toList(),
        );
      },
    );
  }
}
