import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/shared/widgets/empty_state.dart';
import '../services/budget_service.dart';
import '../models/budget_models.dart';
import '../widgets/expense_chart.dart';
import '../widgets/category_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Budget de Voyage',
            subtitle: 'Suivez vos dépenses',
            icon: Icons.account_balance_wallet_rounded,
          ),
          Expanded(
            child: Consumer<BudgetService>(
              builder: (_, service, __) {
                final report = service.generateReport();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildOverview(report),
                    const SizedBox(height: 16),
                    ExpenseChart(report: report),
                    const SizedBox(height: 16),
                    _buildCategoryBudgets(context, service, report),
                    const SizedBox(height: 16),
                    _buildRecentExpenses(service),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverview(BudgetReport report) {
    final progress = report.totalBudget > 0
        ? (report.totalSpent / report.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text('Budget Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${report.totalSpent.toStringAsFixed(0)} / ${report.totalBudget.toStringAsFixed(0)} TL',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Dépensé ${report.spendingRate.toStringAsFixed(0)}% du budget',
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: report.totalRemaining < 0 ? AppColors.error : Colors.white,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Restant: ${report.totalRemaining.toStringAsFixed(0)} TL',
              style: TextStyle(
                color: report.totalRemaining < 0 ? AppColors.error : Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgets(BuildContext context, BudgetService service, BudgetReport report) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget par catégorie', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('${service.expenses.length} dépenses',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            ...report.categories.map((cat) => CategoryCard(report: cat)),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => _showBudgetEditor(context, service),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier les budgets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(BudgetService service) {
    if (service.expenses.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Aucune dépense',
        subtitle: 'Ajoutez votre première dépense',
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dernières dépenses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            ...service.expenses.take(10).map((e) => ListTile(
              dense: true,
              leading: Text(_getCategoryEmoji(e.category), style: const TextStyle(fontSize: 24)),
              title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('${e.date.day}/${e.date.month}/${e.date.year}${e.city.isNotEmpty ? " - ${e.city}" : ""}'),
              trailing: Text(
                '-${e.amount.toStringAsFixed(0)} TL',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String id) {
    try {
      return ExpenseCategory.defaults.firstWhere((c) => c.id == id).emoji;
    } catch (_) {
      return '📦';
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    final categories = ExpenseCategory.defaults;
    String selectedCategory = 'food';
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: StatefulBuilder(
          builder: (_, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppColors.divider, borderRadius: BorderRadius.circular(2),
              ))),
              const SizedBox(height: 16),
              const Text('Nouvelle dépense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Catégorie', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((cat) => ChoiceChip(
                  avatar: Text(cat.emoji),
                  label: Text(cat.name),
                  selected: selectedCategory == cat.id,
                  onSelected: (_) => setDialogState(() => selectedCategory = cat.id),
                )).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (TL)', prefixText: '₺ '),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (descCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                      final expense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: selectedCategory,
                        description: descCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        date: DateTime.now(),
                      );
                      context.read<BudgetService>().addExpense(expense);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetEditor(BuildContext context, BudgetService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budgets par catégorie'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: service.categories.map((cat) {
              final ctrl = TextEditingController(text: cat.budget.toStringAsFixed(0));
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${cat.emoji} ${cat.name}', style: const TextStyle(fontSize: 14)),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                        onChanged: (v) {
                          final budget = double.tryParse(v);
                          if (budget != null) {
                            service.setCategoryBudget(cat.id, budget);
                          }
                        },
                      ),
                    ),
                    const Text(' TL', style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
