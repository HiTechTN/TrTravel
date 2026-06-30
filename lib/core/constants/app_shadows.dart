import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const BoxShadow small = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static List<BoxShadow> get cardShadows => [card];
  static List<BoxShadow> get smallShadows => [small];
  static List<BoxShadow> get mediumShadows => [medium];
  static List<BoxShadow> get largeShadows => [large];
}
