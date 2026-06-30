import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/budget/models/budget_models.dart';
import 'package:trtravel/features/currency/services/currency_service.dart';

class BudgetService extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = ExpenseCategory.defaults;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<ExpenseCategory> get categories => _categories;

  BudgetService() {
    _load();
  }

  void _load() {
    final jsonList = LocalStorage.getJsonList('budget_expenses');
    if (jsonList != null) {
      _expenses = jsonList.map((j) => Expense.fromJson(j)).toList();
    }
    _loadCategories();
  }

  void _loadCategories() {
    final jsonList = LocalStorage.getJsonList('budget_categories');
    if (jsonList != null) {
      _categories = jsonList.map((j) => ExpenseCategory(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        budget: (j['budget'] as num).toDouble(),
      )).toList();
    }
  }

  void _save() {
    LocalStorage.setJsonList('budget_expenses', _expenses.map((e) => e.toJson()).toList());
    LocalStorage.setJsonList('budget_categories', _categories.map((c) => {
      'id': c.id, 'name': c.name, 'emoji': c.emoji, 'budget': c.budget,
    }).toList());
    _syncToFirestore();
  }

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _save();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void setCategoryBudget(String id, double budget) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = ExpenseCategory(
        id: _categories[index].id,
        name: _categories[index].name,
        emoji: _categories[index].emoji,
        budget: budget,
      );
      _save();
      notifyListeners();
    }
  }

  double getTotalSpent() => _expenses.fold(0.0, (s, e) => s + e.amount);
  double getTotalBudget() => _categories.fold(0.0, (s, c) => s + c.budget);

  double getSpentByCategory(String categoryId) {
    return _expenses
        .where((e) => e.category == categoryId)
        .fold(0.0, (s, e) => s + e.amount);
  }

  int getExpenseCountByCategory(String categoryId) {
    return _expenses.where((e) => e.category == categoryId).length;
  }

  double getRemainingBudget() => getTotalBudget() - getTotalSpent();

  double getRemainingByCategory(String categoryId) {
    final cat = _categories.firstWhere((c) => c.id == categoryId,
        orElse: () => const ExpenseCategory(id: '', name: '', emoji: '', budget: 0));
    return cat.budget - getSpentByCategory(categoryId);
  }

  BudgetReport generateReport({DateTime? from, DateTime? to}) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year, now.month, 1);
    final toDate = to ?? now;

    final filtered = _expenses.where((e) =>
      !e.date.isBefore(fromDate) && !e.date.isAfter(toDate)
    ).toList();

    final categoryReports = _categories.map((cat) {
      final catExpenses = filtered.where((e) => e.category == cat.id).toList();
      final spent = catExpenses.fold(0.0, (s, e) => s + e.amount);
      return CategoryReport(
        categoryId: cat.id,
        categoryName: cat.name,
        emoji: cat.emoji,
        budget: cat.budget,
        spent: spent,
        expenseCount: catExpenses.length,
      );
    }).toList();

    final totalSpent = filtered.fold(0.0, (s, e) => s + e.amount);
    final totalBudget = _categories.fold(0.0, (s, c) => s + c.budget);

    return BudgetReport(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalRemaining: totalBudget - totalSpent,
      categories: categoryReports,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  List<Map<String, dynamic>> getDailySpending(int days) {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      final total = _expenses
          .where((e) => !e.date.isBefore(dayStart) && !e.date.isAfter(dayEnd))
          .fold(0.0, (s, e) => s + e.amount);
      result.add({
        'date': dayStart,
        'total': total,
        'label': '${dayStart.day}/${dayStart.month}',
      });
    }
    return result;
  }

  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    final curService = CurrencyService();
    final fromRate = curService.getRateFor(fromCurrency);
    final toRate = curService.getRateFor(toCurrency);
    if (fromRate == 0 || toRate == 0) return amount;
    final inEur = amount / fromRate;
    return inEur * toRate;
  }

  void clearAll() {
    _expenses.clear();
    _save();
    notifyListeners();
  }

  Future<void> _syncToFirestore() async {
    try {
      final user = LocalStorage.getString('auth_user_id');
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('budget')
          .doc('expenses')
          .set({
        'expenses': _expenses.map((e) => e.toJson()).toList(),
        'categories': _categories.map((c) => {
          'id': c.id, 'name': c.name, 'emoji': c.emoji, 'budget': c.budget,
        }).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LogService.warning('BudgetService', 'Firestore sync failed: $e');
    }
  }

  Future<void> syncFromFirestore() async {
    try {
      final user = LocalStorage.getString('auth_user_id');
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('budget')
          .doc('expenses')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final remoteExpenses = (data['expenses'] as List?)
            ?.map((j) => Expense.fromJson(j as Map<String, dynamic>))
            .toList();
        if (remoteExpenses != null && remoteExpenses.isNotEmpty) {
          _expenses = remoteExpenses;
          _save();
          notifyListeners();
        }
      }
    } catch (e) {
      LogService.warning('BudgetService', 'Firestore sync from failed: $e');
    }
  }
}
