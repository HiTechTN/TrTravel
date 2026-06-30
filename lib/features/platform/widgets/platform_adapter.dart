import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:trtravel/features/platform/services/platform_service.dart';

class PlatformAdapter extends StatelessWidget {
  final Widget Function(BuildContext) material;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? desktopPadding;
  final double? mobileFontSize;
  final double? desktopFontSize;
  final bool useInsetPadding;

  const PlatformAdapter({
    super.key,
    required this.material,
    this.mobilePadding,
    this.desktopPadding,
    this.mobileFontSize,
    this.desktopFontSize,
    this.useInsetPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformService.isDesktop;
    final width = MediaQuery.of(context).size.width;

    if (useInsetPadding && isDesktop) {
      return Padding(
        padding: desktopPadding ??
            PlatformService.responsivePadding(width),
        child: material(context),
      );
    }

    if (useInsetPadding && !isDesktop) {
      return Padding(
        padding: mobilePadding ??
            PlatformService.responsivePadding(width),
        child: material(context),
      );
    }

    return material(context);
  }
}

class PlatformHint extends StatelessWidget {
  final Widget mobile;
  final Widget? desktop;

  const PlatformHint({
    super.key,
    required this.mobile,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isDesktop && desktop != null) {
      return desktop!;
    }
    return mobile;
  }
}

class PlatformScrollBehavior extends StatelessWidget {
  final Widget child;

  const PlatformScrollBehavior({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isDesktop) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: true,
          overscroll: false,
          dragDevices: {
            ui.PointerDeviceKind.touch,
            ui.PointerDeviceKind.mouse,
            ui.PointerDeviceKind.trackpad,
          },
        ),
        child: child,
      );
    }
    return child;
  }
}

class PlatformSizedBox extends StatelessWidget {
  final double? mobileWidth;
  final double? mobileHeight;
  final double? desktopWidth;
  final double? desktopHeight;
  final Widget? child;

  const PlatformSizedBox({
    super.key,
    this.mobileWidth,
    this.mobileHeight,
    this.desktopWidth,
    this.desktopHeight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformService.isDesktop;
    return SizedBox(
      width: isDesktop ? desktopWidth : mobileWidth,
      height: isDesktop ? desktopHeight : mobileHeight,
      child: child,
    );
  }
}

class PlatformGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const PlatformGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isDesktop && onDoubleTap == null && onLongPress == null) {
      return InkWell(
        onTap: onTap,
        child: child,
      );
    }
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}
