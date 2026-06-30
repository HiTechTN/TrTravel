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
    CurrencyRate(code: 'EUR', name: 'Euro', flag: '🇪🇺', rateToEur: 1.0, rateToUsd: 1.085),
    CurrencyRate(code: 'USD', name: 'US Dollar', flag: '🇺🇸', rateToEur: 0.922, rateToUsd: 1.0),
    CurrencyRate(code: 'TRY', name: 'Lire Turque', flag: '🇹🇷', rateToEur: 38.50, rateToUsd: 35.50),
    CurrencyRate(code: 'GBP', name: 'Livre Sterling', flag: '🇬🇧', rateToEur: 1.16, rateToUsd: 1.26),
    CurrencyRate(code: 'CHF', name: 'Franc Suisse', flag: '🇨🇭', rateToEur: 0.94, rateToUsd: 1.02),
    CurrencyRate(code: 'CAD', name: 'Dollar Canadien', flag: '🇨🇦', rateToEur: 0.68, rateToUsd: 0.74),
    CurrencyRate(code: 'RUB', name: 'Rouble Russe', flag: '🇷🇺', rateToEur: 90.0, rateToUsd: 83.0),
    CurrencyRate(code: 'JPY', name: 'Yen Japonais', flag: '🇯🇵', rateToEur: 168.0, rateToUsd: 155.0),
    CurrencyRate(code: 'CNY', name: 'Yuan Chinois', flag: '🇨🇳', rateToEur: 7.85, rateToUsd: 7.24),
    CurrencyRate(code: 'AUD', name: 'Dollar Australien', flag: '🇦🇺', rateToEur: 0.62, rateToUsd: 0.67),
    CurrencyRate(code: 'AED', name: 'Dirham Émirati', flag: '🇦🇪', rateToEur: 3.98, rateToUsd: 3.67),
    CurrencyRate(code: 'SAR', name: 'Riyal Saoudien', flag: '🇸🇦', rateToEur: 4.08, rateToUsd: 3.76),
    CurrencyRate(code: 'TND', name: 'Dinar Tunisien', flag: '🇹🇳', rateToEur: 3.30, rateToUsd: 3.04),
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
