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
    ExpenseCategory(id: 'hotel', name: 'Hébergement', emoji: '🏨', budget: 2000),
    ExpenseCategory(id: 'food', name: 'Repas', emoji: '🍽️', budget: 800),
    ExpenseCategory(id: 'transport', name: 'Transport', emoji: '🚕', budget: 500),
    ExpenseCategory(id: 'activities', name: 'Activités', emoji: '🎟️', budget: 1000),
    ExpenseCategory(id: 'shopping', name: 'Shopping', emoji: '🛍️', budget: 1500),
    ExpenseCategory(id: 'other', name: 'Autres', emoji: '📦', budget: 500),
  ];
}
