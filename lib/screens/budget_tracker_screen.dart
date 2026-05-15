import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({super.key});

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  List<Expense> _expenses = [];
  double _dailyBudget = 0;
  bool _loaded = false;

  static const _categories = [
    ('H\u00E9bergement', Icons.hotel, const Color(0xFF003B66)),
    ('Transport', Icons.directions_bus, const Color(0xFFE30A17)),
    ('Nourriture', Icons.restaurant, const Color(0xFF2E7D32)),
    ('Visites', Icons.museum, const Color(0xFF6A1B9A)),
    ('Shopping', Icons.shopping_bag, const Color(0xFFFF6F00)),
    ('Activit\u00E9s', Icons.sports_esports, const Color(0xFF00838F)),
    ('Divers', Icons.more_horiz, Colors.grey),
  ];

  static const _currencySymbol = '\u20BA';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('budget_expenses');
    if (expensesJson != null) {
      final decoded = json.decode(expensesJson) as List;
      _expenses = decoded.map((e) => Expense.fromJson(e)).toList();
    }
    _dailyBudget = prefs.getDouble('daily_budget') ?? 1500;
    setState(() => _loaded = true);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('budget_expenses', json.encode(_expenses.map((e) => e.toJson()).toList()));
    await prefs.setDouble('daily_budget', _dailyBudget);
  }

  Future<void> _addExpense() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = _categories[0].$1;
    final dateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter une d\u00E9pense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'D\u00E9pense', border: OutlineInputBorder()), autofocus: true),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Montant ($_currencySymbol)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Cat\u00E9gorie', border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$1))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (jj/mm/aaaa)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || amountCtrl.text.trim().isEmpty) return;
                final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return;
                Navigator.pop(ctx, {
                  'name': nameCtrl.text.trim(),
                  'amount': amount,
                  'category': selectedCategory,
                  'date': dateCtrl.text.trim(),
                });
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _expenses.add(Expense(
          name: result['name'],
          amount: result['amount'],
          category: result['category'],
          date: result['date'],
        ));
      });
      await _saveData();
    }
  }

  Future<void> _setBudget() async {
    final ctrl = TextEditingController(text: _dailyBudget.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget journalier'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Budget par jour ($_currencySymbol)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _dailyBudget = result);
      await _saveData();
    }
  }

  Future<void> _deleteExpense(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer \u00AB ${_expenses[index].name} \u00BB ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _expenses.removeAt(index));
      await _saveData();
    }
  }

  double get _totalSpent => _expenses.fold(0, (sum, e) => sum + e.amount);
  Map<String, double> get _byCategory {
    final m = <String, double>{};
    for (final e in _expenses) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final todayExpenses = _expenses.where((e) => e.date == today).fold<double>(0, (s, e) => s + e.amount);
    final remaining = _dailyBudget - todayExpenses;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFFE65100),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFE65100), Color(0xFFFF6F00)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Budget de voyage',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _setBudget,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$_currencySymbol${_dailyBudget.toStringAsFixed(0)}/j',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, color: Colors.white70, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayCard(todayExpenses, remaining),
                  const SizedBox(height: 20),
                  _buildSummary(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, size: 20, color: Color(0xFFE65100)),
                      const SizedBox(width: 8),
                      const Text('D\u00E9penses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const Spacer(),
                      Text('${_totalSpent.toStringAsFixed(0)} $_currencySymbol',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_expenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('Aucune d\u00E9pense enregistr\u00E9e', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_expenses.length, (i) {
                      final e = _expenses[i];
                      final cat = _categories.firstWhere((c) => c.$1 == e.category, orElse: () => _categories.last);
                      return Dismissible(
                        key: Key('${e.name}_$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        onDismissed: (_) => _deleteExpense(i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: cat.$3.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(cat.$2, color: cat.$3, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                    Text('${e.category} \u2022 ${e.date}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              Text('${e.amount.toStringAsFixed(0)} $_currencySymbol',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFE65100))),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(double spent, double remaining) {
    final ratio = _dailyBudget > 0 ? spent / _dailyBudget : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [remaining >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                   remaining >= 0 ? const Color(0xFF43A047) : const Color(0xFFE53935)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aujourd\'hui', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('D\u00E9pens\u00E9 $_currencySymbol${spent.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('Reste $_currencySymbol${remaining.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  Text('$_currencySymbol${_dailyBudget.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text('Budget', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, size: 18, color: Color(0xFFE65100)),
              SizedBox(width: 8),
              Text('R\u00E9partition par cat\u00E9gorie',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 12),
          if (_byCategory.isEmpty)
            Text('Ajoutez des d\u00E9penses pour voir la r\u00E9partition',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]))
          else
            ..._categories.map((cat) {
              final amount = _byCategory[cat.$1] ?? 0;
              if (amount == 0) return const SizedBox();
              final pct = _totalSpent > 0 ? amount / _totalSpent : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(cat.$2, size: 16, color: cat.$3),
                    const SizedBox(width: 8),
                    SizedBox(width: 80, child: Text(cat.$1, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: cat.$3.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(cat.$3),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(width: 60, child: Text('${(pct * 100).toInt()}%', textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class Expense {
  final String name;
  final double amount;
  final String category;
  final String date;

  Expense({required this.name, required this.amount, required this.category, required this.date});

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    date: json['date'] as String,
  );

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'category': category, 'date': date};
}
