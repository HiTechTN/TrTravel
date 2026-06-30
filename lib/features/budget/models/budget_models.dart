class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final String currency;
  final DateTime date;
  final String city;

  const Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    this.currency = 'TRY',
    required this.date,
    this.city = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'description': description,
    'amount': amount,
    'currency': currency,
    'date': date.toIso8601String(),
    'city': city,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    category: json['category'] as String,
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'TRY',
    date: DateTime.parse(json['date'] as String),
    city: json['city'] as String? ?? '',
  );
}

class ExpenseCategory {
  final String id;
  final String name;
  final String emoji;
  final double budget;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.emoji,
    this.budget = 0,
  });

  static const List<ExpenseCategory> defaults = [
    ExpenseCategory(id: 'food', name: 'Repas', emoji: '🍽️', budget: 800),
    ExpenseCategory(id: 'transport', name: 'Transport', emoji: '🚕', budget: 500),
    ExpenseCategory(id: 'hotel', name: 'Hébergement', emoji: '🏨', budget: 2000),
    ExpenseCategory(id: 'activities', name: 'Activités', emoji: '🎟️', budget: 1000),
    ExpenseCategory(id: 'shopping', name: 'Shopping', emoji: '🛍️', budget: 1500),
    ExpenseCategory(id: 'other', name: 'Autres', emoji: '📦', budget: 500),
  ];
}

class BudgetReport {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final List<CategoryReport> categories;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetReport({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.categories,
    required this.fromDate,
    required this.toDate,
  });

  double get spendingRate => totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'totalBudget': totalBudget,
    'totalSpent': totalSpent,
    'totalRemaining': totalRemaining,
    'categories': categories.map((c) => c.toJson()).toList(),
    'fromDate': fromDate.toIso8601String(),
    'toDate': toDate.toIso8601String(),
  };

  factory BudgetReport.fromJson(Map<String, dynamic> json) => BudgetReport(
    totalBudget: (json['totalBudget'] as num).toDouble(),
    totalSpent: (json['totalSpent'] as num).toDouble(),
    totalRemaining: (json['totalRemaining'] as num).toDouble(),
    categories: (json['categories'] as List).map((c) => CategoryReport.fromJson(c)).toList(),
    fromDate: DateTime.parse(json['fromDate'] as String),
    toDate: DateTime.parse(json['toDate'] as String),
  );
}

class CategoryReport {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final double budget;
  final double spent;
  final int expenseCount;

  const CategoryReport({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.budget,
    required this.spent,
    this.expenseCount = 0,
  });

  double get remaining => budget - spent;
  double get percentage => budget > 0 ? (spent / budget) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'emoji': emoji,
    'budget': budget,
    'spent': spent,
    'expenseCount': expenseCount,
  };

  factory CategoryReport.fromJson(Map<String, dynamic> json) => CategoryReport(
    categoryId: json['categoryId'] as String,
    categoryName: json['categoryName'] as String,
    emoji: json['emoji'] as String,
    budget: (json['budget'] as num).toDouble(),
    spent: (json['spent'] as num).toDouble(),
    expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
  );
}
