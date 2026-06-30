import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/features/budget/models/budget_models.dart';

class CategoryCard extends StatelessWidget {
  final CategoryReport report;

  const CategoryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final progress = report.budget > 0
        ? (report.spent / report.budget).clamp(0.0, 1.0)
        : 0.0;
    final isOver = report.spent > report.budget && report.budget > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(report.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (report.expenseCount > 0)
                      Text('${report.expenseCount} dépense(s)',
                          style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${report.spent.toStringAsFixed(0)} / ${report.budget.toStringAsFixed(0)} TL',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOver ? AppColors.error : AppColors.textSecondary,
                        fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
                      )),
                  Text('${report.remaining.toStringAsFixed(0)} restant',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOver ? AppColors.error : AppColors.success,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              color: isOver ? AppColors.error : AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
