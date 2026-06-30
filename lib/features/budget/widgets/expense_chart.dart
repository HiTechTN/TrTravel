import 'dart:math';
import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/features/budget/models/budget_models.dart';

class ExpenseChart extends StatelessWidget {
  final BudgetReport report;

  const ExpenseChart({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.totalSpent <= 0) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Répartition des dépenses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 8),
                    Text('Aucune dépense à afficher',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasSpending = report.categories.any((c) => c.spent > 0);
    if (!hasSpending) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Répartition des dépenses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: _PieChartPainter(report.categories),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: report.categories
                          .where((c) => c.spent > 0)
                          .take(4)
                          .map((c) => _buildLegendItem(c))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(CategoryReport cat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: _colorForIndex(report.categories.indexOf(cat)),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(cat.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              cat.categoryName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${cat.spent.toStringAsFixed(0)} TL',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static Color _colorForIndex(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.gold,
      AppColors.mosque,
      AppColors.museum,
      AppColors.food,
    ];
    return colors[index % colors.length];
  }
}

class _PieChartPainter extends CustomPainter {
  final List<CategoryReport> categories;

  _PieChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final total = categories.fold(0.0, (sum, c) => sum + c.spent);

    if (total <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      if (cat.spent <= 0) continue;

      final sweepAngle = (cat.spent / total) * 2 * pi;
      final paint = Paint()
        ..color = _PieChartPainter._colorForIndex(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, innerPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: total.toStringAsFixed(0),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2 - 8));

    final subPainter = TextPainter(
      text: const TextSpan(
        text: 'TL',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    subPainter.layout();
    subPainter.paint(canvas, center - Offset(subPainter.width / 2, 6));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => oldDelegate.categories != categories;

  static Color _colorForIndex(int index) {
    const colors = [
      Color(0xFFE30A17),
      Color(0xFF003B66),
      Color(0xFFFFB800),
      Color(0xFF059669),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
    ];
    return colors[index % colors.length];
  }
}
