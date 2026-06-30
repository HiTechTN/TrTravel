import 'package:latlong2/latlong.dart';
import '../models/map_place.dart';

class MapPlacesData {
  static final List<MapPlace> all = [
    // === ISTANBUL - MONUMENTS ===
    MapPlace(
      id: 'ayasofya', name: 'Sainte-Sophie (Ayasofya)', nameTr: 'Ayasofya-i Kebir', nameEn: 'Hagia Sophia',
      description: 'Chef-d\'œuvre byzantin du 6e siècle construit par l\'empereur Justinien. D\'abord cathédrale (537-1453), puis mosquée (1453-1934), musée (1935-2020), et de nouveau mosquée. Coupole de 31m de diamètre, mosaïques byzantines, marbres précieux.',
      descriptionTr: 'İmparator Justinianus tarafından 6. yüzyılda inşa edilen Bizans başyapıtı. Önce katedral (537-1453), sonra cami (1453-1934), müze (1935-2020) ve tekrar cami. 31m çapında kubbe, Bizans mozaikleri, değerli mermerler.',
      descriptionEn: '6th century Byzantine masterpiece built by Emperor Justinian. First cathedral (537-1453), then mosque (1453-1934), museum (1935-2020), and mosque again. 31m dome, Byzantine mosaics, precious marbles.',
      location: LatLng(41.0086, 28.9802), category: 'Monuments Historiques',
      rating: 4.8, reviewCount: 45230,
      address: 'Sultanahmet, Ayasofya Meydanı, Fatih/İstanbul',
      phone: '+90 212 522 1750', website: 'https://muze.gen.tr/muze-icerik/ayasofya',
      openingHours: '09:00', closingHours: '17:00', priceRange: 'Gratuit', entranceFee: 'Gratuit (mosquée)',
      bestTime: 'Matin 8h-10h (moins de monde)', estimatedMinutes: 90,
      tags: ['byzantin', 'mosquée', 'patrimoine-mondial', 'coupole', 'mosaïque', 'gratuit', 'incontournable'],
      city: 'Istanbul', district: 'Sultanahmet',
      hasWheelchair: true, isIndoor: true, allowsPhotography: true,
      dressCode: 'Épaules et genoux couverts. Femmes: voile obligatoire',
      metroStation: 'Sultanahmet (T1)', busLines: ['BN1', 'BN2'],
      wikipediaUrl: 'https://fr.wikipedia.org/wiki/Sainte-Sophie',
    ),
    MapPlace(
      id: 'mosquee-bleue', name: 'Mosquée Bleue (Sultanahmet)', nameTr: 'Sultanahmet Camii', nameEn: 'Blue Mosque',
      description: 'Mosquée ottomane du 17e siècle (1609-1616) par l\'architecte Sedefkâr Mehmed Ağa. Six minarets, plus de 20 000 céramiques bleues d\'Iznik. Intérieur spectaculaire avec hautes voûtes et vitraux.',
      descriptionTr: 'Mimar Sedefkâr Mehmed Ağa tarafından 17. yüzyılda (1609-1616) inşa edilen Osmanlı camisi. Altı minare, 20.000\'den fazla İznik mavi çinisi. Yüksek kubbeler ve vitraylarla muhteşem iç mekan.',
      descriptionEn: '17th century Ottoman mosque (1609-1616) by architect Sedefkâr Mehmed Ağa. Six minarets, over 20,000 blue Iznik tiles. Spectacular interior with high vaults and stained glass.',
      location: LatLng(41.0054, 28.9768), category: 'Mosquées',
      rating: 4.7, reviewCount: 38900,
      address: 'Sultanahmet, Atmeydanı Cd., Fatih/İstanbul',
      openingHours: '09:00', closingHours: '18:00', priceRange: 'Gratuit',
      bestTime: 'Matin avant 11h', estimatedMinutes: 60,
      tags: ['mosquée', 'ottoman', 'céramique', 'iznik', '6-minarets', 'gratuit', 'incontournable'],
      city: 'Istanbul', district: 'Sultanahmet',
      hasWheelchair: true, isIndoor: true, allowsPhotography: true,
      dressCode: 'Épaules et genoux couverts. Femmes: voile obligatoire',
      metroStation: 'Sultanahmet (T1)',
      wikipediaUrl: 'https://fr.wikipedia.org/wiki/Mosqu%C3%A9e_Bleue',
    ),
    MapPlace(
      id: 'topkapi', name: 'Palais de Topkapi', nameTr: 'Topkapı Sarayı', nameEn: 'Topkapi Palace',
      description: 'Résidence des sultans ottomans pendant 400 ans (1465-1856). 4 cours, harem de 400 pièces, trésor impérial avec le célèbre Poignard de Topkapi et le Diamant du Cuillérien (86 carats). Vue panoramique sur le Bosphore et la Corne d\'Or.',
      descriptionTr: 'Osmanlı padişahlarının 400 yıllık ikametgahı (1465-1856). 4 avlu, 400 odalı harem, ünlü Topkapı Hançeri ve Kaşıkçı Elması (86 karat) imparatorluk hazinesi. Boğaz ve Haliç\'in panoramik manzarası.',
      descriptionEn: 'Home of Ottoman sultans for 400 years (1465-1856). 4 courtyards, 400-room harem, imperial treasury with the famous Topkapi Dagger and Spoonmaker\'s Diamond (86 carats). Panoramic Bosphorus view.',
      location: LatLng(41.0115, 28.9833), category: 'Palais',
      rating: 4.6, reviewCount: 31500,
      address: 'Sultanahmet, Fatih/İstanbul',
      phone: '+90 212 512 0480', website: 'https://muze.gen.tr/muze-icerik/topkapi',
      openingHours: '09:00', closingHours: '18:00', entranceFee: '750 TL', priceRange: '750 TL',
      bestTime: 'Matin 8h-10h (files d\'attente longues)', estimatedMinutes: 180,
      tags: ['palais', 'ottoman', 'harem', 'trésor', 'diamant', 'panorama', 'incontournable'],
      city: 'Istanbul', district: 'Sultanahmet',
      hasWheelchair: true, isIndoor: true, allowsPhotography: false,
      metroStation: 'Sultanahmet (T1)', wikipediaUrl: 'https://fr.wikipedia.org/wiki/Palais_de_Topkapi',
    ),
    MapPlace(
      id: 'citerne-basilique', name: 'Citerne Basilique', nameTr: 'Yerebatan Sarnıcı', nameEn: 'Basilica Cistern',
      description: 'Citerne souterraine byzantine du 6e siècle (532) construite par Justinien. 336 colonnes de 8m de haut, capacité de 80 000 m³ d\'eau. Mystérieuses têtes de Méduse sculptées à l\'envers à la base de deux colonnes. Éclairage atmosphérique.',
      descriptionTr: 'Justinianus tarafından 6. yüzyılda (532) inşa edilen Bizans yeraltı sarnıcı. 336 sütun, 8m yükseklik, 80.000 m³ su kapasitesi. İki sütunun tabanında ters çevrilmiş Medusa başları. Atmosferik aydınlatma.',
      descriptionEn: '6th century Byzantine underground cistern (532) built by Justinian. 336 columns, 8m high, 80,000 m³ water capacity. Mysterious upside-down Medusa heads at the base of two columns. Atmospheric lighting.',
      location: LatLng(41.0084, 28.9779), category: 'Monuments Historiques',
      rating: 4.5, reviewCount: 28700,
      address: 'Sultanahmet, Yerebatan Cd., Fatih/İstanbul',
      phone: '+90 212 522 1259', website: 'https://www.yerebatan.com',
      openingHours: '09:00', closingHours: '19:00', entranceFee: '350 TL', priceRange: '350 TL',
      bestTime: 'Matin 9h-11h', estimatedMinutes: 60,
      tags: ['byzantin', 'souterrain', 'citerne', 'méduse', 'unique', 'ambiance'],
      city: 'Istanbul', district: 'Sultanahmet',
      isIndoor: true, allowsPhotography: true,
      metroStation: 'Sultanahmet (T1)', wikipediaUrl: 'https://fr.wikipedia.org/wiki/Citerne_Basilique',
    ),
    MapPlace(
      id: 'grand-bazar', name: 'Grand Bazar', nameTr: 'Kapalıçarşı', nameEn: 'Grand Bazaar',
      description: 'Plus grand marché couvert du monde (1461). 30 hectares, 61 rues, plus de 4000 boutiques. Bijoux, tapis, céramiques, cuir, épices, textiles. Négociation obligatoire ! Construit sous Mehmet II.',
      descriptionTr: 'Dünyanın en büyük kapalı çarşısı (1461). 30 hektar, 61 sokak, 4000\'den fazla dükkan. Mücevher, halı, seramik, deri, baharat, tekstil. Pazarlık şart! II. Mehmet döneminde inşa edildi.',
      descriptionEn: 'World\'s largest covered market (1461). 30 hectares, 61 streets, over 4000 shops. Jewelry, carpets, ceramics, leather, spices, textiles. Bargaining mandatory! Built under Mehmet II.',
      location: LatLng(41.0107, 28.9680), category: 'Shopping',
      rating: 4.4, reviewCount: 42100,
      address: 'Beyazıt, Fatih/İstanbul',
      phone: '+90 212 519 1248', website: 'https://www.kapalicarsi.com.tr',
      openingHours: '09:00', closingHours: '19:00', priceRange: 'Variable',
      bestTime: 'Matin 9h-11h (calme)', estimatedMinutes: 120,
      tags: ['shopping', 'bazar', 'artisanat', 'souvenirs', 'tapiss', 'bijoux', 'négociation'],
      city: 'Istanbul', district: 'Beyazıt',
      hasWheelchair: true, isIndoor: true, hasWifi: true,
      metroStation: 'Beyazıt-Kapalıçarşı (T1)',
      wikipediaUrl: 'https://fr.wikipedia.org/wiki/Grand_Bazar_d%27Istanbul',
    ),

    // === ISTANBUL - POINTS DE VUE ===
    MapPlace(
      id: 'tour-galata', name: 'Tour de Galata', nameTr: 'Galata Kulesi', nameEn: 'Galata Tower',
      description: 'Tour médiévale génoise construite en 1348. Hauteur: 66,9m. Vue panoramique à 360° sur Istanbul, le Bosphore et la Corne d\'Or. Restaurant et café au sommet. L\'un des symboles d\'Istanbul.',
      descriptionTr: '1348\'de inşa edilen Ceneviz kulesi. Yükseklik: 66,9m. İstanbul, Boğaz ve Haliç\'in 360° panoramik manzarası. Tepede restoran ve kafe. İstanbul\'un sembollerinden biri.',
      descriptionEn: 'Genoese medieval tower built in 1348. Height: 66.9m. 360° panoramic view of Istanbul, the Bosphorus and the Golden Horn. Restaurant and cafe at the top. One of Istanbul\'s symbols.',
      location: LatLng(41.0256, 28.9741), category: 'Points de Vue',
      rating: 4.5, reviewCount: 25600,
      address: 'Bereketzade, Galata Kulesi, Beyoğlu/İstanbul',
      phone: '+90 212 293 8180',
      openingHours: '08:30', closingHours: '22:00', entranceFee: '350 TL', priceRange: '350 TL',
      bestTime: 'Coucher de soleil (17h-19h)', estimatedMinutes: 60,
      tags: ['tour', 'panorama', 'coucher-soleil', 'génois', 'photo', 'incontournable'],
      city: 'Istanbul', district: 'Galata',
      isOutdoor: true, allowsPhotography: true,
      metroStation: 'Tünel (funiculaire)', busLines: ['46Ç', '47E'],
      wikipediaUrl: 'https://fr.wikipedia.org/wiki/Tour_de_Galata',
    ),
    MapPlace(
      id: 'palais-dolmabahce', name: 'Palais de Dolmabahçe', nameTr: 'Dolmabahçe Sarayı', nameEn: 'Dolmabahçe Palace',
      description: 'Palais ottoman du 19e siècle (1843-1856) au bord du Bosphore. Style baroque, rococo et néoclassique. 285 pièces, 46 halls, 6 hammams. Lustre en cristal de Bohème de 4.5 tonnes (plus grand du monde). Horloge de la tour Dolmabahçe.',
      descriptionTr: 'Boğaz kıyısında 19. yüzyıl (1843-1856) Osmanlı sarayı. Barok, rokoko ve neoklasik tarz. 285 oda, 46 salon, 6 hamam. 4.5 tonluk Bohem kristal avize (dünyanın en büyüğü). Dolmabahçe Saat Kulesi.',
      descriptionEn: '19th century Ottoman palace (1843-1856) on the Bosphorus. Baroque, rococo and neoclassical style. 285 rooms, 46 halls, 6 hammams. 4.5 ton Bohemian crystal chandelier (world\'s largest). Dolmabahçe Clock Tower.',
      location: LatLng(41.0392, 28.9992), category: 'Palais',
      rating: 4.6, reviewCount: 22300,
      address: 'Vişnezade, Dolmabahçe Cd., Beşiktaş/İstanbul',
      phone: '+90 212 236 9000', website: 'https://www.dolmabahce.gov.tr',
      openingHours: '09:00', closingHours: '16:00', entranceFee: '650 TL', priceRange: '650 TL',
      bestTime: 'Matin 9h (visite guidée recommandée)', estimatedMinutes: 120,
      tags: ['palais', 'bosphore', 'ottoman', 'luxe', 'cristal', 'baroque'],
      city: 'Istanbul', district: 'Beşiktaş',
      hasWheelchair: true, isIndoor: true, allowsPhotography: false,
      metroStation: 'Kabataş (T1)', busLines: ['22', '25E', '30D'],
      wikipediaUrl: 'https://fr.wikipedia.org/wiki/Palais_de_Dolmabah%C3%A7e',
    ),

    // === ANTALYA ===
    MapPlace(
      id: 'kaleici', name: 'Kaleiçi (Vieille Ville)', nameTr: 'Kaleiçi', nameEn: 'Kaleiçi Old Town',
      description: 'Centre historique d\'Antalya. Ruelles pavées pittoresques, maisons ottomanes en bois des 18-19e siècles, port antique (marina), tour Hidirlik (2e siècle), Porte d\'Hadrien. Boutiques d\'artisanat, restaurants, cafés. Ambiance unique.',
      descriptionTr: 'Antalya\'nın tarihi merkezi. Pitoresk arnavut kaldırımlı sokaklar, 18-19. yüzyıl Osmanlı ahşap evleri, antik liman (marina), Hıdırlık Kulesi (2. yüzyıl), Hadrian Kapısı. El sanatları dükkanları, restoranlar, kafeler. Eşsiz atmosfer.',
      descriptionEn: 'Historic center of Antalya. Picturesque cobblestone streets, 18-19th century Ottoman wooden houses, ancient harbor (marina), Hidirlik Tower (2nd century), Hadrian\'s Gate. Craft shops, restaurants, cafes. Unique atmosphere.',
      location: LatLng(36.8874, 30.7053), category: 'Monuments Historiques',
      rating: 4.6, reviewCount: 18400,
      address: 'Kaleiçi, Muratpaşa/Antalya',
      openingHours: '00:00', closingHours: '24:00', priceRange: 'Gratuit',
      bestTime: 'Fin d\'après-midi (lumière dorée)', estimatedMinutes: 150,
      tags: ['historique', 'ottoman', 'port', 'ruelles', 'artisanat', 'ambiance', 'gratuit'],
      city: 'Antalya', district: 'Kaleiçi',
      isOutdoor: true, allowsPhotography: true,
      busLines: ['LC07', 'LC08'],
    ),
    MapPlace(
      id: 'plage-konyaalti', name: 'Plage Konyaaltı', nameTr: 'Konyaaltı Plajı', nameEn: 'Konyaaltı Beach',
      description: 'Plage de galets de 7km à l\'ouest d\'Antalya. Eau cristalline turquoise, promenade de 4km, nombreux restaurants et bars de plage. Montagnes du Taurus en arrière-plan. Couchers de soleil spectaculaires.',
      descriptionTr: 'Antalya batısında 7km çakıl plajı. Kristal turkuaz su, 4km sahil yolu, çok sayıda restoran ve plaj barı. Arkasında Toros Dağları. Muhteşem gün batımları.',
      descriptionEn: '7km pebble beach west of Antalya. Crystal turquoise water, 4km promenade, many restaurants and beach bars. Taurus Mountains backdrop. Spectacular sunsets.',
      location: LatLng(36.8608, 30.6394), category: 'Plages',
      rating: 4.4, reviewCount: 15200,
      address: 'Konyaaltı, Antalya',
      priceRange: 'Gratuit', bestTime: 'Après-midi 14h-18h', estimatedMinutes: 180,
      tags: ['plage', 'baignade', 'coucher-soleil', 'galets', 'promenade', 'gratuit'],
      city: 'Antalya', district: 'Konyaaltı',
      hasParking: true, isOutdoor: true, allowsPhotography: true,
      busLines: ['KC07', 'LC08'],
    ),
    MapPlace(
      id: 'duden', name: 'Cascades de Düden', nameTr: 'Düden Şelalesi', nameEn: 'Düden Waterfalls',
      description: 'Chutes d\'eau spectaculaires à 15km d\'Antalya. Deux parties: Düden supérieur (parc paysager, piscines naturelles, restaurant) et Düden inférieur (chute de 40m se jetant directement dans la mer Méditerranée). Arc-en-ciel permanent.',
      descriptionTr: 'Antalya\'ya 15km uzaklıkta muhteşem şelaleler. İki bölüm: Yukarı Düden (peyzaj parkı, doğal havuzlar, restoran) ve Aşağı Düden (40m yükseklikten doğrudan Akdeniz\'e dökülen). Sürekli gökkuşağı.',
      descriptionEn: 'Spectacular waterfalls 15km from Antalya. Two parts: Upper Düden (landscaped park, natural pools, restaurant) and Lower Düden (40m fall falling directly into the Mediterranean). Permanent rainbow.',
      location: LatLng(36.8488, 30.7698), category: 'Parcs & Jardins',
      rating: 4.4, reviewCount: 12300,
      address: 'Düdenbaşı, Antalya',
      openingHours: '09:00', closingHours: '19:00', entranceFee: '50 TL', priceRange: '50 TL',
      bestTime: 'Matin 9h-11h ou fin d\'après-midi', estimatedMinutes: 90,
      tags: ['nature', 'cascades', 'parc', 'arc-en-ciel', 'photo', 'piscine-naturelle'],
      city: 'Antalya', district: 'Düden',
      hasParking: true, isOutdoor: true, allowsPhotography: true,
    ),

    // === RESTAURANTS ===
    MapPlace(
      id: 'ciya-sofrasi', name: 'Çiya Sofrası', nameTr: 'Çiya Sofrası', nameEn: 'Çiya Sofrası',
      description: 'Restaurant renommé de cuisine anatolienne traditionnelle. Plus de 30种类的 mezes et plats régionaux de toute l\'Anatolie. Recommandé par le chef Anthony Bourdain. Dans le quartier animé de Kadıköy.',
      descriptionTr: 'Geleneksel Anadolu mutfağının ünlü restoranı. Tüm Anadolu\'dan 30\'dan fazla çeşit meze ve yöresel yemek. Şef Anthony Bourdain tarafından önerilmiş. Hareketli Kadıköy semtinde.',
      descriptionEn: 'Famous restaurant of traditional Anatolian cuisine. Over 30 kinds of mezes and regional dishes from all over Anatolia. Recommended by chef Anthony Bourdain. In lively Kadıköy district.',
      location: LatLng(40.9908, 29.0250), category: 'Restaurants',
      rating: 4.5, reviewCount: 8900,
      address: 'Caferağa Mah., Güneşli Bahçe Sk., Kadıköy/İstanbul',
      phone: '+90 216 418 5115', website: 'https://www.ciya.com.tr',
      priceRange: '300-600 TL/pers', cuisine: 'Anatolienne, Turque',
      averagePrice: 400,
      bestTime: 'Déjeuner 12h-14h ou dîner 19h-21h', estimatedMinutes: 90,
      tags: ['restaurant', 'anatolien', 'meze', 'bourdain', 'traditionnel', 'kadıköy'],
      city: 'Istanbul', district: 'Kadıköy',
      isIndoor: true, allowsPhotography: true,
      metroStation: 'Kadıköy (M4)', busLines: ['10', '17'],
    ),
    MapPlace(
      id: '7mehmet', name: '7 Mehmet', nameTr: '7 Mehmet', nameEn: '7 Mehmet',
      description: 'Restaurant gastronomique turc moderne avec vue panoramique sur Antalya. Cuisine raffinée, service excellent, cadre élégant. Spécialités: mezès créatives, poisson frais, desserts artisanaux.',
      descriptionTr: 'Antalya manzaralı modern Türk gastronomi restoranı. Rafine mutfak, mükemmel hizmet, şık ortam. Uzmanlıklar: yaratıcı mezeler, taze balık, el yapımı tatlılar.',
      descriptionEn: 'Modern Turkish gastronomic restaurant with panoramic view of Antalya. Refined cuisine, excellent service, elegant setting. Specialties: creative mezes, fresh fish, artisanal desserts.',
      location: LatLng(36.8860, 30.7030), category: 'Restaurants',
      rating: 4.6, reviewCount: 5600,
      address: 'Kaleiçi, Antalya',
      phone: '+90 242 247 6070', website: 'https://www.7mehmet.com.tr',
      priceRange: '400-800 TL/pers', cuisine: 'Turque Moderne, Méditerranéenne',
      averagePrice: 550,
      bestTime: 'Dîner (coucher de soleil)', estimatedMinutes: 120,
      tags: ['restaurant', 'gastronomique', 'panorama', 'poisson', 'meze'],
      city: 'Antalya', district: 'Kaleiçi',
      isIndoor: true, isOutdoor: true, allowsPhotography: true,
    ),

    // === TRANSPORTS ===
    MapPlace(
      id: 'aeroport-ist', name: 'Aéroport d\'Istanbul (IST)', nameTr: 'İstanbul Havalimanı (IST)', nameEn: 'Istanbul Airport (IST)',
      description: 'Plus grand aéroport d\'Europe (2019). Capacité: 90M passagers/an. Relié au centre par métro M11 (35 min) et bus Havaist (60-90 min). Terminaux: principal (vols internationaux + domestiques). Duty-free géant.',
      descriptionTr: 'Avrupa\'nın en büyük havalimanı (2019). Kapasite: yılda 90M yolcu. M11 metrosu (35 dk) ve Havaist otobüsü (60-90 dk) ile merkeze bağlantı. Terminaller: ana (uluslararası + yurt içi). Dev duty-free.',
      descriptionEn: 'Europe\'s largest airport (2019). Capacity: 90M passengers/year. Connected to center by M11 metro (35 min) and Havaist bus (60-90 min). Terminals: main (international + domestic). Giant duty-free.',
      location: LatLng(41.2753, 28.7519), category: 'Transports',
      rating: 4.2, reviewCount: 45100,
      address: 'Tayakadın, Arnavutköy/İstanbul',
      phone: '+90 444 1 442', website: 'https://www.istanbulhavalimani.com',
      priceRange: 'Navette: 150 TL, Taxi: 800-1200 TL', estimatedMinutes: 60,
      tags: ['aéroport', 'arrivée', 'départ', 'international', 'métro'],
      city: 'Istanbul', district: 'Arnavutköy',
      hasParking: true, hasWheelchair: true, hasWifi: true, isIndoor: true,
      metroStation: 'İstanbul Havalimanı (M11)', busLines: ['Havaist', 'İETT'],
    ),
    MapPlace(
      id: 'aeroport-ayt', name: 'Aéroport d\'Antalya (AYT)', nameTr: 'Antalya Havalimanı (AYT)', nameEn: 'Antalya Airport (AYT)',
      description: 'Aéroport international à 13km du centre. 2 terminaux: international et domestique. Navettes Havaş, tramway (T1), taxis. Destination très fréquentée en été.',
      descriptionTr: 'Merkeze 13km uzaklıkta uluslararası havalimanı. 2 terminal: uluslararası ve yurt içi. Havaş servisleri, tramvay (T1), taksiler. Yaz aylarında çok yoğun.',
      descriptionEn: 'International airport 13km from center. 2 terminals: international and domestic. Havaş shuttles, tram (T1), taxis. Very busy in summer.',
      location: LatLng(36.9034, 30.7957), category: 'Transports',
      rating: 4.0, reviewCount: 23400,
      address: 'Antalya',
      phone: '+90 242 330 3600', website: 'https://www.aytport.com',
      priceRange: 'Havaş: 50 TL, Taxi: 200-300 TL', estimatedMinutes: 30,
      tags: ['aéroport', 'arrivée', 'départ', 'international'],
      city: 'Antalya', district: 'Aksu',
      hasParking: true, hasWheelchair: true, hasWifi: true, isIndoor: true,
    ),
  ];

  static List<MapPlace> filter({String? city, String? category, String? query}) {
    var results = all;
    if (city != null && city != 'all') {
      results = results.where((p) => p.city.toLowerCase() == city.toLowerCase()).toList();
    }
    if (category != null && category != 'Tout') {
      results = results.where((p) => p.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.nameEn.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.tags.any((t) => t.toLowerCase().contains(q)) ||
        p.district.toLowerCase().contains(q)
      ).toList();
    }
    return results;
  }

  static MapPlace? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
