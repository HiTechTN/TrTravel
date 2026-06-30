import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';

class QuickReplies extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  final double spacing;
  final double runSpacing;

  const QuickReplies({
    super.key,
    required this.suggestions,
    required this.onTap,
    this.spacing = 8,
    this.runSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: suggestions.map((suggestion) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(suggestion),
              borderRadius: BorderRadius.circular(AppRadius.round),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
