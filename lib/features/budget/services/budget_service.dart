import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/features/budget/models/budget_models.dart';

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

  double getTotalSpent() => _expenses.fold(0, (sum, e) => sum + e.amount);
  double getTotalBudget() => _categories.fold(0, (sum, c) => sum + c.budget);

  double getSpentByCategory(String categoryId) {
    return _expenses
        .where((e) => e.category == categoryId)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getRemainingBudget() => getTotalBudget() - getTotalSpent();

  void clearAll() {
    _expenses.clear();
    _save();
    notifyListeners();
  }
}
