import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
export '../models/exchange_office.dart';
import '../models/exchange_office.dart';

class ExchangeOfficeService extends ChangeNotifier {
  List<ExchangeOffice> _offices = [];
  Position? _userPosition;
  String _filterCity = 'all';
  String _filterDistrict = 'all';

  static final Map<String, double> _currentRates = {
    'EUR': 1.0,
    'USD': 1.08,
    'GBP': 0.86,
    'TRY': 32.50,
    'TND': 3.25,
    'CHF': 0.95,
    'RUB': 0.011,
    'AED': 0.27,
    'SAR': 0.27,
    'IQD': 0.00082,
    'IRR': 0.000024,
    'GEL': 0.38,
    'AZN': 0.59,
  };

  List<ExchangeOffice> get offices => _filterCity == 'all' 
      ? _offices 
      : _offices.where((o) => o.city == _filterCity).toList();

  List<String> get availableCities {
    final cities = _offices.map((o) => o.city).toSet().toList();
    cities.sort();
    return ['all', ...cities];
  }

  List<String> get availableDistricts {
    final filtered = _filterCity == 'all' ? _offices : _offices.where((o) => o.city == _filterCity);
    final districts = filtered.map((o) => o.district).toSet().toList();
    districts.sort();
    return ['all', ...districts];
  }

  void setCityFilter(String city) {
    _filterCity = city;
    _filterDistrict = 'all';
    notifyListeners();
  }

  void setDistrictFilter(String district) {
    _filterDistrict = district;
    notifyListeners();
  }

  List<ExchangeOffice> get filteredOffices {
    var result = _offices;
    if (_filterCity != 'all') {
      result = result.where((o) => o.city == _filterCity).toList();
    }
    if (_filterDistrict != 'all') {
      result = result.where((o) => o.district == _filterDistrict).toList();
    }
    return result;
  }

  Future<void> init() async {
    _loadAllOffices();
    notifyListeners();
  }

  void _loadAllOffices() {
    _offices = [
      // ==================== İSTANBUL ====================
      // Sultanahmet Area
      ExchangeOffice(id: 'ist_001', name: 'Sultanahmet Döviz', latitude: 41.0060, longitude: 28.9758, address: 'Sultan Ahmet Mah. Atmeydanı Cad. No:15', district: 'Sultanahmet', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 517 1234', openingHours: '08:00-22:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_002', name: 'Altınsoy Döviz Sultanahmet', latitude: 41.0082, longitude: 28.9771, address: 'Sultan Ahmet Mah. Tihatçılar Sok. No:8', district: 'Sultanahmet', city: 'Istanbul', rates: _currentRates, rating: 4.7, phone: '+90 212 518 2345', openingHours: '07:00-23:00', type: 'Zincir'),
      ExchangeOffice(id: 'ist_003', name: 'İstanbul Döviz Saray', latitude: 41.0075, longitude: 28.9745, address: 'Sultan Ahmet Mah. Tahtakale Sok. No:5', district: 'Sultanahmet', city: 'Istanbul', rates: _currentRates, rating: 4.3, phone: '+90 212 516 3456', openingHours: '08:00-21:00', type: 'Bağımsız'),
      
      // Sirkeci Area
      ExchangeOffice(id: 'ist_004', name: 'Sirkeci Döviz Bürosu', latitude: 41.0028, longitude: 28.9758, address: 'Sirkeci Mah. Hocapaşa Sok. No:12', district: 'Sirkeci', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 519 4567', openingHours: '07:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_005', name: 'Harem Döviz', latitude: 41.0015, longitude: 28.9842, address: 'Sirkeci Mah. Necatibey Cad. No:28', district: 'Sirkeci', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 520 5678', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_006', name: 'Çemberlitaş Döviz', latitude: 41.0065, longitude: 28.9678, address: 'Çemberlitaş Mah. Büyük Reşit Sok. No:18', district: 'Çemberlitaş', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 521 6789', openingHours: '08:00-20:00', type: 'Bağımsız'),

      // Grand Bazaar Area
      ExchangeOffice(id: 'ist_007', name: 'Kapalıçarşı Döviz', latitude: 41.0092, longitude: 28.9695, address: 'Beyazıt Mah. Kırkı Kilic Sok. No:45', district: 'Grand Bazaar', city: 'Istanbul', rates: _currentRates, rating: 4.8, phone: '+90 212 522 7890', openingHours: '08:30-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_008', name: 'Bahçekapı Döviz', latitude: 41.0105, longitude: 28.9682, address: 'Bahçekapı Mah. Yağkapan Sok. No:8', district: 'Grand Bazaar', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 523 8901', openingHours: '08:00-18:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_009', name: 'Sandal Bedesteni Döviz', latitude: 41.0088, longitude: 28.9712, address: 'Beyazıt Mah. Sandal Bedesteni Sok. No:22', district: 'Grand Bazaar', city: 'Istanbul', rates: _currentRates, rating: 4.7, phone: '+90 212 524 9012', openingHours: '09:00-18:00', type: 'Bağımsız'),

      // Aksaray - Laleli Area
      ExchangeOffice(id: 'ist_010', name: 'Aksaray Döviz', latitude: 41.0112, longitude: 28.9615, address: 'Aksaray Mah. Atatürk Cad. No:88', district: 'Aksaray', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 525 0123', openingHours: '07:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_011', name: 'Laleli Döviz Bürosu', latitude: 41.0098, longitude: 28.9652, address: 'Laleli Mah. Ordu Cad. No:156', district: 'Laleli', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 526 1234', openingHours: '07:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_012', name: 'Menderes Döviz', latitude: 41.0135, longitude: 28.9598, address: 'Menderes Mah. Vatan Cad. No:42', district: 'Aksaray', city: 'Istanbul', rates: _currentRates, rating: 4.3, phone: '+90 212 527 2345', openingHours: '08:00-19:00', type: 'Bağımsız'),

      // Fatih Area
      ExchangeOffice(id: 'ist_013', name: 'Fatih Döviz', latitude: 41.0202, longitude: 28.9498, address: 'Fatih Mah. Fevzipaşa Cad. No:75', district: 'Fatih', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 528 3456', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_014', name: 'Vatan Döviz', latitude: 41.0185, longitude: 28.9532, address: 'Vatan Mah. Vatan Cad. No:124', district: 'Fatih', city: 'Istanbul', rates: _currentRates, rating: 4.2, phone: '+90 212 529 4567', openingHours: '08:30-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_015', name: 'Hirka-i Şerif Döviz', latitude: 41.0225, longitude: 28.9455, address: 'Hirka-i Şerif Mah. Mahmutpaşa Sok. No:12', district: 'Fatih', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 530 5678', openingHours: '08:00-18:00', type: 'Bağımsız'),

      // Beyoğlu - Taksim Area
      ExchangeOffice(id: 'ist_016', name: 'İstiklal Döviz', latitude: 41.0365, longitude: 28.9738, address: 'İstiklal Cad. No:128', district: 'Beyoğlu', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 531 6789', openingHours: '08:00-22:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_017', name: 'Taksim Döviz Bürosu', latitude: 41.0378, longitude: 28.9785, address: 'Taksim Meydanı No:15', district: 'Taksim', city: 'Istanbul', rates: _currentRates, rating: 4.7, phone: '+90 212 532 7890', openingHours: '08:00-23:00', type: 'Zincir'),
      ExchangeOffice(id: 'ist_018', name: 'Galata Döviz', latitude: 41.0262, longitude: 28.9745, address: 'Galata Mah. Bankalar Cad. No:35', district: 'Galata', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 533 8901', openingHours: '08:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_019', name: 'Karaköy Döviz', latitude: 41.0282, longitude: 28.9812, address: 'Karaköy Gıda Sok. No:22', district: 'Karaköy', city: 'Istanbul', rates: _currentRates, rating: 4.8, phone: '+90 212 534 9012', openingHours: '07:30-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_020', name: 'Şişhane Döviz', latitude: 41.0502, longitude: 28.9875, address: 'Şişhane Mah. İstiklal Cad. No:78', district: 'Beyoğlu', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 535 0123', openingHours: '08:00-20:00', type: 'Bağımsız'),

      // Kadıköy Area
      ExchangeOffice(id: 'ist_021', name: 'Kadıköy Döviz', latitude: 41.0085, longitude: 29.0245, address: 'Kadıköy Mah. Bahariye Cad. No:45', district: 'Kadıköy', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 216 345 1234', openingHours: '08:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_022', name: 'Moda Döviz', latitude: 41.0255, longitude: 29.0315, address: 'Moda Mah. Caferağa Cad. No:88', district: 'Kadıköy', city: 'Istanbul', rates: _currentRates, rating: 4.7, phone: '+90 216 346 2345', openingHours: '08:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_023', name: 'Göztepe Döviz', latitude: 41.0312, longitude: 29.0525, address: 'Göztepe Mah. Bağdat Cad. No:156', district: 'Göztepe', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 216 347 3456', openingHours: '08:00-19:00', type: 'Bağımsız'),

      // Beşiktaş Area
      ExchangeOffice(id: 'ist_024', name: 'Beşiktaş Döviz', latitude: 41.0442, longitude: 29.0062, address: 'Beşiktaş Cumhuriyet Cad. No:42', district: 'Beşiktaş', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 261 1234', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_025', name: 'Levent Döviz', latitude: 41.0565, longitude: 29.0285, address: 'Levent Mah. Levent Cad. No:88', district: 'Levent', city: 'Istanbul', rates: _currentRates, rating: 4.7, phone: '+90 212 262 2345', openingHours: '08:30-19:00', type: 'Zincir'),
      ExchangeOffice(id: 'ist_026', name: 'Maslak Döviz', latitude: 41.0825, longitude: 29.0198, address: 'Maslak Mah. Büyükdere Cad. No:225', district: 'Maslak', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 263 3456', openingHours: '08:00-18:00', type: 'Bağımsız'),

      // Üsküdar Area
      ExchangeOffice(id: 'ist_027', name: 'Üsküdar Döviz', latitude: 41.0275, longitude: 29.0152, address: 'Üsküdar Mah. Cumhuriyet Cad. No:65', district: 'Üsküdar', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 216 531 4567', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_028', name: 'Çamlıca Döviz', latitude: 41.0385, longitude: 29.0325, address: 'Çamlıca Mah. Çamlıca Cad. No:120', district: 'Üsküdar', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 216 532 5678', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_029', name: 'Beylerbeyi Döviz', latitude: 41.0422, longitude: 29.0452, address: 'Beylerbeyi Mah. Beylerbeyi Cad. No:45', district: 'Beylerbeyi', city: 'Istanbul', rates: _currentRates, rating: 4.3, phone: '+90 216 533 6789', openingHours: '08:30-18:00', type: 'Bağımsız'),

      // Mecidiyeköy - Şişli Area
      ExchangeOffice(id: 'ist_030', name: 'Mecidiyeköy Döviz', latitude: 41.0555, longitude: 29.0122, address: 'Mecidiyeköy Mah. Silahşör Cad. No:55', district: 'Mecidiyeköy', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 212 275 1234', openingHours: '08:00-20:00', type: 'Zincir'),
      ExchangeOffice(id: 'ist_031', name: 'Şişli Döviz', latitude: 41.0612, longitude: 29.0098, address: 'Şişli Mah. Abide-i Hürriyet Cad. No:88', district: 'Şişli', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 276 2345', openingHours: '08:30-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_032', name: 'Bomonti Döviz', latitude: 41.0685, longitude: 28.9985, address: 'Bomonti Mah. Fitness Sok. No:12', district: 'Şişli', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 277 3456', openingHours: '08:00-18:00', type: 'Bağımsız'),

      // Airport Area
      ExchangeOffice(id: 'ist_033', name: 'İstanbul Havalimanı Döviz', latitude: 41.2752, longitude: 28.7515, address: 'İstanbul Havalimanı Terminal A', district: 'Arnavutköy', city: 'Istanbul', rates: _currentRates, rating: 4.8, phone: '+90 212 463 1234', openingHours: '24 Saat', type: 'Zincir'),
      ExchangeOffice(id: 'ist_034', name: 'Sabiha Gökçen Döviz', latitude: 40.8985, longitude: 29.3082, address: 'Sabiha Gökçen Havalimanı', district: 'Pendik', city: 'Istanbul', rates: _currentRates, rating: 4.6, phone: '+90 216 588 1234', openingHours: '24 Saat', type: 'Zincir'),

      // Bakırköy Area
      ExchangeOffice(id: 'ist_035', name: 'Bakırköy Döviz', latitude: 40.9865, longitude: 28.8725, address: 'Bakırköy Mah. Cevizlik Cad. No:42', district: 'Bakırköy', city: 'Istanbul', rates: _currentRates, rating: 4.5, phone: '+90 212 543 1234', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_036', name: 'Yeşilyurt Döviz', latitude: 40.9815, longitude: 28.8855, address: 'Yeşilyurt Mah. Yeşilyurt Cad. No:28', district: 'Bakırköy', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 544 2345', openingHours: '08:30-19:00', type: 'Bağımsız'),

      // Avcılar Area
      ExchangeOffice(id: 'ist_037', name: 'Avcılar Döviz', latitude: 40.9965, longitude: 28.7215, address: 'Avcılar Mah. İstanbul Cad. No:156', district: 'Avcılar', city: 'Istanbul', rates: _currentRates, rating: 4.3, phone: '+90 212 593 1234', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ist_038', name: 'Merkez Döviz Avcılar', latitude: 40.9895, longitude: 28.7315, address: 'Merkez Mah. Amiral Sok. No:22', district: 'Avcılar', city: 'Istanbul', rates: _currentRates, rating: 4.4, phone: '+90 212 594 2345', openingHours: '08:30-18:00', type: 'Bağımsız'),

      // ==================== ANTALYA ====================
      // Kaleiçi - Lara Area
      ExchangeOffice(id: 'ant_001', name: 'Kaleiçi Döviz', latitude: 36.8835, longitude: 30.6925, address: 'Kaleiçi Mah. Hesapçı Sok. No:12', district: 'Kaleiçi', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 247 1234', openingHours: '08:00-22:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_002', name: 'Kaleiçi Altın Döviz', latitude: 36.8852, longitude: 30.6895, address: 'Kaleiçi Mah. Barbaros Cad. No:45', district: 'Kaleiçi', city: 'Antalya', rates: _currentRates, rating: 4.7, phone: '+90 242 248 2345', openingHours: '09:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_003', name: 'Lara Döviz Bürosu', latitude: 36.8545, longitude: 30.7835, address: 'Lara Mah. Lara Cad. No:88', district: 'Lara', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 249 3456', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_004', name: 'Kundu Döviz', latitude: 36.8395, longitude: 30.6255, address: 'Kundu Mah. Atatürk Cad. No:156', district: 'Lara', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 250 4567', openingHours: '08:00-19:00', type: 'Bağımsız'),

      // Konyaaltı Area
      ExchangeOffice(id: 'ant_005', name: 'Konyaaltı Döviz', latitude: 36.8815, longitude: 30.6415, address: 'Konyaaltı Mah. Akdeniz Cad. No:75', district: 'Konyaaltı', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 251 5678', openingHours: '08:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_006', name: 'Boğa Döviz Konyaaltı', latitude: 36.8795, longitude: 30.6355, address: 'Konyaaltı Mah. Pınarbaşı Sok. No:18', district: 'Konyaaltı', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 252 6789', openingHours: '08:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_007', name: 'Altınova Döviz', latitude: 36.8755, longitude: 30.6185, address: 'Altınova Mah. Yavuz Sultan Selim Cad. No:42', district: 'Konyaaltı', city: 'Antalya', rates: _currentRates, rating: 4.3, phone: '+90 242 253 7890', openingHours: '08:00-19:00', type: 'Bağımsız'),

      // Muratpaşa Area
      ExchangeOffice(id: 'ant_008', name: 'Muratpaşa Döviz', latitude: 36.8915, longitude: 30.7095, address: 'Muratpaşa Mah. Cumhuriyet Cad. No:125', district: 'Muratpaşa', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 311 1234', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_009', name: 'Meydan Döviz', latitude: 36.8935, longitude: 30.7055, address: 'Muratpaşa Mah. Meydan Cad. No:8', district: 'Muratpaşa', city: 'Antalya', rates: _currentRates, rating: 4.8, phone: '+90 242 312 2345', openingHours: '07:00-22:00', type: 'Zincir'),
      ExchangeOffice(id: 'ant_010', name: 'Yüksekalan Döviz', latitude: 36.8895, longitude: 30.7185, address: 'Yüksekalan Mah. 502 Sok. No:32', district: 'Muratpaşa', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 313 3456', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_011', name: 'Serik Döviz Muratpaşa', latitude: 36.8865, longitude: 30.7235, address: 'Serik Mah. Şehit Nazım Sok. No:18', district: 'Muratpaşa', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 314 4567', openingHours: '08:30-18:00', type: 'Bağımsız'),

      // Merkez - Kepez Area
      ExchangeOffice(id: 'ant_012', name: 'Antalya Merkez Döviz', latitude: 36.8965, longitude: 30.6985, address: 'Kepez Mah. Şarampol Cad. No:88', district: 'Kepez', city: 'Antalya', rates: _currentRates, rating: 4.7, phone: '+90 242 315 5678', openingHours: '07:30-21:00', type: 'Zincir'),
      ExchangeOffice(id: 'ant_013', name: 'Şafak Döviz', latitude: 36.9025, longitude: 30.6895, address: 'Şafak Mah. Gazi Bulvarı No:42', district: 'Kepez', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 316 6789', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_014', name: 'Dokuma Döviz', latitude: 36.9085, longitude: 30.6815, address: 'Dokuma Mah. Organize Sanayi Cad. No:15', district: 'Kepez', city: 'Antalya', rates: _currentRates, rating: 4.3, phone: '+90 242 317 7890', openingHours: '08:00-18:00', type: 'Bağımsız'),

      // Döşemealtı Area
      ExchangeOffice(id: 'ant_015', name: 'Döşemealtı Döviz', latitude: 36.9515, longitude: 30.6415, address: 'Döşemealtı Yeşilbayır Mah. Cad. No:125', district: 'Döşemealtı', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 318 8901', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_016', name: 'Yeşilbayır Döviz', latitude: 36.9455, longitude: 30.6285, address: 'Yeşilbayır Mah. Atatürk Cad. No:78', district: 'Döşemealtı', city: 'Antalya', rates: _currentRates, rating: 4.3, phone: '+90 242 319 9012', openingHours: '08:30-18:00', type: 'Bağımsız'),

      // Alanya Area
      ExchangeOffice(id: 'ant_017', name: 'Alanya Döviz Bürosu', latitude: 36.2475, longitude: 31.9995, address: 'Cumhuriyet Mah. Atatürk Cad. No:145', district: 'Alanya', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 511 1234', openingHours: '08:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_018', name: 'Cleopatra Döviz', latitude: 36.2515, longitude: 32.0055, address: 'Cleopatra Cad. No:88', district: 'Alanya', city: 'Antalya', rates: _currentRates, rating: 4.7, phone: '+90 242 512 2345', openingHours: '08:00-22:00', type: 'Zincir'),
      ExchangeOffice(id: 'ant_019', name: 'Kargacalar Döviz', latitude: 36.2555, longitude: 31.9895, address: 'Kargıcak Mah. D-400 Cad. No:42', district: 'Alanya', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 513 3456', openingHours: '08:30-20:00', type: 'Bağımsız'),

      // Side Area
      ExchangeOffice(id: 'ant_020', name: 'Side Döviz', latitude: 36.7775, longitude: 31.3885, address: 'Side Mah. Kumköy Cad. No:75', district: 'Side', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 753 1234', openingHours: '08:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_021', name: 'Manavgat Döviz', latitude: 36.7865, longitude: 31.4415, address: 'Manavgat Mah. Side Cad. No:125', district: 'Side', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 754 2345', openingHours: '08:00-20:00', type: 'Bağımsız'),

      // Belek Area
      ExchangeOffice(id: 'ant_022', name: 'Belek Döviz', latitude: 36.8625, longitude: 31.0455, address: 'Belek Mah. Cad. No:45', district: 'Belek', city: 'Antalya', rates: _currentRates, rating: 4.7, phone: '+90 242 715 1234', openingHours: '08:00-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_023', name: 'Kadriye Döviz', latitude: 36.8525, longitude: 31.0625, address: 'Kadriye Mah. Atatürk Cad. No:88', district: 'Belek', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 716 2345', openingHours: '08:30-19:00', type: 'Bağımsız'),

      // Kemer Area
      ExchangeOffice(id: 'ant_024', name: 'Kemer Döviz', latitude: 36.6015, longitude: 30.5635, address: 'Kemer Mah. Atatürk Cad. No:125', district: 'Kemer', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 814 1234', openingHours: '08:00-21:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_025', name: 'Çamyuva Döviz', latitude: 36.5845, longitude: 30.5375, address: 'Çamyuva Mah. Riva Cad. No:42', district: 'Kemer', city: 'Antalya', rates: _currentRates, rating: 4.3, phone: '+90 242 815 2345', openingHours: '08:30-20:00', type: 'Bağımsız'),

      // Kumluca Area
      ExchangeOffice(id: 'ant_026', name: 'Kumluca Döviz', latitude: 36.3715, longitude: 30.4015, address: 'Kumluca Mah. Cumhuriyet Cad. No:78', district: 'Kumluca', city: 'Antalya', rates: _currentRates, rating: 4.2, phone: '+90 242 887 1234', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_027', name: 'Finike Döviz', latitude: 36.3035, longitude: 30.1495, address: 'Finike Mah. Cumhuriyet Cad. No:55', district: 'Finike', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 893 1234', openingHours: '08:00-18:00', type: 'Bağımsız'),

      // Kaş Area
      ExchangeOffice(id: 'ant_028', name: 'Kaş Döviz', latitude: 36.2005, longitude: 29.6475, address: 'Kaş Mah. Cumhuriyet Cad. No:98', district: 'Kaş', city: 'Antalya', rates: _currentRates, rating: 4.6, phone: '+90 242 836 1234', openingHours: '08:30-20:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_029', name: 'Kalkan Döviz', latitude: 36.2635, longitude: 29.4175, address: 'Kalkan Mah. Kışla Cad. No:42', district: 'Kalkan', city: 'Antalya', rates: _currentRates, rating: 4.5, phone: '+90 242 844 1234', openingHours: '08:00-19:00', type: 'Bağımsız'),

      // Aksu - Duman Area
      ExchangeOffice(id: 'ant_030', name: 'Aksu Döviz', latitude: 36.9385, longitude: 30.8375, address: 'Aksu Mah. Atatürk Cad. No:168', district: 'Aksu', city: 'Antalya', rates: _currentRates, rating: 4.4, phone: '+90 242 426 1234', openingHours: '08:00-19:00', type: 'Bağımsız'),
      ExchangeOffice(id: 'ant_031', name: 'Duman Döviz', latitude: 36.9255, longitude: 30.8525, address: 'Duman Mah. Yeşilyurt Cad. No:75', district: 'Aksu', city: 'Antalya', rates: _currentRates, rating: 4.3, phone: '+90 242 427 2345', openingHours: '08:30-18:00', type: 'Bağımsız'),
    ];
  }

  ExchangeOffice? findNearestOffice(double lat, double lon) {
    if (_offices.isEmpty) return null;
    
    ExchangeOffice? nearest;
    double minDistance = double.infinity;
    
    for (final office in _offices) {
      final distance = Geolocator.distanceBetween(lat, lon, office.latitude, office.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = office;
      }
    }
    
    return nearest;
  }

  ExchangeOffice? findBestRate(String fromCurrency, String toCurrency, double amount) {
    if (_offices.isEmpty) return null;
    
    ExchangeOffice? bestOffice;
    double maxAmount = 0;
    
    for (final office in _offices) {
      final converted = office.getBenefit(fromCurrency, toCurrency, amount);
      if (converted > maxAmount) {
        maxAmount = converted;
        bestOffice = office;
      }
    }
    
    return bestOffice;
  }

  List<ExchangeOffice> sortByRating() {
    final sorted = List<ExchangeOffice>.from(_offices);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  List<ExchangeOffice> sortByDistance(double userLat, double userLon) {
    final sorted = List<ExchangeOffice>.from(_offices);
    sorted.sort((a, b) {
      final distA = Geolocator.distanceBetween(userLat, userLon, a.latitude, a.longitude);
      final distB = Geolocator.distanceBetween(userLat, userLon, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  int get totalCount => _offices.length;
  
  int getIstanbulCount() => _offices.where((o) => o.city == 'Istanbul').length;
  
  int getAntalyaCount() => _offices.where((o) => o.city == 'Antalya').length;

  List<ExchangeOffice> getOffices() => filteredOffices;

  List<ExchangeOffice> getOfficesSortedByRate(String from, String to, {required double amount}) {
    final list = List<ExchangeOffice>.from(filteredOffices);
    list.sort((a, b) {
      final rateA = a.getRate(from, to);
      final rateB = b.getRate(from, to);
      return rateB.compareTo(rateA);
    });
    return list;
  }

  List<ExchangeOffice> getOfficesSortedByDistance(double userLat, double userLon) {
    return sortByDistance(userLat, userLon);
  }

  Map<String, List<String>> get districtsByCity {
    final result = <String, List<String>>{};
    for (final office in _offices) {
      if (!result.containsKey(office.city)) {
        result[office.city] = [];
      }
      if (!result[office.city]!.contains(office.district)) {
        result[office.city]!.add(office.district);
      }
    }
    for (final key in result.keys) {
      result[key]!.sort();
    }
    return result;
  }

  void setUserPosition(Position? pos) {
    _userPosition = pos;
    notifyListeners();
  }

  ExchangeOffice? getBestRateOffice(String from, String to, {double? amount, double? userLat, double? userLon}) {
    return findBestRate(from, to, amount ?? 100);
  }

  double getDistanceToOffice(ExchangeOffice office) {
    if (_userPosition == null) return 0;
    return Geolocator.distanceBetween(
      _userPosition!.latitude, 
      _userPosition!.longitude, 
      office.latitude, 
      office.longitude
    );
  }
}