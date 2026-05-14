import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100');
  String _fromCurrency = 'EUR';
  String _toCurrency = 'TRY';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyService>().fetchRates();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<CurrencyService>();
    final currencies = service.getAvailableCurrencies();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final converted = service.convert(amount, _fromCurrency, _toCurrency);
    final rate = service.getRate(_fromCurrency, _toCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertisseur de devises'),
        backgroundColor: const Color(0xFF43A047),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => service.fetchRates(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => service.fetchRates(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyDropdown(currencies, _fromCurrency, (val) {
                              setState(() => _fromCurrency = val!);
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz, size: 32),
                            onPressed: _swapCurrencies,
                          ),
                          Expanded(
                            child: _buildCurrencyDropdown(currencies, _toCurrency, (val) {
                              setState(() => _toCurrency = val!);
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFE8F5E9),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        service.formatCurrency(converted, _toCurrency),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1 $_fromCurrency = ${rate.toStringAsFixed(4)} $_toCurrency',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              if (service.lastUpdate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Mis à jour: ${DateFormat('dd/MM HH:mm').format(service.lastUpdate!)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              if (service.isOffline)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Mode hors-ligne - taux approximatifs',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              const Text('Tous les taux', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: currencies.map((currency) {
                    final code = currency['code']!;
                    final convertedAmount = service.convert(1, _fromCurrency, code);
                    return ListTile(
                      leading: Text(currency['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(code),
                      subtitle: Text(currency['name']!),
                      trailing: Text(
                        service.formatCurrency(convertedAmount, code),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        setState(() => _toCurrency = code);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Convertisseur rapide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [10, 20, 50, 100, 200, 500, 1000].map((amount) {
                  return ActionChip(
                    label: Text('$amount $_fromCurrency'),
                    onPressed: () {
                      _amountController.text = amount.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(
    List<Map<String, String>> currencies,
    String value,
    void Function(String?) onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      items: currencies.map((currency) => DropdownMenuItem(
        value: currency['code'],
        child: Row(
          children: [
            Text(currency['flag']!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(currency['code']!),
          ],
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }
}