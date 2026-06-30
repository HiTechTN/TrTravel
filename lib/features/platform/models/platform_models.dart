import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum PlatformType {
  mobileAndroid,
  mobileIOS,
  web,
  desktopLinux,
  desktopMacOS,
  desktopWindows,
}

enum ScreenSize { small, medium, large, xlarge }

class PlatformConfig {
  final bool isMobile;
  final bool isDesktop;
  final bool isWeb;
  final ScreenSize screenSize;
  final String platformName;

  const PlatformConfig({
    this.isMobile = false,
    this.isDesktop = false,
    this.isWeb = false,
    this.screenSize = ScreenSize.small,
    this.platformName = 'unknown',
  });

  bool get isAndroid => platformName == 'android';
  bool get isIOS => platformName == 'ios';
  bool get isLinux => platformName == 'linux';
  bool get isMacOS => platformName == 'macos';
  bool get isWindows => platformName == 'windows';

  static PlatformConfig detect() {
    if (kIsWeb) {
      return const PlatformConfig(
        isWeb: true,
        isDesktop: false,
        isMobile: false,
        platformName: 'web',
      );
    }

    try {
      if (Platform.isAndroid) {
        return const PlatformConfig(
          isMobile: true,
          platformName: 'android',
        );
      }
      if (Platform.isIOS) {
        return const PlatformConfig(
          isMobile: true,
          platformName: 'ios',
        );
      }
      if (Platform.isLinux) {
        return const PlatformConfig(
          isDesktop: true,
          platformName: 'linux',
        );
      }
      if (Platform.isMacOS) {
        return const PlatformConfig(
          isDesktop: true,
          platformName: 'macos',
        );
      }
      if (Platform.isWindows) {
        return const PlatformConfig(
          isDesktop: true,
          platformName: 'windows',
        );
      }
    } catch (_) {}

    return const PlatformConfig();
  }

  static ScreenSize getScreenSize(double width) {
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.large;
    return ScreenSize.xlarge;
  }

  static double getColumnCount(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.large:
      case ScreenSize.xlarge:
        return 3;
    }
  }

  static double getColumnWidth(ScreenSize size, double totalWidth) {
    final count = getColumnCount(size);
    final padding = size == ScreenSize.small ? 32.0 : 48.0;
    final gap = (count - 1) * 16.0;
    return (totalWidth - padding - gap) / count;
  }
}
