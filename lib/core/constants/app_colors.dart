import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC62828);
  static const Color primaryDark = Color(0xFF8E0000);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color secondary = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF5472D3);
  static const Color accent = Color(0xFFFF8F00);
  static const Color accentLight = Color(0xFFFFC046);

  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;
  static const Color surfaceContainer = Color(0xFFF0F2F8);
  static const Color surfaceDark = Color(0xFF16162A);
  static const Color surfaceDarkContainer = Color(0xFF1E1E38);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color divider = Color(0xFFE8EAF0);
  static const Color shimmer = Color(0xFFE8EAF0);

  static const Color textOnPrimary = Colors.white;
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color gold = Color(0xFFFF8F00);
  static const Color mosque = Color(0xFF059669);
  static const Color museum = Color(0xFF7C3AED);
  static const Color food = Color(0xFFF97316);
  static const Color shop = Color(0xFFEC4899);
  static const Color transport = Color(0xFF06B6D4);
  static const Color hotel = Color(0xFF6366F1);
  static const Color nature = Color(0xFF22C55E);

  static const List<Color> primaryGradient = [primary, Color(0xFFE53935)];
  static const List<Color> glassLight = [Color(0xFAFFFFFF), Color(0x8CF0F2F8)];
  static const List<Color> glassDark = [Color(0xFA1A1A2E), Color(0x8C232340)];
  static const List<Color> sunsetGradient = [primary, gold];
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get header => [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get subtle => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ];
}

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    colors: [AppColors.primary, Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryDark = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunset = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ocean = LinearGradient(
    colors: [AppColors.secondary, Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warm = LinearGradient(
    colors: [AppColors.accent, Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardDark = LinearGradient(
    colors: [Color(0xFF1E1E38), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets page = EdgeInsets.all(md);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: md, vertical: 12);
}
