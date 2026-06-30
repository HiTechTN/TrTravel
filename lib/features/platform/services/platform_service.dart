import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:trtravel/features/platform/models/platform_models.dart';

class PlatformService extends ChangeNotifier {
  static PlatformConfig get config => _cachedConfig;
  static PlatformConfig _cachedConfig = PlatformConfig.detect();

  PlatformConfig _currentConfig = PlatformConfig.detect();

  PlatformConfig get currentConfig => _currentConfig;

  void detectPlatform() {
    _cachedConfig = PlatformConfig.detect();
    _currentConfig = _cachedConfig;
    notifyListeners();
  }

  static bool get isMobile => config.isMobile;
  static bool get isDesktop => config.isDesktop;
  static bool get isWeb => config.isWeb;

  static String get platformName => config.platformName;

  static bool get isIOS => config.isIOS;
  static bool get isAndroid => config.isAndroid;

  static bool get usesCupertino =>
      !kIsWeb && config.isIOS;

  static Brightness? _cachedPlatformBrightness;

  static void cachePlatformBrightness(BuildContext context) {
    _cachedPlatformBrightness = Theme.of(context).brightness;
  }

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static ScreenSize getScreenSize(double width) {
    return PlatformConfig.getScreenSize(width);
  }

  static bool isMobileSize(double width) => width < mobileBreakpoint;
  static bool isTabletSize(double width) =>
      width >= mobileBreakpoint && width < tabletBreakpoint;
  static bool isDesktopSize(double width) =>
      width >= tabletBreakpoint && width < desktopBreakpoint;
  static bool isXLargeSize(double width) => width >= desktopBreakpoint;

  static double responsiveValue<T>({
    required double width,
    required double mobile,
    double? tablet,
    double? desktop,
    double? xlarge,
  }) {
    if (width >= desktopBreakpoint && xlarge != null) return xlarge;
    if (width >= tabletBreakpoint && desktop != null) return desktop;
    if (width >= mobileBreakpoint && tablet != null) return tablet;
    return mobile;
  }

  static EdgeInsets responsivePadding(double width) {
    if (width >= desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
    }
    if (width >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  static double responsiveFontSize(double width, {double base = 14}) {
    if (width >= desktopBreakpoint) return base + 4;
    if (width >= tabletBreakpoint) return base + 2;
    return base;
  }

  static int gridColumns(double width) {
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }

  static double gridSpacing(double width) {
    if (width >= desktopBreakpoint) return 20;
    if (width >= tabletBreakpoint) return 16;
    return 12;
  }
}
