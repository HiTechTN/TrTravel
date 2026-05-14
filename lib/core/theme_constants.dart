import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE30A17);
  static const Color primaryDark = Color(0xFFB00812);
  static const Color secondary = Color(0xFF003B66);
  static const Color secondaryDark = Color(0xFF002244);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color divider = Color(0xFFE8EAF0);
  static const Color disabled = Color(0xFFC5C6D0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> primaryGradientList = [primary, secondary];
}

class AppShadows {
  static BoxShadow get card => BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  static BoxShadow get navigation => BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 8,
    offset: const Offset(0, -2),
  );
}

class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 24;
}
