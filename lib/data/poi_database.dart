import 'package:latlong2/latlong.dart';
import 'poi_istanbul_part2.dart';
import 'poi_istanbul_part3.dart';
import 'poi_istanbul_part4.dart';
import 'poi_istanbul_part5.dart';
import 'poi_istanbul_part6.dart';
import 'poi_antalya_part2.dart';
import 'poi_antalya_part3.dart';
import 'poi_antalya_part4.dart';
import 'poi_antalya_part5.dart';
import 'poi_antalya_part6.dart';

class POI {
  final String id;
  final String name;
  final String nameTr;
  final String nameEn;
  final String description;
  final String descriptionTr;
  final String descriptionEn;
  final LatLng location;
  final String category;
  final String subcategory;
  final double rating;
  final int reviewCount;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? closingHours;
  final String? priceRange;
  final double? entranceFee;
  final String? entranceFeeTr;
  final String? bestTime;
  final String? bestTimeTr;
  final List<String> tags;
  final String city;
  final String district;
  final bool hasParking;
  final bool hasWheelchair;
  final bool hasWifi;
  final bool isIndoor;
  final bool isOutdoor;
  final int? estimatedMinutes;
  final List<String> languages;
  final String? metroStation;
  final String? busLines;
  final bool allowsPhotography;
  final String? dressCode;
  final String? cuisine;
  final double? averagePrice;

  POI({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameEn,
    required this.description,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.location,
    required this.category,
    this.subcategory = '',
    this.rating = 4.0,
    this.reviewCount = 0,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.closingHours,
    this.priceRange,
    this.entranceFee,
    this.entranceFeeTr,
    this.bestTime,
    this.bestTimeTr,
    this.tags = const [],
    required this.city,
    this.district = '',
    this.hasParking = false,
    this.hasWheelchair = false,
    this.hasWifi = false,
    this.isIndoor = false,
    this.isOutdoor = false,
    this.estimatedMinutes,
    this.languages = const [],
    this.metroStation,
    this.busLines,
    this.allowsPhotography = true,
    this.dressCode,
    this.cuisine,
    this.averagePrice,
  });

  String getLocalizedName(String lang) {
    if (lang == 'tr') return nameTr;
    if (lang == 'en') return nameEn;
    return name;
  }

  String getLocalizedDesc(String lang) {
    if (lang == 'tr') return descriptionTr;
    if (lang == 'en') return descriptionEn;
    return description;
  }

  String getEntranceFeeText() {
    if (entranceFee == null || entranceFee == 0) return 'Gratuit';
    return '${entranceFee!.toStringAsFixed(0)} TL';
  }

  String getHoursText() {
    if (openingHours == null) return '24h';
    return '${openingHours!}${closingHours != null ? ' - $closingHours' : ''}';
  }
}

class POIDatabase {
  static List<POI> get allPOIs {
    final List<POI> pois = [..._basePOIs];
    pois.addAll(POIstanbulPart2.getPOIs());
    pois.addAll(POIstanbulPart3.getPOIs());
    pois.addAll(POIstanbulPart4.getPOIs());
    pois.addAll(POIstanbulPart5.getPOIs());
    pois.addAll(POIstanbulPart6.getPOIs());
    pois.addAll(POIAntalyaPart2.getPOIs());
    pois.addAll(POIAntalyaPart3.getPOIs());
    pois.addAll(POIAntalyaPart4.getPOIs());
    pois.addAll(POIAntalyaPart5.getPOIs());
    pois.addAll(POIAntalyaPart6.getPOIs());
    return pois;
  }

  static final List<POI> _basePOIs = [
    POI(id: 'ist_001', name: 'Sainte-Sophie', nameTr: 'Ayasofya', nameEn: 'Hagia Sophia', description: 'Basilique byzantine transformée en mosquée, classée UNESCO. Construite en 537.', descriptionTr: '537 yılında inşa edilen UNESCO Dünya Mirası.', descriptionEn: 'UNESCO World Heritage, built in 537.', location: LatLng(41.0086, 28.9802), category: 'historical', rating: 4.9, reviewCount: 47892, address: 'Sultan Ahmet, Istanbul', phone: '+90 212 522 09 89', website: 'https://ayasofya.istanbul', openingHours: '09:00', closingHours: '18:00', entranceFee: 25.0, bestTime: 'Matin tôt', tags: ['UNESCO', 'Byzantin', 'Architecture'], city: 'Istanbul', district: 'Sultanahmet', hasParking: true, hasWheelchair: true, estimatedMinutes: 120, languages: ['tr', 'en', 'fr'], metroStation: 'Sultanahmet'),
    POI(id: 'ist_002', name: 'Mosquée Bleue', nameTr: 'Sultan Ahmet Camii', nameEn: 'Blue Mosque', description: 'Mosquée ottomane du XVIe siècle avec 6 minarets et 20000 carreaux Iznik.', descriptionTr: '6 minaresi ve 20.000 İznik çinisiyle ünlü Osmanlı camii.', descriptionEn: '16th century Ottoman mosque with 6 minarets.', location: LatLng(41.0054, 28.9768), category: 'religious', rating: 4.8, reviewCount: 39823, address: 'Sultan Ahmet, Istanbul', openingHours: '08:00', closingHours: '18:00', entranceFee: 0.0, bestTime: 'Matin/Soir', tags: ['Ottoman', 'Architecture'], city: 'Istanbul', district: 'Sultanahmet', hasWheelchair: true, estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], metroStation: 'Sultanahmet'),
    POI(id: 'ist_003', name: 'Grand Bazar', nameTr: 'Kapalıçarşı', nameEn: 'Grand Bazaar', description: 'Plus grand marché couvert du monde, 4000 boutiques depuis 1461.', descriptionTr: '1461\'den beri 4.000 dükkanlı dünyanın en büyük kapalı çarşısı.', descriptionEn: 'World\'s largest covered market since 1461.', location: LatLng(41.0097, 28.9702), category: 'shopping', rating: 4.5, reviewCount: 28456, address: 'Beyazıt, Istanbul', openingHours: '08:30', closingHours: '19:00', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Shopping', 'Histoire'], city: 'Istanbul', district: 'Beyazıt', hasParking: true, hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en', 'fr', 'de'], metroStation: 'Beyazıt'),
    POI(id: 'ist_004', name: 'Palais de Topkapi', nameTr: 'Topkapı Sarayı', nameEn: 'Topkapi Palace', description: 'Résidence des sultans 400 ans, trésors de l\'Empire ottoman.', descriptionTr: '400 yıl sultanların ikametgahı.', descriptionEn: 'Sultans\' residence for 400 years.', location: LatLng(41.0045, 28.9838), category: 'palace', rating: 4.8, reviewCount: 35789, address: 'Sultanahmet, Istanbul', phone: '+90 212 512 04 80', openingHours: '09:00', closingHours: '17:00', entranceFee: 20.0, bestTime: 'Matin', tags: ['UNESCO', 'Ottoman'], city: 'Istanbul', district: 'Sultanahmet', hasWheelchair: true, estimatedMinutes: 180, languages: ['tr', 'en', 'fr'], metroStation: 'Sultanahmet'),
    POI(id: 'ist_005', name: 'Basilique Citerne', nameTr: 'Yerebatan Sarnıcı', nameEn: 'Basilica Cistern', description: 'Citerne byzantine 80 000 m³, piliers à tête de Méduse.', descriptionTr: '80.000 m³ Bizans sarnıcı.', descriptionEn: 'Byzantine cistern 80,000 m³.', location: LatLng(41.0084, 28.9759), category: 'historical', rating: 4.6, reviewCount: 22145, address: 'Sultanahmet, Istanbul', openingHours: '09:00', closingHours: '18:30', entranceFee: 15.0, bestTime: 'Midi', tags: ['Byzantin', 'Insolite'], city: 'Istanbul', district: 'Sultanahmet', hasWheelchair: true, estimatedMinutes: 60, languages: ['tr', 'en', 'fr'], metroStation: 'Sultanahmet'),
    POI(id: 'ist_006', name: 'Tour de Galata', nameTr: 'Galata Kulesi', nameEn: 'Galata Tower', description: 'Tour génoise 67m, vue panoramique 360° sur Istanbul.', descriptionTr: '67m Ceneviz kulesi, 360° panorama.', descriptionEn: '67m Genoese tower, 360° view.', location: LatLng(41.0527, 28.9745), category: 'landmark', rating: 4.7, reviewCount: 26789, address: 'Galata, Istanbul', openingHours: '08:00', closingHours: '22:00', entranceFee: 10.0, bestTime: 'Coucher de soleil', tags: ['Vue', 'Moyen Âge'], city: 'Istanbul', district: 'Galata', estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], metroStation: 'Şişhane'),
    POI(id: 'ist_007', name: 'Palais Dolmabahçe', nameTr: 'Dolmabahçe Sarayı', nameEn: 'Dolmabahçe Palace', description: '285 pièces, lustre 4.5 tonnes cristal Bohême.', descriptionTr: '285 oda, 4,5 ton kristal avize.', descriptionEn: '285 rooms, 4.5 tonne crystal chandelier.', location: LatLng(41.0401, 29.0014), category: 'palace', rating: 4.8, reviewCount: 28934, address: 'Dolmabahçe, Istanbul', phone: '+90 212 236 90 00', openingHours: '09:00', closingHours: '16:00', entranceFee: 30.0, bestTime: 'Matin', tags: ['Ottoman', 'Luxe'], city: 'Istanbul', district: 'Dolmabahçe', hasParking: true, hasWheelchair: true, estimatedMinutes: 150, languages: ['tr', 'en', 'fr'], metroStation: 'Dolmabahçe'),
    POI(id: 'ist_008', name: 'Rue Istiklal', nameTr: 'İstiklal Caddesi', nameEn: 'Istiklal Avenue', description: 'Rue piétonne 1.4km, Belle Époque, boutiques, cafés.', descriptionTr: '1,4 km yaya sokağı.', descriptionEn: '1.4 km pedestrian street.', location: LatLng(41.0312, 28.9738), category: 'landmark', rating: 4.7, reviewCount: 34567, address: 'Beyoğlu, Istanbul', openingHours: '24h', entranceFee: 0.0, bestTime: 'Après-midi', tags: ['Shopping', 'Promenade'], city: 'Istanbul', district: 'Beyoğlu', hasWifi: true, estimatedMinutes: 120, languages: ['tr', 'en', 'fr'], metroStation: 'Şişhane'),
    POI(id: 'ist_009', name: 'Place Taksim', nameTr: 'Taksim Meydanı', nameEn: 'Taksim Square', description: 'Place centrale, monument de la République.', descriptionTr: 'Merkezi meydan.', descriptionEn: 'Central square.', location: LatLng(41.0366, 28.9857), category: 'landmark', rating: 4.4, reviewCount: 19876, address: 'Beyoğlu, Istanbul', openingHours: '24h', entranceFee: 0.0, bestTime: 'Soir', tags: ['Centre-ville'], city: 'Istanbul', district: 'Beyoğlu', hasWheelchair: true, hasWifi: true, estimatedMinutes: 60, languages: ['tr', 'en'], metroStation: 'Taksim'),
    POI(id: 'ist_010', name: 'Musée archéologique', nameTr: 'İstanbul Arkeoloji Müzeleri', nameEn: 'Istanbul Archaeological Museums', description: 'Sarcophages royaux, artéfacts anatoliens.', descriptionTr: 'Kraliyet lahitleri.', descriptionEn: 'Royal sarcophagi.', location: LatLng(41.0059, 28.9826), category: 'museum', rating: 4.5, reviewCount: 12345, address: 'Sarayburnu, Istanbul', openingHours: '09:00', closingHours: '17:00', entranceFee: 15.0, bestTime: 'Matin', tags: ['Musée', 'Archéologie'], city: 'Istanbul', district: 'Sultanahmet', hasWheelchair: true, estimatedMinutes: 120, languages: ['tr', 'en', 'fr'], metroStation: 'Gülhane'),
    POI(id: 'ist_011', name: 'Marché aux épices', nameTr: 'Mısır Çarşısı', nameEn: 'Spice Bazaar', description: 'Épices, thés, douceurs turques depuis 1660.', descriptionTr: '1660\'dan beri baharat pazarı.', descriptionEn: 'Spice market since 1660.', location: LatLng(41.0175, 28.9696), category: 'shopping', rating: 4.6, reviewCount: 15678, address: 'Eminönü, Istanbul', openingHours: '08:00', closingHours: '19:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Épices', 'Gastronomie'], city: 'Istanbul', district: 'Eminönü', estimatedMinutes: 60, languages: ['tr', 'en', 'fr', 'ar'], metroStation: 'Eminönü'),
    POI(id: 'ist_012', name: 'Forteresse de Rumeli Hisarı', nameTr: 'Rumeli Hisarı', nameEn: 'Rumeli Fortress', description: 'Forteresse ottomane 1452, 3 tours massives.', descriptionTr: '1452 Osmanlı kalesi.', descriptionEn: '1452 Ottoman fortress.', location: LatLng(41.0819, 29.0566), category: 'historical', rating: 4.7, reviewCount: 12345, address: 'Rumeli Hisarı, Istanbul', openingHours: '09:00', closingHours: '17:00', entranceFee: 8.0, bestTime: 'Matin', tags: ['Ottoman', 'Fortress'], city: 'Istanbul', district: 'Rumeli Hisarı', hasWheelchair: true, estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_013', name: 'Parc de Gülhane', nameTr: 'Gülhane Parkı', nameEn: 'Gülhane Park', description: 'Ancien jardin impérial, roses, fontaines.', descriptionTr: 'Eski saray bahçesi.', descriptionEn: 'Former imperial garden.', location: LatLng(41.0066, 28.9832), category: 'nature', rating: 4.5, reviewCount: 8765, address: 'Gülhane, Istanbul', openingHours: '07:00', closingHours: '22:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Parc', 'Roseraie'], city: 'Istanbul', district: 'Sultanahmet', hasWheelchair: true, estimatedMinutes: 60, languages: ['tr', 'en'], metroStation: 'Gülhane'),
    POI(id: 'ist_014', name: 'Tour de la Pelerine', nameTr: 'Kız Kulesi', nameEn: 'Maidens Tower', description: 'Tour sur îlot, légende de la jeune fille.', descriptionTr: 'Efsanevi ada kulesi.', descriptionEn: 'Legendary islet tower.', location: LatLng(41.0215, 29.0055), category: 'landmark', rating: 4.6, reviewCount: 18765, address: 'Üsküdar, Istanbul', openingHours: '10:00', closingHours: '22:00', entranceFee: 15.0, bestTime: 'Coucher de soleil', tags: ['Vue', 'Romantique', 'Légende'], city: 'Istanbul', district: 'Üsküdar', estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_015', name: 'Aqueduc de Valens', nameTr: 'Bozdoğan Kemeri', nameEn: 'Valens Aqueduct', description: 'Aqueduc byzantin 368, 970m de long.', descriptionTr: '368 yılında inşa edilen su kemeri.', descriptionEn: '368 AD Byzantine aqueduct.', location: LatLng(41.0164, 28.9547), category: 'historical', rating: 4.3, reviewCount: 3456, address: 'Aksaray, Istanbul', openingHours: '24h', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Byzantin', 'Architecture'], city: 'Istanbul', district: 'Fatih', estimatedMinutes: 30, languages: ['tr', 'en'], metroStation: 'Aksaray'),
    POI(id: 'ist_016', name: 'Quartier de Balat', nameTr: 'Balat', nameEn: 'Balat District', description: 'Quartier historique juif, maisons colorées.', descriptionTr: 'Tarihi Yahudi Mahallesi.', descriptionEn: 'Historic Jewish quarter.', location: LatLng(41.0315, 28.9423), category: 'historical', rating: 4.5, reviewCount: 6543, address: 'Balat, Istanbul', openingHours: '24h', entranceFee: 0.0, bestTime: 'Matin', tags: ['Histoire', 'Photos', 'Coloré'], city: 'Istanbul', district: 'Balat', estimatedMinutes: 120, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_017', name: 'Mosquée Ortaköy', nameTr: 'Büyük Mecidiye Camii', nameEn: 'Ortaköy Mosque', description: 'Mosquée baroque au bord du Bosphore.', descriptionTr: 'Boğaz kıyısında barok camii.', descriptionEn: 'Baroque mosque on Bosphorus.', location: LatLng(41.0460, 29.0289), category: 'religious', rating: 4.7, reviewCount: 9876, address: 'Ortaköy, Istanbul', openingHours: '08:00', closingHours: '22:00', entranceFee: 0.0, bestTime: 'Soir', tags: ['Bosphore', 'Baroque', 'Or'], city: 'Istanbul', district: 'Ortaköy', hasWheelchair: true, estimatedMinutes: 45, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_018', name: 'Café Pierre Loti', nameTr: 'Pierre Loti Kahvesi', nameEn: 'Pierre Loti Café', description: 'Café historique, vue Corne d\'Or.', descriptionTr: 'Haliç manzaralı tarihi kafe.', descriptionEn: 'Historic café, Golden Horn view.', location: LatLng(41.0475, 28.9649), category: 'restaurant', rating: 4.4, reviewCount: 8234, address: 'Eyüp, Istanbul', openingHours: '09:00', closingHours: '23:00', entranceFee: 0.0, bestTime: 'Coucher de soleil', tags: ['Vue', 'Romantique', 'Thé turc'], city: 'Istanbul', district: 'Eyüp', hasWifi: true, estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], averagePrice: 5.0),
    POI(id: 'ist_019', name: 'Quartier Moda', nameTr: 'Moda', nameEn: 'Moda District', description: 'Quartier branché, cafés, marché du dimanche.', descriptionTr: 'Trend mahalle.', descriptionEn: 'Trendy district.', location: LatLng(40.9823, 29.0286), category: 'landmark', rating: 4.6, reviewCount: 8765, address: 'Kadıköy, Istanbul', openingHours: '24h', entranceFee: 0.0, bestTime: 'Dimanche', tags: ['Bohème', 'Café', 'Marché'], city: 'Istanbul', district: 'Kadıköy', hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en'], metroStation: 'Kadıköy'),
    POI(id: 'ist_020', name: 'Murailles de Constantinople', nameTr: 'Konstantinopolis Sur Duvarları', nameEn: 'Theodosian Walls', description: 'Murailles 408-450, 6.5km de long.', descriptionTr: '408-450 yılları arasında inşa edilen surlar.', descriptionEn: 'Walls built 408-450 AD.', location: LatLng(41.0081, 28.9324), category: 'historical', rating: 4.4, reviewCount: 5678, address: 'Yedikule, Istanbul', openingHours: '08:00', closingHours: '19:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Byzantin', 'Histoire', 'Fortification'], city: 'Istanbul', district: 'Yedikule', estimatedMinutes: 90, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_021', name: 'Forum Istanbul', nameTr: 'Forum İstanbul', nameEn: 'Forum Istanbul Mall', description: 'Centre commercial 100 000m², cinéma, patinoire.', descriptionTr: '100.000 m² alışveriş merkezi.', descriptionEn: '100,000 m² shopping mall.', location: LatLng(41.0445, 28.9499), category: 'shopping', rating: 4.3, reviewCount: 12345, address: 'Bayrampaşa, Istanbul', openingHours: '10:00', closingHours: '22:00', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Shopping', 'Cinéma'], city: 'Istanbul', district: 'Bayrampaşa', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en'], metroStation: null),
    POI(id: 'ist_022', name: 'Centre commercial Kanyon', nameTr: 'Kanyon', nameEn: 'Kanyon Mall', description: 'Architecture en canyon, boutiques luxe.', descriptionTr: 'Kanyon şeklinde mimari.', descriptionEn: 'Canyon architecture.', location: LatLng(41.0811, 29.0110), category: 'shopping', rating: 4.5, reviewCount: 10987, address: 'Levent, Istanbul', openingHours: '10:00', closingHours: '22:00', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Luxe', 'Design', 'Architecture'], city: 'Istanbul', district: 'Levent', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 120, languages: ['tr', 'en'], metroStation: 'Levent'),
    POI(id: 'ist_023', name: 'Parc d\'Emirgan', nameTr: 'Emirgan Korusu', nameEn: 'Emirgan Grove', description: '117 acres, millions de tulipes au printemps.', descriptionTr: '117 dönüm, milyonlarca lale.', descriptionEn: '117 acres, million tulips.', location: LatLng(41.1078, 29.0568), category: 'nature', rating: 4.7, reviewCount: 9876, address: 'Emirgan, Istanbul', openingHours: '07:00', closingHours: '21:00', entranceFee: 0.0, bestTime: 'Printemps', tags: ['Parc', 'Tulipes', 'Bosphore'], city: 'Istanbul', district: 'Emirgan', hasParking: true, hasWheelchair: true, estimatedMinutes: 120, languages: ['tr', 'en', 'fr'], metroStation: null),
    POI(id: 'ist_024', name: 'Forêt de Belgrade', nameTr: 'Belgrad Ormanı', nameEn: 'Belgrade Forest', description: '5500 hectares de pins et chênes.', descriptionTr: '5500 hektarlık orman.', descriptionEn: '5500 hectares forest.', location: LatLng(41.1245, 28.9747), category: 'nature', rating: 4.6, reviewCount: 6543, address: 'Sarıyer, Istanbul', openingHours: '08:00', closingHours: '20:00', entranceFee: 0.0, bestTime: 'Week-end', tags: ['Forêt', 'Randonnée', 'Nature'], city: 'Istanbul', district: 'Sarıyer', hasParking: true, estimatedMinutes: 240, languages: ['tr', 'en'], metroStation: null),
    POI(id: 'ist_025', name: 'Musée Saklı Yere', nameTr: 'Saklı Yere', nameEn: 'Hidden Valley', description: 'Canyon caché, piscines naturelles.', descriptionTr: 'Gizli kanyon.', descriptionEn: 'Hidden canyon.', location: LatLng(41.1245, 28.9747), category: 'nature', rating: 4.7, reviewCount: 7654, address: 'Sarıyer, Istanbul', openingHours: '08:00', closingHours: '18:00', entranceFee: 5.0, bestTime: 'Été', tags: ['Randonnée', 'Natation', 'Nature'], city: 'Istanbul', district: 'Sarıyer', hasParking: true, estimatedMinutes: 180, languages: ['tr', 'en'], metroStation: null),
    POI(id: 'ant_001', name: 'Kaleiçi (Vieux quartier)', nameTr: 'Kaleiçi', nameEn: 'Kaleici Old Town', description: 'Quartier historique, maisons ottomanes, portes romaines.', descriptionTr: 'Tarihi mahalle.', descriptionEn: 'Historic old town.', location: LatLng(36.8878, 30.7013), category: 'historical', rating: 4.6, reviewCount: 23456, address: 'Kaleiçi, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Soir', tags: ['Ottoman', 'Romantique', 'Restaurants'], city: 'Antalya', district: 'Kaleiçi', hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de', 'ru']),
    POI(id: 'ant_002', name: 'Porte d\'Hadrien', nameTr: 'Hadrian Kapısı', nameEn: 'Hadrians Gate', description: 'Monument marbre 130 après J.-C.', descriptionTr: 'MS 130 mermer anıt.', descriptionEn: '130 AD marble monument.', location: LatLng(36.8880, 30.7034), category: 'historical', rating: 4.4, reviewCount: 12345, address: 'Kaleiçi, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Soir', tags: ['Romain', 'Monument', 'Photo'], city: 'Antalya', district: 'Kaleiçi', estimatedMinutes: 30, languages: ['tr', 'en', 'de', 'ru']),
    POI(id: 'ant_003', name: 'Musée d\'Antalya', nameTr: 'Antalya Müzesi', nameEn: 'Antalya Museum', description: '5000 objets, sculptures romaines/byzantines.', descriptionTr: '5.000 eser, Roma/Bizans heykelleri.', descriptionEn: '5000 objects, Roman/Byzantine statues.', location: LatLng(36.8892, 30.7158), category: 'museum', rating: 4.6, reviewCount: 14567, address: 'Konyaaltı, Antalya', phone: '+90 242 238 58 88', openingHours: '08:00', closingHours: '20:00', entranceFee: 12.0, bestTime: 'Matin', tags: ['Musée', 'Archéologie', 'Romain'], city: 'Antalya', district: 'Konyaaltı', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 120, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_004', name: 'Plage de Konyaaltı', nameTr: 'Konyaaltı Sahili', nameEn: 'Konyaaltı Beach', description: 'Plage 13km, eaux turquoise, Taurus.', descriptionTr: '13 km plaj.', descriptionEn: '13 km beach.', location: LatLng(36.8833, 30.6333), category: 'beach', rating: 4.5, reviewCount: 18765, address: 'Konyaaltı, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Matin', tags: ['Plage', 'Natation', 'Famille'], city: 'Antalya', district: 'Konyaaltı', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_005', name: 'Cascade de Düden', nameTr: 'Düden Şelalesi', nameEn: 'Düden Waterfall', description: 'Cascade 20m dans la Méditerranée.', descriptionTr: '20 m şelale.', descriptionEn: '20m waterfall.', location: LatLng(36.8565, 30.6441), category: 'nature', rating: 4.6, reviewCount: 10987, address: 'Düdenbaşı, Antalya', openingHours: '08:00', closingHours: '20:00', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Cascade', 'Nature', 'Pique-nique'], city: 'Antalya', district: 'Düdenbaşı', hasParking: true, hasWheelchair: true, estimatedMinutes: 90, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_006', name: 'Canyon de Koprulü', nameTr: 'Köprülü Kanyonu', nameEn: 'Köprülü Canyon', description: '14km, rafting, canyoning.', descriptionTr: '14 km kanyon.', descriptionEn: '14 km canyon.', location: LatLng(37.0958, 31.2528), category: 'nature', rating: 4.8, reviewCount: 15678, address: 'Köprülü, Antalya', openingHours: '08:00', closingHours: '18:00', entranceFee: 0.0, bestTime: 'Été', tags: ['Rafting', 'Aventure', 'Canyon'], city: 'Antalya', district: 'Köprülü', hasParking: true, estimatedMinutes: 240, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_007', name: 'Aspendos', nameTr: 'Aspendos Tiyatrosu', nameEn: 'Aspendos Theatre', description: 'Théâtre 15000 places, opéra été.', descriptionTr: '15.000 kişilik tiyatro.', descriptionEn: '15,000-seat theater.', location: LatLng(36.9388, 31.0477), category: 'historical', rating: 4.7, reviewCount: 12345, address: 'Serik, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 15.0, bestTime: 'Soir', tags: ['Romain', 'Opéra', 'Histoire'], city: 'Antalya', district: 'Serik', hasParking: true, hasWheelchair: true, estimatedMinutes: 120, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_008', name: 'Perge', nameTr: 'Perge', nameEn: 'Perge', description: 'Théâtre 15000, stade 12000, mosaïques.', descriptionTr: '15.000 kişilik tiyatro.', descriptionEn: '15,000-seat theater.', location: LatLng(36.9677, 30.8536), category: 'historical', rating: 4.6, reviewCount: 10987, address: 'Aksu, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 12.0, bestTime: 'Matin', tags: ['Grèc', 'Romain', 'Mosaïque'], city: 'Antalya', district: 'Aksu', hasParking: true, estimatedMinutes: 150, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_009', name: 'Side', nameTr: 'Side', nameEn: 'Side', description: 'Temple Apollon, théâtre roche, ruines.', descriptionTr: 'Apollon tapınağı.', descriptionEn: 'Temple of Apollo.', location: LatLng(36.7692, 31.3911), category: 'historical', rating: 4.8, reviewCount: 18765, address: 'Side, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 15.0, bestTime: 'Coucher de soleil', tags: ['Romain', 'Apollon', 'Plage'], city: 'Antalya', district: 'Side', hasParking: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_010', name: 'Plage de Lara', nameTr: 'Lara Sahili', nameEn: 'Lara Beach', description: '15km sable fin, eaux turquoise.', descriptionTr: '15 km ince kum plajı.', descriptionEn: '15 km fine sand beach.', location: LatLng(36.8535, 30.7838), category: 'beach', rating: 4.7, reviewCount: 19876, address: 'Lara, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Matin', tags: ['Plage', 'Luxe', 'Coucher de soleil'], city: 'Antalya', district: 'Lara', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_011', name: 'Plage de Çıralı', nameTr: 'Çıralı Sahili', nameEn: 'Çıralı Beach', description: 'Tortues Caouanne, plage préservée.', descriptionTr: 'Kaplumbağa plajı.', descriptionEn: 'Turtle nesting beach.', location: LatLng(36.4013, 30.4749), category: 'beach', rating: 4.8, reviewCount: 8765, address: 'Çıralı, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Juin-Juillet', tags: ['Nature', 'Tortues', 'Authentique'], city: 'Antalya', district: 'Çıralı', estimatedMinutes: 180, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_012', name: 'Olympos', nameTr: 'Olimpos', nameEn: 'Olympos', description: 'Ville gréco-romaine, vallée luxuriante.', descriptionTr: 'Antik Yunan-Roma kenti.', descriptionEn: 'Ancient Greco-Roman city.', location: LatLng(36.4066, 30.4761), category: 'historical', rating: 4.6, reviewCount: 7654, address: 'Olympos, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 10.0, bestTime: 'Matin', tags: ['Grèc', 'Forêt', 'Randonnée'], city: 'Antalya', district: 'Olympos', estimatedMinutes: 180, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_013', name: 'Montagne du Chimaera', nameTr: 'Yanartaş', nameEn: 'Chimaera Mountain', description: 'Flammes naturelles depuis 2500 ans.', descriptionTr: '2500 yıldır yanan alevler.', descriptionEn: 'Flames burning 2500 years.', location: LatLng(36.3908, 30.4644), category: 'nature', rating: 4.5, reviewCount: 4321, address: 'Olympos, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Nuit', tags: ['Nature', 'Flammes', 'Unique'], city: 'Antalya', district: 'Olympos', estimatedMinutes: 90, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_014', name: 'Termessos', nameTr: 'Termessos', nameEn: 'Termessos', description: 'Cité 1000m altitude, théâtre nuages.', descriptionTr: '1000 m yükseklikte antik kent.', descriptionEn: 'Ancient city at 1000m altitude.', location: LatLng(36.9758, 30.2879), category: 'historical', rating: 4.9, reviewCount: 9876, address: 'Termessos, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 12.0, bestTime: 'Matin', tags: ['Montagne', 'Théâtre', 'Randonnée'], city: 'Antalya', district: 'Termessos', hasParking: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_015', name: 'Cascade de Manavgat', nameTr: 'Manavgat Şelalesi', nameEn: 'Manavgat Waterfall', description: 'Cascade 5m, parc paysager.', descriptionTr: '5 m şelale.', descriptionEn: '5m waterfall.', location: LatLng(37.1658, 31.3947), category: 'nature', rating: 4.6, reviewCount: 7654, address: 'Manavgat, Antalya', openingHours: '08:00', closingHours: '20:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Cascade', 'Famille'], city: 'Antalya', district: 'Manavgat', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 90, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_016', name: 'Bazar de Manavgat', nameTr: 'Manavgat Pazarı', nameEn: 'Manavgat Bazaar', description: 'Marché lundi/jeudi, tapis, épices.', descriptionTr: 'Pazartesi/perşembe pazarı.', descriptionEn: 'Monday/Thursday market.', location: LatLng(37.1628, 31.3939), category: 'shopping', rating: 4.4, reviewCount: 5432, address: 'Manavgat, Antalya', openingHours: '08:00', closingHours: '18:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Marché', 'Tapis'], city: 'Antalya', district: 'Manavgat', hasParking: true, estimatedMinutes: 120, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_017', name: 'Plage de Kleopatra', nameTr: 'Kleopatra Sahili', nameEn: 'Kleopatra Beach', description: 'Plage nommée d\'après Cléopâtre.', descriptionTr: 'Kleopatra adlı plaj.', descriptionEn: 'Beach named after Cleopatra.', location: LatLng(36.4489, 32.0833), category: 'beach', rating: 4.5, reviewCount: 8765, address: 'Alanya, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Matin', tags: ['Plage', 'Cléopâtre', 'Natation'], city: 'Antalya', district: 'Alanya', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 180, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_018', name: 'Forteresse d\'Alanya', nameTr: 'Alanya Kalesi', nameEn: 'Alanya Castle', description: 'Forteresse seldjoukide 13e siècle, 140 tours.', descriptionTr: '13. yüzyıl Selçuklu kalesi.', descriptionEn: '13th century Seljuk fortress.', location: LatLng(36.5633, 31.9953), category: 'historical', rating: 4.7, reviewCount: 10987, address: 'Alanya, Antalya', openingHours: '08:00', closingHours: '19:00', entranceFee: 8.0, bestTime: 'Coucher de soleil', tags: ['Seldjoukide', 'Forteresse', 'Vue'], city: 'Antalya', district: 'Alanya', estimatedMinutes: 120, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_019', name: 'Grotte de Damlataş', nameTr: 'Damlataş Mağarası', nameEn: 'Damlataş Cave', description: 'Grotte thérapeutique asthme.', descriptionTr: 'Astım tedavi mağarası.', descriptionEn: 'Asthma therapy cave.', location: LatLng(36.5475, 31.9973), category: 'nature', rating: 4.4, reviewCount: 6543, address: 'Alanya, Antalya', openingHours: '09:00', closingHours: '18:00', entranceFee: 8.0, bestTime: 'Toute la journée', tags: ['Grotte', 'Santé'], city: 'Antalya', district: 'Alanya', hasParking: true, estimatedMinutes: 60, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_020', name: 'Port de Kaleiçi', nameTr: 'Kaleiçi Limanı', nameEn: 'Kaleici Marina', description: 'Port historique, marina moderne.', descriptionTr: 'Tarihi liman.', descriptionEn: 'Historic harbor.', location: LatLng(36.8911, 30.6985), category: 'port', rating: 4.4, reviewCount: 6543, address: 'Kaleiçi, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Soir', tags: ['Port', 'Marina', 'Restaurant'], city: 'Antalya', district: 'Kaleiçi', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 90, languages: ['tr', 'en', 'de', 'ru'], averagePrice: 15.0),
    POI(id: 'ant_021', name: 'Aqualand Antalya', nameTr: 'Aqualand Antalya', nameEn: 'Aqualand', description: 'Parc aquatique, toboggans extrême.', descriptionTr: 'Su parkı.', descriptionEn: 'Water park.', location: LatLng(36.8555, 30.7755), category: 'activities', rating: 4.4, reviewCount: 10987, address: 'Lara, Antalya', openingHours: '10:00', closingHours: '18:00', entranceFee: 25.0, bestTime: 'Été', tags: ['Parc aquatique', 'Famille', 'Toboggans'], city: 'Antalya', district: 'Lara', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 240, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_022', name: 'Antalya Opera', nameTr: 'Antalya Opera ve Bale', nameEn: 'Antalya Opera', description: 'Opéra 750 places, programmation internationale.', descriptionTr: '750 kişilik opera.', descriptionEn: '750-seat opera.', location: LatLng(36.8844, 30.7041), category: 'activities', rating: 4.5, reviewCount: 4321, address: 'Konyaaltı, Antalya', phone: '+90 242 242 00 20', openingHours: 'Varies', entranceFee: 15.0, bestTime: 'Soir', tags: ['Opéra', 'Ballet', 'Culture'], city: 'Antalya', district: 'Konyaaltı', hasParking: true, hasWheelchair: true, estimatedMinutes: 150, languages: ['tr', 'en'], metroStation: null),
    POI(id: 'ant_023', name: 'Musée d\'Alanya', nameTr: 'Alanya Müzesi', nameEn: 'Alanya Museum', description: '5000 ans d\'histoire régionale.', descriptionTr: '5000 yıllık tarih.', descriptionEn: '5000 years of history.', location: LatLng(36.5622, 31.9953), category: 'museum', rating: 4.3, reviewCount: 3210, address: 'Alanya, Antalya', openingHours: '08:00', closingHours: '17:00', entranceFee: 5.0, bestTime: 'Matin', tags: ['Musée', 'Archéologie', 'Seldjoukide'], city: 'Antalya', district: 'Alanya', hasParking: true, hasWheelchair: true, estimatedMinutes: 90, languages: ['tr', 'en', 'de'], metroStation: null),
    POI(id: 'ant_024', name: 'Saklıköy', nameTr: 'Saklıköy', nameEn: 'Saklıköy', description: 'Village traditionnel, sources naturelles.', descriptionTr: 'Geleneksel köy.', descriptionEn: 'Traditional village.', location: LatLng(36.8565, 30.6441), category: 'nature', rating: 4.3, reviewCount: 3210, address: 'Saklıköy, Antalya', openingHours: '24h', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Village', 'Randonnée', 'Nature'], city: 'Antalya', district: 'Düdenbaşı', estimatedMinutes: 180, languages: ['tr', 'en'], metroStation: null),
    POI(id: 'ant_025', name: 'Restaurant Selamlık', nameTr: 'Selamlık', nameEn: 'Selamlık', description: 'Cuisine anatolienne, terrasse vue Kaleiçi.', descriptionTr: 'Anadolu mutfağı.', descriptionEn: 'Anatolian cuisine.', location: LatLng(36.8878, 30.7013), category: 'restaurant', rating: 4.6, reviewCount: 5432, address: 'Kaleiçi, Antalya', openingHours: '12:00', closingHours: '23:00', entranceFee: 0.0, bestTime: 'Dîner', tags: ['Cuisine turque', 'Mezze', 'Vue'], city: 'Antalya', district: 'Kaleiçi', estimatedMinutes: 90, languages: ['tr', 'en', 'de'], cuisine: 'Turque', averagePrice: 12.0),
    POI(id: 'ant_026', name: 'Restaurant Ciya', nameTr: 'Ciya Sofrası', nameEn: 'Ciya Restaurant', description: 'Cuisine anatolienne authentique depuis 1986.', descriptionTr: '1986\'dan beri Anadolu mutfağı.', descriptionEn: 'Anatolian cuisine since 1986.', location: LatLng(36.8878, 30.7013), category: 'restaurant', rating: 4.7, reviewCount: 8765, address: 'Kaleiçi, Antalya', openingHours: '07:00', closingHours: '23:00', entranceFee: 0.0, bestTime: 'Déjeuner', tags: ['Cuisine turque', 'Tradition', 'Anatolien'], city: 'Antalya', district: 'Kaleiçi', estimatedMinutes: 90, languages: ['tr', 'en'], cuisine: 'Turque', averagePrice: 8.0),
    POI(id: 'ant_027', name: 'Centre commercial Terracity', nameTr: 'Terracity', nameEn: 'Terracity Mall', description: 'Centre commercial luxe, vue Méditerranée.', descriptionTr: 'Lüks alışveriş merkezi.', descriptionEn: 'Luxury shopping mall.', location: LatLng(36.8622, 30.7233), category: 'shopping', rating: 4.5, reviewCount: 8765, address: 'Lara, Antalya', openingHours: '10:00', closingHours: '22:00', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Shopping', 'Luxe'], city: 'Antalya', district: 'Lara', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 120, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_028', name: 'Shakepeare Coffee', nameTr: 'Shakespeare Coffee', nameEn: 'Shakespeare Coffee', description: 'Café specialty coffee, Kaleiçi.', descriptionTr: 'Özel kahve.', descriptionEn: 'Specialty coffee.', location: LatLng(36.8878, 30.7013), category: 'restaurant', rating: 4.4, reviewCount: 3210, address: 'Kaleiçi, Antalya', openingHours: '08:00', closingHours: '23:00', entranceFee: 0.0, bestTime: 'Matin', tags: ['Café', 'Specialty coffee'], city: 'Antalya', district: 'Kaleiçi', hasWifi: true, estimatedMinutes: 45, languages: ['tr', 'en'], averagePrice: 4.0),
    POI(id: 'ant_029', name: 'Antalya Aquarium', nameTr: 'Antalya Akvaryumu', nameEn: 'Antalya Aquarium', description: 'Tunnel 120m, monde sous-marin.', descriptionTr: '120 m tünel akvaryum.', descriptionEn: '120m tunnel aquarium.', location: LatLng(36.8622, 30.7233), category: 'activities', rating: 4.5, reviewCount: 9876, address: 'Lara, Antalya', openingHours: '10:00', closingHours: '18:00', entranceFee: 20.0, bestTime: 'Toute la journée', tags: ['Famille', 'Aquarium', 'Sous-marin'], city: 'Antalya', district: 'Lara', hasParking: true, hasWheelchair: true, hasWifi: true, estimatedMinutes: 120, languages: ['tr', 'en', 'de', 'ru'], metroStation: null),
    POI(id: 'ant_030', name: 'Miniature Turc Antalya', nameTr: 'Türkiye Minyatürleri', nameEn: 'Turkish Miniature Park', description: 'Maquettes des monuments turcs.', descriptionTr: 'Türk anıtları minyatürleri.', descriptionEn: 'Turkish monument miniatures.', location: LatLng(36.8722, 30.7333), category: 'museum', rating: 4.3, reviewCount: 6543, address: 'Lara, Antalya', openingHours: '09:00', closingHours: '18:00', entranceFee: 10.0, bestTime: 'Matin', tags: ['Miniature', 'Famille', 'Ottoman'], city: 'Antalya', district: 'Lara', hasParking: true, hasWheelchair: true, estimatedMinutes: 90, languages: ['tr', 'en', 'de'], metroStation: null),
  ];

  static List<POI> getByCity(String city) => allPOIs.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();
  static List<POI> getByCategory(String category) => allPOIs.where((p) => p.category == category).toList();
  static POI? getById(String id) { try { return allPOIs.firstWhere((p) => p.id == id); } catch (_) { return null; } }

  static List<POI> search(String query, {String? city, String? category}) {
    final q = query.toLowerCase();
    return allPOIs.where((p) {
      final matchCity = city == null || p.city.toLowerCase() == city.toLowerCase();
      final matchCat = category == null || p.category == category;
      final matchText = p.name.toLowerCase().contains(q) || p.nameTr.toLowerCase().contains(q) ||
          p.nameEn.toLowerCase().contains(q) || p.description.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
      return matchCity && matchCat && matchText;
    }).toList();
  }

  static List<String> getCategories() => allPOIs.map((p) => p.category).toSet().toList()..sort();
  static List<String> getCities() => allPOIs.map((p) => p.city).toSet().toList()..sort();
  static List<String> getDistricts(String city) => allPOIs.where((p) => p.city.toLowerCase() == city.toLowerCase()).map((p) => p.district).toSet().toList()..sort();
  static List<String> getTags() => allPOIs.expand((p) => p.tags).toSet().toList()..sort();
  static int get totalPOIs => allPOIs.length;
}