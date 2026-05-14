import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/itinerary_service.dart';
import '../models/itinerary.dart';
import '../services/itinerary_generator_service.dart';

class MapPlace {
  final String name;
  final String nameTr;
  final String description;
  final String descriptionTr;
  final LatLng location;
  final String category;
  final double rating;
  final String? openingHours;
  final double? estimatedDuration;
  final String? phone;
  final String? website;
  final String? address;
  final double? entranceFee;
  final String? bestTime;
  final List<String> tags;
  final String city;

  MapPlace({
    required this.name,
    required this.nameTr,
    required this.description,
    required this.descriptionTr,
    required this.location,
    required this.category,
    this.rating = 4.0,
    this.openingHours,
    this.estimatedDuration,
    this.phone,
    this.website,
    this.address,
    this.entranceFee,
    this.bestTime,
    this.tags = const [],
    this.city = 'Istanbul',
  });
}

class MapScreen extends StatefulWidget {
  final ItineraryItem? focusedDay;

  const MapScreen({super.key, this.focusedDay});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  FMTCTileProvider? _tileProvider;
  bool _isInitialized = false;
  String? _initError;
  String _transportMode = 'walking';
  MapPlace? _selectedPlace;
  MapController? _mapController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _showRoute = true;
  String _selectedCategory = 'all';
  bool _showTripPlanner = false;
  int _selectedDayIndex = 0;

  static const String _storeName = 'trtravel_maps';

  static final List<MapPlace> allPlaces = [
    MapPlace(
      name: 'Sainte-Sophie', nameTr: 'Ayasofya', description: 'Basilique byzantine transformée en mosquée, chef-d\'œuvre architectural classé au patrimoine mondial de l\'UNESCO. Construite en 537, elle fut la plus grande église du monde pendant près de 1000 ans.',
      descriptionTr: 'Bizans kilisesinden camiye dönüştürülmüş, UNESCO Dünya Mirası listesindeki mimari şaheser. 537 yılında inşa edilmiş, yaklaşık 1000 yıl boyunca dünyanın en büyük kilisesi olmuştur.',
      location: LatLng(41.0086, 28.9802), category: 'historical', rating: 4.9, openingHours: '09:00 - 18:00', estimatedDuration: 2.0, phone: '+90 212 522 09 89', website: 'https://ayasofya.istanbul', address: 'Sultan Ahmet Mahallesi, Istanbul', entranceFee: 25.0, bestTime: 'Matin tôt', tags: ['UNESCO', 'Byzantin', 'Architecture'], city: 'Istanbul'),
    MapPlace(
      name: 'Mosquée Bleue', nameTr: 'Sultan Ahmet Camii', description: 'Mosquée ottomane du XVIe siècle emblématique avec plus de 20 000 carreaux de faïence d\'Iznik. Ses six minarets en font un monument unique.',
      descriptionTr: '20.000\'den fazla İznik çinisi ile ünlü, 16. yüzyıldan kalma ikonik Osmanlı camii. Altı minaresi ile benzersiz bir yapıdır.',
      location: LatLng(41.0054, 28.9768), category: 'religious', rating: 4.8, openingHours: '08:00 - 18:00', estimatedDuration: 1.5, phone: '+90 212 458 63 69', address: 'Sultan Ahmet Mahallesi, Istanbul', entranceFee: 0.0, bestTime: 'Matin ou soir', tags: ['Ottoman', 'Architecture', 'Religion'], city: 'Istanbul'),
    MapPlace(
      name: 'Grand Bazar', nameTr: 'Kapalıçarşı', description: 'L\'un des plus grands marchés couverts du monde avec plus de 4000 boutiques. Fondé en 1461, c\'est l\'un des plus anciens centres commerciaux au monde.',
      descriptionTr: '4.000\'den fazla dükkanı ile dünyanın en büyük kapalı çarşılarından biri. 1461 yılında kurulmuş, dünyanın en eski alışveriş merkezlerinden biridir.',
      location: LatLng(41.0097, 28.9702), category: 'shopping', rating: 4.5, openingHours: '08:30 - 19:00', estimatedDuration: 3.0, phone: '+90 212 519 12 48', address: 'Beyazıt Mahallesi, Istanbul', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Shopping', 'Histoire', ' tradition'], city: 'Istanbul'),
    MapPlace(
      name: 'Palais de Topkapi', nameTr: 'Topkapı Sarayı', description: 'Résidence principale des sultans ottomans pendant 400 ans. Abrita l\'un des plus riches trésors impériaux包含了珠寶、武器和聖物。',
      descriptionTr: '400 yıl boyunca Osmanlı sultanlarının ana ikametgahı. mücevherler, silahlar ve kutsal emanetler içeren en zengin imparatorluk hazinelerinden birine ev sahipliği yaptı.',
      location: LatLng(41.0045, 28.9838), category: 'palace', rating: 4.8, openingHours: '09:00 - 17:00', estimatedDuration: 3.0, phone: '+90 212 512 04 80', website: 'https://topkapipalace.istanbul', address: 'Cankurtaran Mahallesi, Istanbul', entranceFee: 20.0, bestTime: 'Matin', tags: ['UNESCO', 'Ottoman', 'Trésors'], city: 'Istanbul'),
    MapPlace(
      name: 'Basilique Cistern', nameTr: 'Yerebatan Sarnıcı', description: 'Citerne souterraine byzantine du VIe siècle pouvant contenir 80 000 m³ d\'eau. Célèbre pour ses colonnes à tête de méduse inversée.',
      descriptionTr: '80.000 m³ su tutabilen, 6. yüzyıldan kalma Bizans yeraltı sarnıcı. Ters dönmüş Medusa başlarıyla ünlü sütunları ile dikkat çeker.',
      location: LatLng(41.0084, 28.9759), category: 'historical', rating: 4.6, openingHours: '09:00 - 18:30', estimatedDuration: 1.0, phone: '+90 212 383 52 34', address: 'Sultan Ahmet Mahallesi, Istanbul', entranceFee: 15.0, bestTime: 'Midi (moins de monde)', tags: ['Byzantin', 'Architecture', 'Insolite'], city: 'Istanbul'),
    MapPlace(
      name: 'Tour de Galata', nameTr: 'Galata Kulesi', description: 'Tour médiévale génoise de 67 mètres offrant une vue panoramique sur Istanbul et le Bosphore. Construite au XIVe siècle.',
      descriptionTr: '14. yüzyılda inşa edilmiş, İstanbul ve Boğaz\'ın panoramik manzarasını sunan 67 metre yüksekliğinde ortaçağ Ceneviz kulesi.',
      location: LatLng(41.0527, 28.9745), category: 'landmark', rating: 4.7, openingHours: '08:00 - 22:00', estimatedDuration: 1.5, phone: '+90 212 293 81 80', address: 'Bereketzade Mahallesi, Istanbul', entranceFee: 10.0, bestTime: 'Coucher de soleil', tags: ['Vue panoramique', 'Moyen Âge', 'Romantique'], city: 'Istanbul'),
    MapPlace(
      name: 'Palais Dolmabahçe', nameTr: 'Dolmabahçe Sarayı', description: 'Résidence officielle des sultans ottomans après Topkapi. Le plus grand palais de Турции avec 285 pièces et un lustre en cristal de Bohême de 4,5 tonnes.',
      descriptionTr: 'Topkapı\'dan sonra Osmanlı sultanlarının resmi ikametgahı. 285 oda ve 4,5 tonluk Bohemya kristal avizesiyle Türkiye\'nin en büyük sarayı.',
      location: LatLng(41.0401, 29.0014), category: 'palace', rating: 4.8, openingHours: '09:00 - 16:00', estimatedDuration: 2.5, phone: '+90 212 236 90 00', address: 'Dolmabahçe Mahallesi, Istanbul', entranceFee: 30.0, bestTime: 'Matin', tags: ['Ottoman', 'Luxe', 'Architecture'], city: 'Istanbul'),
    MapPlace(
      name: 'Mosquée de Rustempasa', nameTr: 'Rüstem Paşa Camii', description: 'Petite mosquée ottomane célèbre pour ses carrelages Iznik exceptionnels représentant des fleurs, fruits et fleurs géométriques.',
      descriptionTr: 'Çiçekleri, meyveleri ve geometrik çiçekleri tasvir eden olağanüstü İznik çinileriyle ünlü küçük Osmanlı camii.',
      location: LatLng(41.0183, 28.9696), category: 'religious', rating: 4.5, openingHours: '08:00 - 18:00', estimatedDuration: 0.5, phone: '', address: 'Rüstem Paşa Mahallesi, Istanbul', entranceFee: 0.0, bestTime: 'Matin', tags: ['Ottoman', 'Iznik', 'Art'], city: 'Istanbul'),
    MapPlace(
      name: 'Église Saint-Antoine de Padoue', nameTr: 'Sent Antuan Bazilikası', description: 'Plus grande église catholique de Istanbul, construite en style gothique vénitien avec une façade impressive.',
      descriptionTr: 'Venedik Gotik tarzında inşa edilmiş, etkileyici bir cephesi olan İstanbul\'un en büyük Katolik kilisesi.',
      location: LatLng(41.0518, 28.9881), category: 'religious', rating: 4.3, openingHours: '07:00 - 20:00', estimatedDuration: 0.5, phone: '+90 212 293 82 12', address: 'Şişhane Mahallesi, Istanbul', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Catholique', 'Gothique', 'Paix'], city: 'Istanbul'),
    MapPlace(
      name: 'Musée archéologique', nameTr: 'Arkeoloji Müzesi', description: 'Musée avec l\'une des plus grandes collections d\'artéfacts de la civilisation anatolienne, incluant les sarcophages royaux de Sichem.',
      descriptionTr: 'Anadolu uygarlıklarının en büyük eser koleksiyonlarından birine sahip müze, Sichem kraliyet lahitlerini içerir.',
      location: LatLng(41.0059, 28.9826), category: 'museum', rating: 4.5, openingHours: '09:00 - 17:00', estimatedDuration: 2.0, phone: '+90 212 517 03 30', address: 'Sarayburnu, Istanbul', entranceFee: 15.0, bestTime: 'Matin', tags: ['Musée', 'Histoire', 'Archéologie'], city: 'Istanbul'),
    MapPlace(
      name: 'Cimetière de Pierre', nameTr: 'Pierre Loti Tepesi', description: 'Colline romantique avec une vue imprenable sur la Corne d\'Or. Nommé d\'après l\'écrivain français Pierre Loti qui y venait souvent.',
      descriptionTr: 'Haliç\'e muhteşem manzarası olan romantik tepe. Sık sık buraya gelen Fransız yazar Pierre Loti\'nin adını almıştır.',
      location: LatLng(41.0475, 28.9649), category: 'nature', rating: 4.6, openingHours: '08:00 - 22:00', estimatedDuration: 1.5, phone: '', address: 'Eyüp, Istanbul', entranceFee: 0.0, bestTime: 'Coucher de soleil', tags: ['Vue', 'Romantique', 'Nature'], city: 'Istanbul'),
    MapPlace(
      name: 'Plage de Konyaaltı', nameTr: 'Konyaaltı Sahili', description: 'Plage emblématiques de 13 km le long de la Méditerranée avec vue sur les montagnes du Taurus et une infrastructure complète.',
      descriptionTr: 'Toros Dağları manzarası ve tam altyapı ile Akdeniz boyunca uzanan 13 km\'lik ünlü plaj.',
      location: LatLng(36.8833, 30.6333), category: 'beach', rating: 4.5, openingHours: '24h', estimatedDuration: 2.0, phone: '', address: 'Konyaaltı, Antalya', entranceFee: 0.0, bestTime: 'Matin ou fin d\'après-midi', tags: ['Plage', 'Méditerranée', 'Détente'], city: 'Antalya'),
    MapPlace(
      name: 'Plage de Lara', nameTr: 'Lara Sahili', description: 'Plage de sable fin de 15 km avec eaux turquoise cristallines, l\'une des plus belles de la Méditerranée turque.',
      descriptionTr: 'Turkuaz kristal berrak suları olan 15 km\'lik ince kumlu plaj, Türk Akdenizi\'nin en güzel plajlarından biri.',
      location: LatLng(36.8535, 30.7838), category: 'beach', rating: 4.7, openingHours: '24h', estimatedDuration: 2.0, phone: '', address: 'Lara, Antalya', entranceFee: 0.0, bestTime: 'Matin', tags: ['Plage', 'Luxe', 'Sable fin'], city: 'Antalya'),
    MapPlace(
      name: 'Plage de Çıralı', nameTr: 'Çıralı Sahili', description: 'Plage préservée près des ruines de Olympos, célèbre pour les tortues Caouanne qui viennent nicher. Ambiente naturel et authentique.',
      descriptionTr: 'Olimpos harabelerine yakın, Caretta Caretta kaplumbağalarının yumurtlamaya geldiği ünlü, korunan plaj. Doğal ve otantik atmosfer.',
      location: LatLng(36.4013, 30.4749), category: 'beach', rating: 4.8, openingHours: '24h', estimatedDuration: 2.0, phone: '', address: 'Çıralı, Antalya', entranceFee: 0.0, bestTime: 'Juin-Juillet (tortues)', tags: ['Nature', 'Tortues', 'Authentique'], city: 'Antalya'),
    MapPlace(
      name: 'Vallée de Göreme', nameTr: 'Göreme Vadisi', description: 'Vallée avec formations rocheuses uniques (cheminées de fées) et churches rupestres byzantines inscrites au patrimoine mondial de l\'UNESCO.',
      descriptionTr: 'UNESCO Dünya Mirası listesindeki benzersiz kaya oluşumları (peribacaları) ve Bizans kayalık kiliseleri ile vadı.',
      location: LatLng(38.6431, 34.8289), category: 'nature', rating: 4.9, openingHours: '24h', estimatedDuration: 4.0, phone: '', address: 'Göreme, Nevşehir', entranceFee: 0.0, bestTime: 'Lever/coucher du soleil', tags: ['UNESCO', 'Nature', 'Aventure'], city: 'Cappadoce'),
    MapPlace(
      name: 'Cheminées de fées', nameTr: 'Peri Bacaları', description: 'Phénomène géologique unique composé de colonnes rocheuses en forme de champignons atteignant 40 mètres de hauteur.',
      descriptionTr: '40 metre yüksekliğe ulaşan mantar şeklindeki kaya sütunlarından oluşan benzersiz jeolojik fenomen.',
      location: LatLng(38.6514, 34.8356), category: 'nature', rating: 4.8, openingHours: '24h', estimatedDuration: 2.0, phone: '', address: 'Paşabağı, Nevşehir', entranceFee: 0.0, bestTime: 'Lever du soleil', tags: ['Nature', 'Géologie', 'Photo'], city: 'Cappadoce'),
    MapPlace(
      name: 'Uçhisar', nameTr: 'Uçhisar', description: 'Village troglodyte avec une forteresse rocheuse offrant la meilleure vue panoramique sur la Cappadoce.',
      descriptionTr: 'Kappadokia\'nın en iyi panoramik manzarasını sunan kaya kale ile kaya içine oyulmuş köy.',
      location: LatLng(38.6269, 34.8017), category: 'village', rating: 4.6, openingHours: '24h', estimatedDuration: 2.0, phone: '', address: 'Uçhisar, Nevşehir', entranceFee: 0.0, bestTime: 'Lever du soleil', tags: ['Village', 'Vue', 'Troglodyte'], city: 'Cappadoce'),
    MapPlace(
      name: 'Grotte de Kaymaklı', nameTr: 'Kaymaklı Yeraltı Şehri', description: 'Ville souterraine antique pouvant accueillir 20 000 personnes, l\'une des plus grandes et mieux conservées de Cappadoce.',
      descriptionTr: '20.000 kişiyi barındırabilen, Kappadokia\'nın en büyük ve en iyi korunan şehirlerinden biri olan antik yeraltı şehri.',
      location: LatLng(38.4583, 34.8644), category: 'historical', rating: 4.7, openingHours: '08:00 - 17:00', estimatedDuration: 1.5, phone: '+90 384 511 38 02', address: 'Kaymaklı, Nevşehir', entranceFee: 12.0, bestTime: 'Matin', tags: ['Troglodyte', 'Histoire', 'Insolite'], city: 'Cappadoce'),
    MapPlace(
      name: 'Anıtkabir', nameTr: 'Anıtkabir', description: 'Mausolée majestueux d\'Atatürk, fondateur de la République turque moderne. Complexe monumental de 900 000 m².',
      descriptionTr: 'Modern Türkiye\'nin kurucusu Atatürk\'ün görkemli mozolesi. 900.000 m²\'lik anıtsal kompleksi.',
      location: LatLng(39.9254, 32.8378), category: 'historical', rating: 4.8, openingHours: '09:00 - 17:00', estimatedDuration: 2.0, phone: '+90 312 231 79 05', website: 'https://ankara.adalet.gov.tr', address: 'Anıtkabir, Ankara', entranceFee: 0.0, bestTime: 'Matin', tags: ['Monument', 'Histoire', 'Patriotisme'], city: 'Ankara'),
    MapPlace(
      name: 'Musée des civilisations anatoliennes', nameTr: 'Anadolu Medeniyetleri Müzesi', description: 'Musée primé présentant l\'histoire des civilisations qui ont existé en Anatolie depuis 500 000 ans av. J.-C.',
      descriptionTr: 'M.Ö. 500.000 yılından günümüze Anadolu\'da yaşamış uygarlıkların tarihini sergileyen ödüllü müze.',
      location: LatLng(39.9383, 32.8597), category: 'museum', rating: 4.7, openingHours: '08:30 - 17:30', estimatedDuration: 2.5, phone: '+90 312 324 31 60', address: 'Ulus, Ankara', entranceFee: 10.0, bestTime: 'Matin', tags: ['Musée', 'Histoire', 'Prime'], city: 'Ankara'),
    MapPlace(
      name: 'Ephèse', nameTr: 'Efes', description: 'Ruines de l\'antique ville grecque, l\'une des mieux préservées au monde. Ancienne patrie de l\'apôtre Paul.',
      descriptionTr: 'Dünyanın en iyi korunan antik Yunan şehirlerinden biri. Apostol Pavlus\'un eski vatanı.',
      location: LatLng(37.9411, 27.3419), category: 'historical', rating: 4.9, openingHours: '08:00 - 18:00', estimatedDuration: 4.0, phone: '+90 232 892 60 48', address: 'Selçuk, İzmir', entranceFee: 20.0, bestTime: 'Matin tôt', tags: ['UNESCO', 'Grèc', 'Paul'], city: 'Izmir'),
    MapPlace(
      name: 'Agora de Smyrne', nameTr: 'Smyrna Agorası', description: 'Ruines de l\'agora grec antique restauré, avec des colonnes ioniques et une vue sur le mont Pagus.',
      descriptionTr: 'İyonik sütunları ve Pendik Dağı manzarasıyla restore edilmiş antik Yunan agorası kalıntıları.',
      location: LatLng(38.4192, 27.1336), category: 'historical', rating: 4.4, openingHours: '08:30 - 17:30', estimatedDuration: 1.5, phone: '+90 232 489 09 09', address: 'Kemeraltı, İzmir', entranceFee: 8.0, bestTime: 'Matin', tags: ['Grèc', 'Architecture', 'Histoire'], city: 'Izmir'),
    MapPlace(
      name: 'Monastère de Sumela', nameTr: 'Sümela Manastırı', description: 'Monastère byzantin médiéval accroché à flanc de falaise dans les montagnes du Pont, à 300m d\'altitude. Vue spectaculaire.',
      descriptionTr: 'Pont Dağları\'ndaki uçurum yamacına 300m yükseklikte tutturulmuş ortaçağ Bizans manastırı. Etkileyici manzara.',
      location: LatLng(40.7631, 39.6844), category: 'religious', rating: 4.9, openingHours: '08:00 - 19:00', estimatedDuration: 3.0, phone: '+90 462 712 21 36', address: 'Maçka, Trabzon', entranceFee: 15.0, bestTime: 'Matin', tags: ['Byzantin', 'Montagne', 'Spectaculaire'], city: 'Trabzon'),
    MapPlace(
      name: 'Forteresse de Trabzon', nameTr: 'Trabzon Kalesi', description: 'Forteresse byzantine et ottomane offrant une vue panoramique sur la ville et la mer Noire.',
      descriptionTr: 'Şehre ve Karadeniz\'e panoramik manzara sunan Bizans ve Osmanlı kalesi.',
      location: LatLng(41.0025, 39.7164), category: 'historical', rating: 4.5, openingHours: '08:00 - 20:00', estimatedDuration: 1.5, phone: '', address: 'Trabzon', entranceFee: 0.0, bestTime: 'Soir', tags: ['Fort', 'Vue', 'Byzantin'], city: 'Trabzon'),
    MapPlace(
      name: 'Cascade de Manavgat', nameTr: 'Manavgat Şelalesi', description: 'Magnifique cascade naturelle de 5 mètres de large avec parc paysager, à 3 km de Manavgat.',
      descriptionTr: 'Manavgat\'ın 3 km uzağında, 5 metre genişliğinde muhteşem doğal şelale ve peyzajlı park.',
      location: LatLng(37.1658, 31.3947), category: 'nature', rating: 4.6, openingHours: '08:00 - 20:00', estimatedDuration: 1.5, phone: '', address: 'Manavgat, Antalya', entranceFee: 0.0, bestTime: 'Matin', tags: ['Nature', 'cascade', 'Famille'], city: 'Antalya'),
    MapPlace(
      name: 'Canyon de Koprulü', nameTr: 'Köprülü Kanyonu', description: 'Canyon spectaculaire de 14 km pour le rafting et le canyoning. Paradis des amoureux de l\'aventure.',
      descriptionTr: 'Rafting ve kanyon tırmanışı için 14 km\'lik etkileyici kanyon. Macera tutkunları için cennet.',
      location: LatLng(37.0958, 31.2528), category: 'nature', rating: 4.8, openingHours: '08:00 - 18:00', estimatedDuration: 3.0, phone: '', address: 'Köprülü, Antalya', entranceFee: 0.0, bestTime: 'Toute la journée', tags: ['Aventure', 'Rafting', 'Canyon'], city: 'Antalya'),
    MapPlace(
      name: 'Port de Kaleiçi', nameTr: 'Kaleiçi Limanı', description: 'Port historique de Kaleiçi avec marina, restaurants au bord de l\'eau et atmosphère méditerranéenne authentique.',
      descriptionTr: 'Marina, deniz kenarında restoranlar ve otantik Akdeniz atmosferi ile Kaleiçi\'nin tarihi limanı.',
      location: LatLng(36.8911, 30.6985), category: 'port', rating: 4.4, openingHours: '24h', estimatedDuration: 1.5, phone: '', address: 'Kaleiçi, Antalya', entranceFee: 0.0, bestTime: 'Soir', tags: ['Port', 'Romantique', 'Restaurants'], city: 'Antalya'),
    MapPlace(
      name: 'Musée d\'Antalya', nameTr: 'Antalya Müzesi', description: 'Musée archéologique avec l\'une des plus riches collections de sculptures romaines et byzantines de Turquie.',
      descriptionTr: 'Türkiye\'nin en zengin Roma ve Bizans heykel koleksiyonlarından birine sahip arkeoloji müzesi.',
      location: LatLng(36.8892, 30.7158), category: 'museum', rating: 4.6, openingHours: '08:00 - 20:00', estimatedDuration: 2.0, phone: '+90 242 238 58 88', address: 'Konyaaltı, Antalya', entranceFee: 12.0, bestTime: 'Matin', tags: ['Musée', 'Archéologie', 'Romain'], city: 'Antalya'),
    MapPlace(
      name: 'Aspendos', nameTr: 'Aspendos', description: 'Théâtre romain antique de 15 000 places remarkably bien conservé, célèbre pour ses spectacles d\'opéra et de ballet.',
      descriptionTr: '15.000 kişilik, dikkat çekici şekilde korunmuş antik Roma tiyatrosu, opera ve bale gösterileriyle ünlü.',
      location: LatLng(36.9388, 31.0477), category: 'historical', rating: 4.7, openingHours: '08:00 - 19:00', estimatedDuration: 2.0, phone: '+90 242 710 15 15', address: 'Serik, Antalya', entranceFee: 15.0, bestTime: 'Matin', tags: ['Romain', 'Théâtre', 'Spectacle'], city: 'Antalya'),
    MapPlace(
      name: 'Perge', nameTr: 'Perge', description: 'Ruines antiques avec un théâtre magnifique, un stade de 15 000 places et de belles colonnes grecques.',
      descriptionTr: 'Muhteşem tiyatrosu, 15.000 kişilik stadı ve güzel Yunan sütunları ile antik kalıntılar.',
      location: LatLng(36.9677, 30.8536), category: 'historical', rating: 4.6, openingHours: '08:00 - 19:00', estimatedDuration: 2.0, phone: '+90 242 510 55 30', address: 'Aksu, Antalya', entranceFee: 12.0, bestTime: 'Matin', tags: ['Grèc', 'Romain', 'Architecture'], city: 'Antalya'),
    MapPlace(
      name: 'Vallée de l\'Ihlara', nameTr: 'Ihlara Vadisi', description: 'Vallée naturelle spectaculaire de 15 km avec des temples rupestres byzantins, des chapelle et des villages troglodytes.',
      descriptionTr: '15 km\'lik etkileyici doğal vadi, Bizans kayalık kiliseleri, şapeller ve kaya içi köyler.',
      location: LatLng(38.2428, 34.3044), category: 'nature', rating: 4.8, openingHours: '24h', estimatedDuration: 3.0, phone: '', address: 'Ihlara, Aksaray', entranceFee: 0.0, bestTime: 'Matin', tags: ['Nature', 'Byzantin', 'Randonnée'], city: 'Cappadoce'),
    MapPlace(
      name: 'Pamukkale', nameTr: 'Pamukkale', description: 'Terrasses de travertin blanc naturel et ruines de Hiérapolis, site classé au patrimoine mondial de l\'UNESCO.',
      descriptionTr: 'UNESCO Dünya Mirası listesindeki beyaz doğal traverten terasları ve Hierapolis harabeleri.',
      location: LatLng(37.9201, 29.1176), category: 'nature', rating: 5.0, openingHours: '06:00 - 22:00', estimatedDuration: 4.0, phone: '+90 258 272 20 88', address: 'Pamukkale, Denizli', entranceFee: 25.0, bestTime: 'Lever du soleil', tags: ['UNESCO', 'Nature', 'Thermal'], city: 'Izmir'),
    MapPlace(
      name: 'Vieux quartier de Kaleiçi', nameTr: 'Kaleiçi Eski Mahalle', description: 'Vieux quartier historique de Antalya avec ruelles étroites, maisons ottomanes et portes romaines préservées.',
      descriptionTr: 'Dar sokakları, Osmanlı evleri ve korunmuş Roma kapılarıyla Antalya\'nın tarihi mahallesi.',
      location: LatLng(36.8878, 30.7013), category: 'old_town', rating: 4.6, openingHours: '24h', estimatedDuration: 3.0, phone: '', address: 'Kaleiçi, Antalya', entranceFee: 0.0, bestTime: 'Soir', tags: ['Ottoman', 'Promenade', 'Histoire'], city: 'Antalya'),
    MapPlace(
      name: 'Porte d\'Hadrien', nameTr: 'Hadrian Kapısı', description: 'Monument historique en marbre blanc construit en l\'an 130 pour célébrer la visite de l\'empereur Hadrien.',
      descriptionTr: 'İmparator Hadrian\'ın ziyareti onuruna M.S. 130 yılında beyaz mermerden inşa edilmiş tarihi anıt.',
      location: LatLng(36.8880, 30.7034), category: 'landmark', rating: 4.4, openingHours: '24h', estimatedDuration: 0.5, phone: '', address: 'Kaleiçi, Antalya', entranceFee: 0.0, bestTime: 'Soir (photo)', tags: ['Romain', 'Monument', 'Photo'], city: 'Antalya'),
  ];

  final List<String> _categories = [
    'all', 'historical', 'religious', 'nature', 'beach', 'museum', 'shopping', 'palace', 'landmark', 'village', 'port', 'old_town',
  ];

  @override
  void initState() {
    super.initState();
    _initializeTileLayer();
    _mapController = MapController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeTileLayer() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      const store = FMTCStore(_storeName);
      if (!await store.manage.ready) {
        await store.manage.create();
      }
      _tileProvider = store.getTileProvider();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _initError = 'Erreur: $e';
        });
      }
    }
  }

  List<MapPlace> get _filteredPlaces {
    if (_selectedCategory == 'all') return allPlaces;
    return allPlaces.where((p) => p.category == _selectedCategory).toList();
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'historical': Icons.account_balance,
      'religious': Icons.church,
      'nature': Icons.park,
      'beach': Icons.beach_access,
      'museum': Icons.museum,
      'shopping': Icons.shopping_bag,
      'palace': Icons.castle,
      'landmark': Icons.location_on,
      'village': Icons.home,
      'port': Icons.directions_boat,
      'old_town': Icons.streetview,
    };
    return icons[category] ?? Icons.place;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'historical': const Color(0xFF8D6E63),
      'religious': const Color(0xFF9C27B0),
      'nature': const Color(0xFF43A047),
      'beach': const Color(0xFF1E88E5),
      'museum': const Color(0xFFFF6D00),
      'shopping': const Color(0xFFE91E63),
      'palace': const Color(0xFFFFB300),
      'landmark': const Color(0xFF5C6BC0),
      'village': const Color(0xFF78909C),
      'port': const Color(0xFF26A69A),
      'old_town': const Color(0xFF6D4C41),
    };
    return colors[category] ?? Colors.grey;
  }

  String _getCategoryLabel(String category) {
    final labels = {
      'all': 'Tous',
      'historical': 'Histoire',
      'religious': 'Religion',
      'nature': 'Nature',
      'beach': 'Plage',
      'museum': 'Musée',
      'shopping': 'Shopping',
      'palace': 'Palais',
      'landmark': 'Monument',
      'village': 'Village',
      'port': 'Port',
      'old_town': 'Vieille ville',
    };
    return labels[category] ?? category;
  }

  List<LatLng> _getPolylinePoints(List<Place> places) {
    if (places.length < 2) return [];
    final coords = places.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final route = <LatLng>[];
    for (int i = 0; i < coords.length - 1; i++) {
      route.addAll(_generateIntermediatePoints(coords[i], coords[i + 1]));
    }
    return route;
  }

  List<LatLng> _generateIntermediatePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    final steps = 10;
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lon = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lon));
    }
    return points;
  }

  Widget _buildTripPlannerPanel(List<ItineraryItem> itineraryItems) {
    if (itineraryItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Générez un itinéraire pour voir le parcours',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    final dayItem = _selectedDayIndex < itineraryItems.length 
        ? itineraryItems[_selectedDayIndex] 
        : itineraryItems.first;
    final activities = dayItem.activities;

    final routePoints = <LatLng>[];
    double totalDuration = 0;
    double totalCost = 0;

    for (int i = 0; i < activities.length; i++) {
      final lat = _findPlaceLat(activities[i].description);
      final lon = _findPlaceLon(activities[i].description);
      if (lat != 0 && lon != 0) {
        routePoints.add(LatLng(lat, lon));
        totalDuration += 2.0;
        totalCost += 50.0;
      }
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE30A17),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jour ${_selectedDayIndex + 1}: ${dayItem.dayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activities.length} lieux',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(Icons.schedule, '${totalDuration.toStringAsFixed(0)}h'),
                _buildStatChip(Icons.monetization_on, '${totalCost.toStringAsFixed(0)} TL'),
                _buildStatChip(Icons.straighten, '${_calculateTotalDistance(routePoints).toStringAsFixed(1)} km'),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final lat = _findPlaceLat(activity.description);
                final lon = _findPlaceLon(activity.description);
                final isValid = lat != 0 && lon != 0;

                return InkWell(
                  onTap: isValid ? () {
                    _mapController?.move(LatLng(lat, lon), 15);
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: index == 0 ? const Color(0xFFE30A17).withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: index == 0 ? const Color(0xFFE30A17) : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: index == 0 
                                ? const Color(0xFFE30A17) 
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index == 0 ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (activity.time != null)
                                Text(
                                  activity.time!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                            ],
                          ),
                        ),
                        if (isValid)
                          Icon(Icons.navigation, size: 16, color: Colors.grey[400])
                        else
                          Icon(Icons.help_outline, size: 16, color: Colors.orange[300]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (itineraryItems.length > 1)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: _selectedDayIndex > 0 
                        ? () => setState(() => _selectedDayIndex--) 
                        : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(itineraryItems.length, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: i == _selectedDayIndex 
                                ? const Color(0xFFE30A17) 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'J${i + 1}',
                            style: TextStyle(
                              color: i == _selectedDayIndex ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: _selectedDayIndex < itineraryItems.length - 1 
                        ? () => setState(() => _selectedDayIndex++) 
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
      ],
    );
  }

  double _calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _haversineDistance(points[i], points[i + 1]);
    }
    return total;
  }

  double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371.0;
    final dLat = _toRad(p2.latitude - p1.latitude);
    final dLon = _toRad(p2.longitude - p1.longitude);
    final a = (1 - _cos(dLat)) / 2 + 
              _cos(p1.latitude) * _cos(p2.latitude) * (1 - _cos(dLon)) / 2;
    return 2 * R * _asin(_sqrt(a));
  }

  double _toRad(double deg) => deg * 3.14159265359 / 180;
  double _cos(double x) => x.isNaN ? 0 : _cosApprox(x);
  double _asin(double x) => x.isNaN ? 0 : _asinApprox(x);
  double _sqrt(double x) => x.isNaN ? 0 : _sqrtApprox(x);
  
  double _cosApprox(double x) {
    x = x % (2 * 3.14159265359);
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _asinApprox(double x) {
    if (x >= 1) return 3.14159265359 / 2;
    if (x <= -1) return -3.14159265359 / 2;
    return x + (x * x * x) / 6;
  }

  double _sqrtApprox(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  @override
  Widget build(BuildContext context) {
    final itineraryService = context.watch<ItineraryService>();
    final itineraryItems = itineraryService.getCachedItinerary();
    final categoryColor = _getCategoryColor(_selectedCategory);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  _getCategoryLabel(cat),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedCategory = cat),
                                backgroundColor: Colors.white,
                                selectedColor: categoryColor,
                                checkmarkColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${allPlaces.length} lieux',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getCategoryLabel(_selectedCategory),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(39.0, 35.0),
                    initialZoom: 6,
                    minZoom: 5,
                    maxZoom: 18,
                    onTap: (_, __) => setState(() => _selectedPlace = null),
                    onPositionChanged: (_, __) {},
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.trtravel.app',
                      tileProvider: _tileProvider,
                    ),
                    if (_showRoute && itineraryItems.isNotEmpty) ...[
                      PolylineLayer(
                        polylines: itineraryItems.asMap().entries.map((entry) {
                          final item = entry.value;
                          final dayIndex = entry.key;
                          final places = item.activities
                              .map((a) => Place(
                                    name: a.description,
                                    description: a.details ?? '',
                                    latitude: _findPlaceLat(a.description),
                                    longitude: _findPlaceLon(a.description),
                                    category: 'landmark',
                                    rating: 4.0,
                                    address: '',
                                    photos: [],
                                    openingHours: a.time,
                                  ))
                              .where((p) => p.latitude != 0 && p.longitude != 0)
                              .toList();
                          final points = _getPolylinePoints(places);
                          if (points.length < 2) return null;
                          return Polyline(
                            points: points,
                            strokeWidth: dayIndex == _selectedDayIndex ? 5 : 3,
                            color: dayIndex == _selectedDayIndex 
                                ? const Color(0xFFE30A17)
                                : const Color(0xFFE30A17).withValues(alpha: 0.3),
                          );
                        }).whereType<Polyline>().toList(),
                      ),
                      MarkerLayer(
                        markers: _getItineraryMarkers(itineraryItems),
                      ),
                    ],
                    MarkerLayer(
                      markers: _filteredPlaces.map((place) {
                        final isSelected = place == _selectedPlace;
                        return Marker(
                          point: place.location,
                          width: isSelected ? 56 : 44,
                          height: isSelected ? 56 : 44,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlace = place),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(place.category),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: isSelected ? 3 : 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_getCategoryColor(place.category)).withValues(alpha: isSelected ? 0.5 : 0.3),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCategoryIcon(place.category),
                                color: Colors.white,
                                size: isSelected ? 28 : 20,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_selectedPlace != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildPlaceInfo(),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _buildMapButton(Icons.layers, () => _showMapTypeMenu()),
                      const SizedBox(height: 8),
                      _buildMapButton(
                        _showRoute ? Icons.route : Icons.route_outlined,
                        () => setState(() => _showRoute = !_showRoute),
                      ),
                      const SizedBox(height: 8),
                      _buildMapButton(
                        _showTripPlanner ? Icons.list_alt : Icons.list_alt_outlined,
                        () => setState(() => _showTripPlanner = !_showTripPlanner),
                      ),
                    ],
                  ),
                ),
                if (_showTripPlanner && itineraryItems.isNotEmpty)
                  Positioned(
                    left: 12,
                    top: 12,
                    right: 80,
                    child: _buildTripPlannerPanel(itineraryItems),
                  ),
              ],
            ),
          ),
          _buildPlacesList(),
        ],
      ),
    );
  }

  double _findPlaceLat(String desc) {
    final lower = desc.toLowerCase();
    for (final p in allPlaces) {
      if (lower.contains(p.name.toLowerCase())) return p.location.latitude;
    }
    return 0;
  }

  double _findPlaceLon(String desc) {
    final lower = desc.toLowerCase();
    for (final p in allPlaces) {
      if (lower.contains(p.name.toLowerCase())) return p.location.longitude;
    }
    return 0;
  }

  List<Marker> _getItineraryMarkers(List<ItineraryItem> itineraryItems) {
    if (itineraryItems.isEmpty) return [];
    
    final day = _selectedDayIndex < itineraryItems.length 
        ? itineraryItems[_selectedDayIndex] 
        : itineraryItems.first;
    
    final markers = <Marker>[];
    for (int i = 0; i < day.activities.length; i++) {
      final lat = _findPlaceLat(day.activities[i].description);
      final lon = _findPlaceLon(day.activities[i].description);
      if (lat != 0 && lon != 0) {
        markers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 36,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                color: i == 0 ? const Color(0xFF43A047) : const Color(0xFFE30A17),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Widget _buildMapButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        color: const Color(0xFFE30A17),
      ),
    );
  }

  void _showMapTypeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type de carte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('OpenStreetMap'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    final place = _selectedPlace!;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(i < place.rating.floor() ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                        const SizedBox(width: 4),
                        Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryLabel(place.category),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getCategoryColor(place.category)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => setState(() => _selectedPlace = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            place.description,
            style: TextStyle(color: Colors.grey[700], height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (place.openingHours != null)
                _buildChip(Icons.access_time, place.openingHours!),
              if (place.estimatedDuration != null)
                _buildChip(Icons.schedule, '~${place.estimatedDuration!.toStringAsFixed(1)}h'),
              if (place.entranceFee != null)
                _buildChip(Icons.monetization_on, place.entranceFee! > 0 ? '${place.entranceFee!.toStringAsFixed(0)} TL' : 'Gratuit'),
              if (place.bestTime != null)
                _buildChip(Icons.wb_sunny, place.bestTime!),
              if (place.city.isNotEmpty)
                _buildChip(Icons.location_city, place.city),
            ],
          ),
          if (place.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: place.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('#$tag', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              )).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Itinéraire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30A17),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    _mapController?.move(place.location, 16);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Détails'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showPlaceDetails(place),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showPlaceDetails(MapPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(i < place.rating.floor() ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
                              const SizedBox(width: 6),
                              Text('${place.rating}/5', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryLabel(place.category).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _getCategoryColor(place.category), letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(place.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                if (place.descriptionTr.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🇹🇷 ', style: TextStyle(fontSize: 14)),
                            Text('Türkçe', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(place.descriptionTr, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Informations pratiques', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (place.address != null) _buildDetailRow(Icons.location_on, 'Adresse', place.address!),
                if (place.openingHours != null) _buildDetailRow(Icons.access_time, 'Horaires', place.openingHours!),
                if (place.estimatedDuration != null) _buildDetailRow(Icons.schedule, 'Durée estimée', '~${place.estimatedDuration!.toStringAsFixed(1)} heures'),
                if (place.entranceFee != null) _buildDetailRow(Icons.monetization_on, 'Entrée', place.entranceFee! > 0 ? '${place.entranceFee!.toStringAsFixed(0)} TL' : 'Gratuit'),
                if (place.bestTime != null) _buildDetailRow(Icons.wb_sunny, 'Meilleur moment', place.bestTime!),
                if (place.city.isNotEmpty) _buildDetailRow(Icons.location_city, 'Ville', place.city),
                if (place.phone != null && place.phone!.isNotEmpty) _buildDetailRow(Icons.phone, 'Téléphone', place.phone!),
                if (place.website != null && place.website!.isNotEmpty) _buildDetailRow(Icons.language, 'Site web', place.website!),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.pin_drop, 'Coordonnées', '${place.location.latitude.toStringAsFixed(4)}, ${place.location.longitude.toStringAsFixed(4)}'),
                if (place.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tags', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: place.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30A17).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('#$tag', style: const TextStyle(fontSize: 13, color: Color(0xFFE30A17), fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController?.move(place.location, 16);
                    },
                    icon: const Icon(Icons.navigation, size: 20),
                    label: const Text('Navigate vers ce lieu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30A17),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    return Container(
      height: 130,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = _filteredPlaces[index];
          final isSelected = place == _selectedPlace;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPlace = place);
              _mapController?.move(place.location, 14);
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? _getCategoryColor(place.category).withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _getCategoryColor(place.category) : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getCategoryIcon(place.category), size: 14, color: _getCategoryColor(place.category)),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${place.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(
                        place.openingHours ?? '24h',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}