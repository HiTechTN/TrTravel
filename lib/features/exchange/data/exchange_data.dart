class ExchangeOffice {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String district;
  final String city;
  final double buyRate;
  final double sellRate;
  final double rating;
  final String? phone;
  final bool isOpen;
  final String? openingHours;

  const ExchangeOffice({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.district,
    required this.city,
    required this.buyRate,
    required this.sellRate,
    this.rating = 4.0,
    this.phone,
    this.isOpen = true,
    this.openingHours,
  });
}

class ExchangeData {
  static final List<ExchangeOffice> all = [
    // === ISTANBUL ===
    ExchangeOffice(id: 'ist1', name: 'Kapalıçarşı Döviz', latitude: 41.0105, longitude: 28.9680,
        address: 'Grand Bazar, İç Kapı No:42, Nuruosmaniye', district: 'Beyazıt', city: 'Istanbul',
        buyRate: 34.90, sellRate: 35.30, rating: 4.6, phone: '+90 212 511 11 11', openingHours: '09:00-19:00'),
    ExchangeOffice(id: 'ist2', name: 'Sultanahmet Döviz', latitude: 41.0068, longitude: 28.9755,
        address: 'Sultanahmet Meydanı No:15', district: 'Sultanahmet', city: 'Istanbul',
        buyRate: 34.60, sellRate: 35.10, rating: 4.3, phone: '+90 212 517 22 22', openingHours: '08:00-20:00'),
    ExchangeOffice(id: 'ist3', name: 'Taksim Döviz', latitude: 41.0345, longitude: 28.9778,
        address: 'İstiklal Caddesi No:85, Taksim', district: 'Taksim', city: 'Istanbul',
        buyRate: 34.70, sellRate: 35.15, rating: 4.2, phone: '+90 212 243 33 33', openingHours: '09:00-22:00'),
    ExchangeOffice(id: 'ist4', name: 'Eminönü Döviz', latitude: 41.0173, longitude: 28.9718,
        address: 'Eminönü Meydanı No:3, Yeni Camii Yanı', district: 'Eminönü', city: 'Istanbul',
        buyRate: 34.85, sellRate: 35.25, rating: 4.4, phone: '+90 212 528 44 44', openingHours: '08:00-19:00'),
    ExchangeOffice(id: 'ist5', name: 'Kadıköy Döviz', latitude: 40.9903, longitude: 29.0268,
        address: 'Kadıköy Meydanı, Rıhtım Cad. No:12', district: 'Kadıköy', city: 'Istanbul',
        buyRate: 34.65, sellRate: 35.05, rating: 4.1, phone: '+90 216 336 55 55', openingHours: '09:00-21:00'),
    ExchangeOffice(id: 'ist6', name: 'Etiler Döviz', latitude: 41.0838, longitude: 29.0355,
        address: 'Etiler Mahallesi, Nispetiye Cad. No:78', district: 'Etiler', city: 'Istanbul',
        buyRate: 34.50, sellRate: 34.95, rating: 4.5, phone: '+90 212 358 66 66', openingHours: '09:00-20:00'),
    ExchangeOffice(id: 'ist7', name: 'Nişantaşı Döviz', latitude: 41.0520, longitude: 28.9925,
        address: 'Nişantaşı, Abdi İpekçi Cad. No:34', district: 'Nişantaşı', city: 'Istanbul',
        buyRate: 34.55, sellRate: 35.00, rating: 4.4, phone: '+90 212 234 77 77', openingHours: '09:00-21:00'),
    ExchangeOffice(id: 'ist8', name: 'Beşiktaş Döviz', latitude: 41.0425, longitude: 29.0065,
        address: 'Beşiktaş Meydanı No:8', district: 'Beşiktaş', city: 'Istanbul',
        buyRate: 34.60, sellRate: 35.05, rating: 4.0, phone: '+90 212 260 88 88', openingHours: '09:00-20:00'),
    ExchangeOffice(id: 'ist9', name: 'Bakırköy Döviz', latitude: 40.9690, longitude: 28.8710,
        address: 'Bakırköy Meydanı, İstanbul Cad. No:22', district: 'Bakırköy', city: 'Istanbul',
        buyRate: 34.75, sellRate: 35.15, rating: 4.2, phone: '+90 212 571 99 99', openingHours: '09:00-20:00'),
    ExchangeOffice(id: 'ist10', name: 'Üsküdar Döviz', latitude: 41.0260, longitude: 29.0150,
        address: 'Üsküdar Meydanı, Hakimiyeti Milliye Cad.', district: 'Üsküdar', city: 'Istanbul',
        buyRate: 34.70, sellRate: 35.10, rating: 4.1, openingHours: '09:00-19:00'),

    // === ANTALYA ===
    ExchangeOffice(id: 'ant1', name: 'Kaleiçi Döviz', latitude: 36.8870, longitude: 30.7060,
        address: 'Kaleiçi, Tuzcular Mah. No:45', district: 'Kaleiçi', city: 'Antalya',
        buyRate: 34.60, sellRate: 35.20, rating: 4.3, phone: '+90 242 241 11 11', openingHours: '09:00-20:00'),
    ExchangeOffice(id: 'ant2', name: 'Lara Döviz', latitude: 36.8560, longitude: 30.8120,
        address: 'Lara Bulvarı No:156, Güzeloba', district: 'Lara', city: 'Antalya',
        buyRate: 34.40, sellRate: 35.00, rating: 4.0, phone: '+90 242 323 22 22', openingHours: '09:00-21:00'),
    ExchangeOffice(id: 'ant3', name: 'Konyaaltı Döviz', latitude: 36.8625, longitude: 30.6410,
        address: 'Konyaaltı Sahili, Atatürk Bulvarı No:34', district: 'Konyaaltı', city: 'Antalya',
        buyRate: 34.50, sellRate: 35.10, rating: 4.2, phone: '+90 242 229 33 33', openingHours: '09:00-22:00'),
    ExchangeOffice(id: 'ant4', name: 'Antalya Merkez Döviz', latitude: 36.8878, longitude: 30.7045,
        address: 'Cumhuriyet Meydanı No:7, Muratpaşa', district: 'Muratpaşa', city: 'Antalya',
        buyRate: 34.55, sellRate: 35.15, rating: 4.1, phone: '+90 242 248 44 44', openingHours: '08:00-19:00'),
    ExchangeOffice(id: 'ant5', name: 'Alanya Döviz', latitude: 36.5440, longitude: 31.9950,
        address: 'Alanya Merkez, Damlataş Cad. No:28', district: 'Alanya', city: 'Antalya',
        buyRate: 34.35, sellRate: 34.95, rating: 4.0, phone: '+90 242 513 55 55', openingHours: '09:00-20:00'),
    ExchangeOffice(id: 'ant6', name: 'Side Döviz', latitude: 36.7680, longitude: 31.3960,
        address: 'Side Merkez, Liman Cad. No:15', district: 'Side', city: 'Antalya',
        buyRate: 34.30, sellRate: 34.90, rating: 3.9, openingHours: '09:00-19:00'),
    ExchangeOffice(id: 'ant7', name: 'Aéroport AYT Döviz', latitude: 36.9015, longitude: 30.7915,
        address: 'Antalya Havalimanı Dış Hatlar Terminali', district: 'Aksu', city: 'Antalya',
        buyRate: 34.20, sellRate: 35.30, rating: 3.5, phone: '+90 242 330 66 66', openingHours: '00:00-24:00'),
  ];

  static List<ExchangeOffice> getByCity(String city) => all.where((o) => o.city == city).toList();

  static ExchangeOffice? getBestRate(String city, {bool buy = true}) {
    final cityOffices = getByCity(city);
    if (cityOffices.isEmpty) return null;
    if (buy) {
      return cityOffices.fold<ExchangeOffice?>(null, (best, o) =>
          best == null || o.buyRate > best.buyRate ? o : best);
    }
    return cityOffices.fold<ExchangeOffice?>(null, (best, o) =>
        best == null || o.sellRate < best.sellRate ? o : best);
  }
}
