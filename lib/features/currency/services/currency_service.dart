import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import '../models/currency_rate.dart';

class CurrencyService extends ChangeNotifier {
  String _fromCurrency = 'EUR';
  String _toCurrency = 'TRY';
  double _amount = 100;
  String _result = '';
  bool _isLoading = false;
  String? _lastUpdated;
  bool _useOffline = true;
  List<Map<String, String>> _quickAmounts = [
    {'label': '50 €', 'amount': '50'},
    {'label': '100 €', 'amount': '100'},
    {'label': '200 €', 'amount': '200'},
    {'label': '500 €', 'amount': '500'},
    {'label': '1000 €', 'amount': '1000'},
  ];

  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get amount => _amount;
  String get result => _result;
  bool get isLoading => _isLoading;
  String? get lastUpdated => _lastUpdated;
  bool get useOffline => _useOffline;
  List<CurrencyRate> get currencies => CurrencyData.currencies;
  List<Map<String, String>> get quickAmounts => _quickAmounts;

  CurrencyService() {
    _loadState();
  }

  void _loadState() {
    _fromCurrency = LocalStorage.getString('currency_from') ?? 'EUR';
    _toCurrency = LocalStorage.getString('currency_to') ?? 'TRY';
    _amount = LocalStorage.getDouble('currency_amount') ?? 100;
    _lastUpdated = LocalStorage.getString('currency_updated');
    doConvert();
  }

  void setFromCurrency(String code) {
    _fromCurrency = code;
    LocalStorage.setString('currency_from', code);
    doConvert();
  }

  void setToCurrency(String code) {
    _toCurrency = code;
    LocalStorage.setString('currency_to', code);
    doConvert();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    LocalStorage.setString('currency_from', _fromCurrency);
    LocalStorage.setString('currency_to', _toCurrency);
    doConvert();
  }

  void setAmount(double value) {
    _amount = value;
    LocalStorage.setDouble('currency_amount', value);
    doConvert();
  }

  void doConvert() {
    _result = CurrencyData.convert(_amount, _fromCurrency, _toCurrency);
    notifyListeners();
  }

  String getFromSymbol() {
    final c = CurrencyData.currencies.firstWhere((c) => c.code == _fromCurrency);
    return c.flag;
  }

  String getToSymbol() {
    final c = CurrencyData.currencies.firstWhere((c) => c.code == _toCurrency);
    return c.flag;
  }

  double getRateFor(String code) {
    final c = CurrencyData.currencies.firstWhere((c) => c.code == code);
    return c.rateToEur;
  }

  Future<void> updateRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/EUR');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>? ?? {};
        
        final updatedCurrencies = CurrencyData.currencies.map((c) {
          if (c.code == 'EUR') return c;
          final rate = rates[c.code] as num? ?? c.rateToEur;
          return CurrencyRate(
            code: c.code,
            name: c.name,
            flag: c.flag,
            rateToEur: rate.toDouble(),
            rateToUsd: c.code == 'USD' ? 1.0 : (rate / (rates['USD'] as num? ?? 1.0)).toDouble(),
          );
        }).toList();
        
        _lastUpdated = DateTime.now().toIso8601String();
        LocalStorage.setString('currency_updated', _lastUpdated!);
        doConvert();
      }
    } catch (e) {
      LogService.warning('Currency', 'Failed to fetch rates: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
