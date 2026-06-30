import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trtravel/core/constants/app_colors.dart';

class FloatingTravelAssistant extends StatelessWidget {
  final VoidCallback onQuickActions;

  const FloatingTravelAssistant({
    super.key,
    required this.onQuickActions,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onQuickActions();
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      child: const Icon(Icons.flash_on_rounded, size: 28),
    );
  }
}
