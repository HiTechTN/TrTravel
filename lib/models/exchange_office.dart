class ExchangeOffice {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String district;
  final String city;
  final Map<String, double> rates;
  final double rating;
  final String? phone;
  final String? openingHours;
  final bool isOpen;
  final String? type;

  ExchangeOffice({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.district,
    required this.city,
    required this.rates,
    this.rating = 4.0,
    this.phone,
    this.openingHours,
    this.isOpen = true,
    this.type,
  });

  double getRate(String fromCurrency, String toCurrency) {
    final fromRate = fromCurrency == 'TRY' ? 1.0 : (rates[fromCurrency] ?? 1.0);
    final toRate = toCurrency == 'TRY' ? 1.0 : (rates[toCurrency] ?? 1.0);
    return toRate / fromRate;
  }

  double getBenefit(String fromCurrency, String toCurrency, double amount) {
    final rate = getRate(fromCurrency, toCurrency);
    final amountInTry = amount / (fromCurrency == 'TRY' ? 1.0 : rates[fromCurrency]!);
    return amountInTry * rate;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'district': district,
    'city': city,
    'rates': rates,
    'rating': rating,
    'phone': phone,
    'openingHours': openingHours,
    'isOpen': isOpen,
    'type': type,
  };

  factory ExchangeOffice.fromJson(Map<String, dynamic> json) => ExchangeOffice(
    id: json['id'],
    name: json['name'],
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    address: json['address'] ?? '',
    district: json['district'] ?? '',
    city: json['city'] ?? '',
    rates: Map<String, double>.from(json['rates'] ?? {}),
    rating: (json['rating'] ?? 4.0).toDouble(),
    phone: json['phone'],
    openingHours: json['openingHours'],
    isOpen: json['isOpen'] ?? true,
    type: json['type'],
  );
}
