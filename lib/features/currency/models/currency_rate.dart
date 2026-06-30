class CurrencyRate {
  final String code;
  final String name;
  final String flag;
  final double rateToEur;
  final double rateToUsd;

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.flag,
    required this.rateToEur,
    required this.rateToUsd,
  });
}

class CurrencyData {
  static List<CurrencyRate> currencies = [
    CurrencyRate(code: 'EUR', name: 'Euro', flag: '🇪🇺', rateToEur: 1.0, rateToUsd: 1.08),
    CurrencyRate(code: 'USD', name: 'US Dollar', flag: '🇺🇸', rateToEur: 0.93, rateToUsd: 1.0),
    CurrencyRate(code: 'TRY', name: 'Lire Turque', flag: '🇹🇷', rateToEur: 35.50, rateToUsd: 33.20),
    CurrencyRate(code: 'GBP', name: 'Livre Sterling', flag: '🇬🇧', rateToEur: 1.17, rateToUsd: 1.27),
    CurrencyRate(code: 'CHF', name: 'Franc Suisse', flag: '🇨🇭', rateToEur: 1.03, rateToUsd: 1.12),
    CurrencyRate(code: 'CAD', name: 'Dollar Canadien', flag: '🇨🇦', rateToEur: 0.67, rateToUsd: 0.73),
    CurrencyRate(code: 'RUB', name: 'Rouble Russe', flag: '🇷🇺', rateToEur: 105.0, rateToUsd: 98.0),
    CurrencyRate(code: 'JPY', name: 'Yen Japonais', flag: '🇯🇵', rateToEur: 162.0, rateToUsd: 150.0),
    CurrencyRate(code: 'CNY', name: 'Yuan Chinois', flag: '🇨🇳', rateToEur: 7.80, rateToUsd: 7.25),
    CurrencyRate(code: 'AUD', name: 'Dollar Australien', flag: '🇦🇺', rateToEur: 0.60, rateToUsd: 0.65),
    CurrencyRate(code: 'AED', name: 'Dirham Émirati', flag: '🇦🇪', rateToEur: 0.25, rateToUsd: 0.27),
    CurrencyRate(code: 'SAR', name: 'Riyal Saoudien', flag: '🇸🇦', rateToEur: 0.24, rateToUsd: 0.26),
    CurrencyRate(code: 'TND', name: 'Dinar Tunisien', flag: '🇹🇳', rateToEur: 3.30, rateToUsd: 3.05),
  ];

  static String convert(double amount, String from, String to) {
    final fromRate = currencies.firstWhere((c) => c.code == from);
    final toRate = currencies.firstWhere((c) => c.code == to);
    final inEur = from == 'EUR' ? amount : amount / fromRate.rateToEur;
    final result = to == 'EUR' ? inEur : inEur * toRate.rateToEur;
    return result.toStringAsFixed(2);
  }

  static double convertDouble(double amount, String from, String to) {
    final fromRate = currencies.firstWhere((c) => c.code == from);
    final toRate = currencies.firstWhere((c) => c.code == to);
    final inEur = from == 'EUR' ? amount : amount / fromRate.rateToEur;
    return to == 'EUR' ? inEur : inEur * toRate.rateToEur;
  }
}
