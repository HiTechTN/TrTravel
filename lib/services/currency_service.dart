import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CurrencyService extends ChangeNotifier {
  static const String _ratesKey = 'currency_rates';
  static const String _lastUpdateKey = 'currency_last_update';
  
  Map<String, double> _rates = {};
  DateTime? _lastUpdate;
  bool _isOffline = false;

  static final List<Map<String, String>> supportedCurrencies = [
    {'code': 'TRY', 'name': 'Livre turque', 'symbol': '₺', 'flag': '🇹🇷'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'USD', 'name': 'Dollar américain', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'GBP', 'name': 'Livre sterling', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'CHF', 'name': 'Franc suisse', 'symbol': 'Fr', 'flag': '🇨🇭'},
    {'code': 'RUB', 'name': 'Rouble russe', 'symbol': '₽', 'flag': '🇷🇺'},
    {'code': 'AED', 'name': 'Dirham émirati', 'symbol': 'د.إ', 'flag': '🇦🇪'},
    {'code': 'SAR', 'name': 'Riyal saoudien', 'symbol': '﷼', 'flag': '🇸🇦'},
    {'code': 'TND', 'name': 'Dinar tunisien', 'symbol': 'د.ت', 'flag': '🇹🇳'},
  ];

  static final Map<String, double> _offlineRates = {
    'TRY': 1.0,
    'EUR': 0.028,
    'USD': 0.031,
    'GBP': 0.024,
    'CHF': 0.027,
    'RUB': 2.8,
    'AED': 0.11,
    'SAR': 0.12,
    'TND': 0.095,
  };

  CurrencyService() {
    _rates = Map<String, double>.from(_offlineRates);
  }

  Future<void> init() async {
    await _loadCachedRates();
  }

  Future<void> _loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = prefs.getString(_ratesKey);
    final lastUpdateStr = prefs.getString(_lastUpdateKey);
    
    if (ratesJson != null) {
      _rates = Map<String, double>.from(json.decode(ratesJson));
    } else {
      _rates = Map<String, double>.from(_offlineRates);
    }
    
    if (lastUpdateStr != null) {
      _lastUpdate = DateTime.parse(lastUpdateStr);
    }
    
    _isOffline = prefs.getBool('offline_mode') ?? false;
  }

  Future<void> _saveCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ratesKey, json.encode(_rates));
    if (_lastUpdate != null) {
      await prefs.setString(_lastUpdateKey, _lastUpdate!.toIso8601String());
    }
  }

  Future<void> fetchRates() async {
    if (_isOffline) return;

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/TRY'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        _rates = {
          'TRY': 1.0,
          'EUR': (rates['EUR'] ?? 0.028).toDouble(),
          'USD': (rates['USD'] ?? 0.031).toDouble(),
          'GBP': (rates['GBP'] ?? 0.024).toDouble(),
          'CHF': (rates['CHF'] ?? 0.027).toDouble(),
          'RUB': (rates['RUB'] ?? 2.8).toDouble(),
          'AED': (rates['AED'] ?? 0.11).toDouble(),
          'SAR': (rates['SAR'] ?? 0.12).toDouble(),
          'TND': (rates['TND'] ?? 0.095).toDouble(),
        };
        
        _lastUpdate = DateTime.now();
        await _saveCachedRates();
      }
    } catch (e) {
      _isOffline = true;
    }
  }

  double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    final fromRate = _rates[fromCurrency] ?? 1.0;
    final toRate = _rates[toCurrency] ?? 1.0;
    
    final amountInTry = amount / fromRate;
    return amountInTry * toRate;
  }

  double getRate(String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return 1.0;
    
    final fromRate = _rates[fromCurrency] ?? 1.0;
    final toRate = _rates[toCurrency] ?? 1.0;
    
    return toRate / fromRate;
  }

  DateTime? get lastUpdate => _lastUpdate;

  bool get isOffline => _isOffline;

  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  Map<String, double> get allRates => _rates;

  List<Map<String, String>> getAvailableCurrencies() {
    return supportedCurrencies;
  }

  String formatCurrency(double amount, String currencyCode) {
    final currency = supportedCurrencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => {'code': currencyCode, 'symbol': currencyCode},
    );
    
    final symbol = currency['symbol'] ?? currencyCode;
    
    if (currencyCode == 'TRY') {
      return '$symbol${amount.toStringAsFixed(2)}';
    } else if (amount >= 1000) {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}