import 'package:flutter/material.dart';
import '../models/wiki_models.dart';

class WikiDatabase {
  static List<WikiCategory> get categories => [
    _historyCulture,
    _gastronomy,
    _places,
    _activities,
    _tips,
    _transport,
    _shopping,
  ];

  static final _historyCulture = WikiCategory(
    id: 'history',
    name: {'fr': 'Histoire & Culture', 'en': 'History & Culture', 'tr': 'Tarih ve Kültür'},
    icon: Icons.account_balance_rounded,
    items: [
      WikiItem(
        id: 'ayasofya',
        city: 'istanbul',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Sainte-Sophie (Ayasofya)', 'en': 'Hagia Sophia', 'tr': 'Ayasofya-i Kebir'},
        description: {'fr': 'Chef-d\'œuvre de l\'architecture byzantine, construite en 537. Musée puis mosquée, symbole d\'Istanbul.', 'en': 'Masterpiece of Byzantine architecture built in 537. Museum then mosque, symbol of Istanbul.', 'tr': '537\'de inşa edilen Bizans mimarisinin başyapıtı. Müze ve cami, İstanbul\'un sembolü.'},
        tags: ['monument', 'histoire', 'byzantin', 'mosquée'],
        price: 'Gratuit (mosquée)',
        hours: 'Lun-Dim 9h-17h',
        address: 'Sultanahmet, Fatih/İstanbul',
        phone: '+90 212 522 1750',
        website: 'https://muze.gen.tr/muze-icerik/ayasofya',
        sections: [
          WikiSection(id: 'ayasofya-histoire', title: {'fr': 'Histoire', 'en': 'History', 'tr': 'Tarih'}, content: {'fr': 'Construite par l\'empereur Justinien entre 532 et 537, Sainte-Sophie fut la plus grande cathédrale du monde pendant près de mille ans. Transformée en mosquée en 1453 après la conquête ottomane, puis en musée en 1935, elle est redevenue mosquée en 2020.', 'en': 'Built by Emperor Justinian between 532 and 537, Hagia Sophia was the largest cathedral in the world for nearly a thousand years. Converted to a mosque in 1453 after the Ottoman conquest, then to a museum in 1935, it became a mosque again in 2020.', 'tr': 'İmparator Justinianus tarafından 532-537 yılları arasında inşa edilen Ayasofya, yaklaşık bin yıl boyunca dünyanın en büyük katedraliydi. 1453\'te Osmanlı fethinden sonra camiye, 1935\'te müzeye dönüştürülen yapı, 2020\'de tekrar cami oldu.'}),
          WikiSection(id: 'ayasofya-conseils', title: {'fr': 'Conseils de visite', 'en': 'Visit Tips', 'tr': 'Ziyaret İpuçları'}, content: {'fr': 'Arrivez tôt le matin pour éviter la foule. Entrée gratuite car lieu de culte. Couvrez-vous les épaules et les genoux. Les femmes doivent se couvrir la tête.', 'en': 'Arrive early morning to avoid crowds. Free entry as it is a place of worship. Cover your shoulders and knees. Women must cover their heads.', 'tr': 'Kalabalıktan kaçınmak için sabah erken gidin. İbadet yeri olduğu için giriş ücretsiz. Omuzlarınızı ve dizlerinizi örtün. Kadınlar başlarını örtmeli.'}),
        ],
      ),
      WikiItem(
        id: 'mosque-bleue',
        city: 'istanbul',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Mosquée Bleue (Sultanahmet)', 'en': 'Blue Mosque (Sultanahmet)', 'tr': 'Sultanahmet Camii'},
        description: {'fr': 'Mosquée historique aux six minarets, célèbre pour ses intérieurs en céramique bleue d\'Iznik.', 'en': 'Historic mosque with six minarets, famous for its blue Iznik ceramic interiors.', 'tr': 'Altı minareli tarihi cami, mavi İznik çinileriyle ünlüdür.'},
        tags: ['mosquée', 'ottoman', 'sultanahmet'],
        price: 'Gratuit',
        hours: 'Lun-Dim 9h-18h (fermé pendant les prières)',
        address: 'Sultanahmet, Fatih/İstanbul',
        phone: '+90 212 518 0505',
        website: 'https://sultanahmetcami.org',
      ),
      WikiItem(
        id: 'palais-topkapi',
        city: 'istanbul',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Palais de Topkapi', 'en': 'Topkapi Palace', 'tr': 'Topkapı Sarayı'},
        description: {'fr': 'Résidence des sultans ottomans pendant 400 ans. Trésor impérial, harem, et vue magnifique sur le Bosphore.', 'en': 'Residence of Ottoman sultans for 400 years. Imperial treasury, harem, and magnificent view of the Bosphorus.', 'tr': '400 yıl boyunca Osmanlı padişahlarının ikametgahı. İmparatorluk hazinesi, harem ve Boğaz\'ın muhteşem manzarası.'},
        tags: ['palais', 'ottoman', 'harem', 'trésor'],
        price: '750 TL',
        hours: 'Mer-Lun 9h-18h (fermé mardi)',
        address: 'Sultanahmet, Fatih/İstanbul',
        phone: '+90 212 512 0480',
        website: 'https://muze.gen.tr/muze-icerik/topkapi',
        bookingUrl: 'https://bilet.muze.gov.tr',
      ),
      WikiItem(
        id: 'cistern-basilique',
        city: 'istanbul',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Citerne Basilique', 'en': 'Basilica Cistern', 'tr': 'Yerebatan Sarnıcı'},
        description: {'fr': 'Citerne souterraine byzantine du VIe siècle, avec 336 colonnes et une mystérieuse tête de Méduse.', 'en': 'Byzantine underground cistern from the 6th century, with 336 columns and a mysterious Medusa head.', 'tr': '6. yüzyıldan kalma Bizans yeraltı sarnıcı, 336 sütun ve gizemli Medusa başı ile.'},
        tags: ['byzantin', 'souterrain', 'citerne'],
        price: '350 TL',
        hours: 'Lun-Dim 9h-19h',
        address: 'Sultanahmet, Fatih/İstanbul',
        phone: '+90 212 522 1259',
        website: 'https://www.yerebatan.com',
        bookingUrl: 'https://bilet.muze.gov.tr',
      ),
      WikiItem(
        id: 'kaleici',
        city: 'antalya',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Kaleiçi (Vieille Ville)', 'en': 'Kaleiçi (Old Town)', 'tr': 'Kaleiçi'},
        description: {'fr': 'Centre historique d\'Antalya avec ruelles pavées, maisons ottomanes, port antique et tour Hidirlik.', 'en': 'Historic center of Antalya with cobblestone streets, Ottoman houses, ancient harbor and Hidirlik Tower.', 'tr': 'Antalya\'nın arnavut kaldırımlı sokakları, Osmanlı evleri, antik liman ve Hıdırlık Kulesi ile tarihi merkezi.'},
        tags: ['historique', 'ottoman', 'port', 'ruelles'],
        price: 'Gratuit',
        hours: 'Accès libre',
        address: 'Kaleiçi, Muratpaşa/Antalya',
      ),
      WikiItem(
        id: 'hadrien-antalya',
        city: 'antalya',
        category: 'history',
        icon: Icons.account_balance_rounded,
        title: {'fr': 'Porte d\'Hadrien', 'en': 'Hadrian\'s Gate', 'tr': 'Hadrian Kapısı'},
        description: {'fr': 'Arc de triomphe romain construit en 130 après J.-C. pour l\'empereur Hadrien. Magnifiquement préservé à l\'entrée de Kaleiçi.', 'en': 'Roman triumphal arch built in 130 AD for Emperor Hadrian. Beautifully preserved at the entrance to Kaleiçi.', 'tr': 'İmparator Hadrianus için MS 130\'da inşa edilen Roma zafer takı. Kaleiçi girişinde güzelce korunmuştur.'},
        tags: ['romain', 'arc', 'empereur'],
        price: 'Gratuit',
        address: 'Kaleiçi, Muratpaşa/Antalya',
      ),
    ],
  );

  static final _gastronomy = WikiCategory(
    id: 'food',
    name: {'fr': 'Gastronomie', 'en': 'Food & Drinks', 'tr': 'Yemek ve İçecek'},
    icon: Icons.restaurant_rounded,
    items: [
      WikiItem(
        id: 'cuisine-turque',
        city: 'general',
        category: 'food',
        icon: Icons.restaurant_rounded,
        title: {'fr': 'Cuisine Turque', 'en': 'Turkish Cuisine', 'tr': 'Türk Mutfağı'},
        description: {'fr': 'Découvrez les saveurs de la Turquie : kebabs, mezes, baklava, et le célèbre thé turc.', 'en': 'Discover the flavors of Turkey: kebabs, mezes, baklava, and the famous Turkish tea.', 'tr': 'Türkiye\'nin lezzetlerini keşfedin: kebap, meze, baklava ve ünlü Türk çayı.'},
        tags: ['cuisine', 'kebab', 'meze', 'baklava'],
        price: 'Budget: 100-300 TL/pers',
        sections: [
          WikiSection(id: 'cuisine-plats', title: {'fr': 'Plats typiques', 'en': 'Typical dishes', 'tr': 'Tipik yemekler'}, content: {'fr': 'Köfte (boulettes), Döner, Lahmacun (pizza turque), Pide (pain garni), Mantı (raviolis turcs), İskender kebap, Meze (entrées froides).', 'en': 'Köfte (meatballs), Döner, Lahmacun (Turkish pizza), Pide (filled bread), Mantı (Turkish ravioli), İskender kebab, Meze (cold appetizers).', 'tr': 'Köfte, Döner, Lahmacun, Pide, Mantı, İskender kebap, Meze.'}),
          WikiSection(id: 'cuisine-desserts', title: {'fr': 'Desserts', 'en': 'Desserts', 'tr': 'Tatlılar'}, content: {'fr': 'Baklava (pistache/noix), Künefe (fromage filé), Dondurma (glace turque), Sütlaç (riz au lait), Lokum (delices turcs).', 'en': 'Baklava (pistachio/walnut), Künefe (shredded cheese), Dondurma (Turkish ice cream), Sütlaç (rice pudding), Lokum (Turkish delight).', 'tr': 'Baklava (antep fıstıklı/cevizli), Künefe, Dondurma, Sütlaç, Lokum.'}),
          WikiSection(id: 'cuisine-boissons', title: {'fr': 'Boissons', 'en': 'Drinks', 'tr': 'İçecekler'}, content: {'fr': 'Çay (thé turc, omniprésent), Kahve (café turc), Ayran (yaourt salé), Şalgam (jus de navet), Rakı (boisson anisée), Efes (bière locale).', 'en': 'Çay (Turkish tea, everywhere), Kahve (Turkish coffee), Ayran (salted yogurt), Şalgam (turnip juice), Rakı (anise drink), Efes (local beer).', 'tr': 'Çay, Kahve, Ayran, Şalgam, Rakı, Efes.'}),
        ],
      ),
      WikiItem(
        id: 'petit-dej-turc',
        city: 'general',
        category: 'food',
        icon: Icons.free_breakfast_rounded,
        title: {'fr': 'Petit-déjeuner Turc', 'en': 'Turkish Breakfast', 'tr': 'Türk Kahvaltısı'},
        description: {'fr': 'Un festin matinal avec fromages, olives, miel, confitures, œufs, menemen, simit et thé à volonté.', 'en': 'A morning feast with cheeses, olives, honey, jams, eggs, menemen, simit and unlimited tea.', 'tr': 'Peynirler, zeytinler, bal, reçeller, yumurta, menemen, simit ve sınırsız çay ile bir şölen.'},
        tags: ['petit-déjeuner', 'tradition', 'thé'],
        price: '150-300 TL/pers',
      ),
      WikiItem(
        id: 'istanbul-food',
        city: 'istanbul',
        category: 'food',
        icon: Icons.restaurant_rounded,
        title: {'fr': 'Où manger à Istanbul', 'en': 'Where to eat in Istanbul', 'tr': 'İstanbul\'da nerede yenir'},
        description: {'fr': 'Les meilleurs restaurants d\'Istanbul du street food aux établissements étoilés.', 'en': 'Best restaurants in Istanbul from street food to Michelin-starred.', 'tr': 'Sokak yemeklerinden Michelin yıldızlı restoranlara İstanbul\'un en iyi restoranları.'},
        tags: ['restaurant', 'street food', 'istanbul'],
        price: 'Street food: 50 TL, Restaurant: 200-800 TL',
        sections: [
          WikiSection(id: 'istanbul-streetfood', title: {'fr': 'Street Food', 'en': 'Street Food', 'tr': 'Sokak Yemekleri'}, content: {'fr': 'Balık ekmek (sandwich poisson) au pont de Galata, Kumpir (patate farcie) à Ortaköy, Midye dolma (moules farcies), Simit (pain au sésame), Kestane (marrons grillés) en hiver.', 'en': 'Balık ekmek (fish sandwich) at Galata Bridge, Kumpir (stuffed potato) at Ortaköy, Midye dolma (stuffed mussels), Simit (sesame bread), Kestane (roasted chestnuts) in winter.', 'tr': 'Galata Köprüsü\'nde balık ekmek, Ortaköy\'de kumpir, midye dolma, simit, kışın kestane.'}),
          WikiSection(id: 'istanbul-restos', title: {'fr': 'Restaurants conseillés', 'en': 'Recommended restaurants', 'tr': 'Tavsiye edilen restoranlar'}, content: {'fr': 'Karaköy Güllüoğlu (baklava), Çiya Sofrası (cuisine anatolienne), Nusr-Et (steakhouse), Mikla (gastronomique, vue panoramique), Pandeli (cuisine ottomane).', 'en': 'Karaköy Güllüoğlu (baklava), Çiya Sofrası (Anatolian cuisine), Nusr-Et (steakhouse), Mikla (gastronomic, panoramic view), Pandeli (Ottoman cuisine).', 'tr': 'Karaköy Güllüoğlu (baklava), Çiya Sofrası (Anadolu mutfağı), Nusr-Et (steakhouse), Mikla (panoramik manzaralı), Pandeli (Osmanlı mutfağı).'}),
        ],
      ),
    ],
  );

  static final _places = WikiCategory(
    id: 'places',
    name: {'fr': 'Lieux à visiter', 'en': 'Places to visit', 'tr': 'Gezilecek Yerler'},
    icon: Icons.map_rounded,
    items: [
      WikiItem(
        id: 'bosphore',
        city: 'istanbul',
        category: 'places',
        icon: Icons.directions_boat_rounded,
        title: {'fr': 'Croisière sur le Bosphore', 'en': 'Bosphorus Cruise', 'tr': 'Boğaz Turu'},
        description: {'fr': 'Balade en bateau entre l\'Europe et l\'Asie. Vue imprenable sur les palais, mosquées et ponts.', 'en': 'Boat ride between Europe and Asia. Stunning views of palaces, mosques and bridges.', 'tr': 'Avrupa ve Asya arasında tekne turu. Saraylar, camiler ve köprülerin muhteşem manzarası.'},
        tags: ['bosphore', 'croisière', 'bateau'],
        price: 'Public ferry: 50 TL, Privé: 300-1000 TL',
        hours: 'Tous les jours, départs réguliers d\'Eminönü',
      ),
      WikiItem(
        id: 'grand-bazar',
        city: 'istanbul',
        category: 'places',
        icon: Icons.store_rounded,
        title: {'fr': 'Grand Bazar', 'en': 'Grand Bazaar', 'tr': 'Kapalıçarşı'},
        description: {'fr': 'L\'un des plus grands marchés couverts du monde avec plus de 4000 boutiques. Bijoux, tapis, épices, céramiques.', 'en': 'One of the largest covered markets in the world with over 4000 shops. Jewelry, carpets, spices, ceramics.', 'tr': 'Dünyanın en büyük kapalı çarşılarından biri, 4000\'den fazla dükkan. Mücevher, halı, baharat, seramik.'},
        tags: ['shopping', 'bazar', 'artisanat'],
        price: 'Gratuit (entrée), variable (achats)',
        hours: 'Lun-Sam 9h-19h (fermé dimanche)',
        address: 'Beyazıt, Fatih/İstanbul',
      ),
      WikiItem(
        id: 'dolmabahce',
        city: 'istanbul',
        category: 'places',
        icon: Icons.map_rounded,
        title: {'fr': 'Palais de Dolmabahçe', 'en': 'Dolmabahçe Palace', 'tr': 'Dolmabahçe Sarayı'},
        description: {'fr': 'Palais ottoman du XIXe siècle mêlant styles baroque, rococo et néoclassique. Lustre en cristal de 4.5 tonnes.', 'en': '19th century Ottoman palace blending baroque, rococo and neoclassical styles. 4.5 ton crystal chandelier.', 'tr': 'Barok, rokoko ve neoklasik stilleri harmanlayan 19. yüzyıl Osmanlı sarayı. 4.5 tonluk kristal avize.'},
        tags: ['palais', 'ottoman', 'bosphore'],
        price: '650 TL',
        hours: 'Mar-Dim 9h-16h (fermé lun/jeu)',
        address: 'Vişnezade, Beşiktaş/İstanbul',
      ),
      WikiItem(
        id: 'cappadoce',
        city: 'general',
        category: 'places',
        icon: Icons.map_rounded,
        title: {'fr': 'Cappadoce', 'en': 'Cappadocia', 'tr': 'Kapadokya'},
        description: {'fr': 'Région unique aux cheminées de fées, villes souterraines et vol en montgolfière au lever du soleil.', 'en': 'Unique region with fairy chimneys, underground cities and hot air balloon ride at sunrise.', 'tr': 'Peri bacaları, yeraltı şehirleri ve gün doğumunda sıcak hava balonu ile eşsiz bölge.'},
        tags: ['nature', 'montgolfière', 'grottes'],
        price: 'Ballon: 2000-5000 TL',
      ),
      WikiItem(
        id: 'duden-antalya',
        city: 'antalya',
        category: 'places',
        icon: Icons.waterfall_chart_rounded,
        title: {'fr': 'Cascades de Düden', 'en': 'Düden Waterfalls', 'tr': 'Düden Şelalesi'},
        description: {'fr': 'Magnifiques chutes d\'eau à 15km d\'Antalya. Deux parties : chutes supérieures (parc) et chutes inférieures (mer).', 'en': 'Beautiful waterfalls 15km from Antalya. Two parts: upper falls (park) and lower falls (sea).', 'tr': 'Antalya\'ya 15km uzaklıkta muhteşem şelaleler. İki bölüm: üst şelale (park) ve alt şelale (deniz).'},
        tags: ['nature', 'cascades', 'parc'],
        price: '50 TL',
        hours: 'Lun-Dim 9h-19h',
      ),
      WikiItem(
        id: 'olympos-antalya',
        city: 'antalya',
        category: 'places',
        icon: Icons.map_rounded,
        title: {'fr': 'Olympos & Çıralı', 'en': 'Olympos & Çıralı', 'tr': 'Olympos ve Çıralı'},
        description: {'fr': 'Ville antique lycienne face à la mer, avec plage de Çıralı et le mont Olympe (Yanartaş) en feu éternel.', 'en': 'Ancient Lycian city by the sea, with Çıralı beach and Mount Olympos (Yanartaş) with eternal flames.', 'tr': 'Deniz kenarında antik Likya kenti, Çıralı plajı ve ebedi alevlerle Olimpos Dağı (Yanartaş).'},
        tags: ['antique', 'plage', 'lycien', 'flammes'],
        price: '400 TL (site antique)',
      ),
    ],
  );

  static final _activities = WikiCategory(
    id: 'activities',
    name: {'fr': 'Activités', 'en': 'Activities', 'tr': 'Aktiviteler'},
    icon: Icons.sports_esports_rounded,
    items: [
      WikiItem(
        id: 'hammam',
        city: 'general',
        category: 'activities',
        icon: Icons.spa_rounded,
        title: {'fr': 'Hammam Turc', 'en': 'Turkish Bath', 'tr': 'Türk Hamamı'},
        description: {'fr': 'Expérience incontournable : bain vapeur, gommage (kese), mousse de savon et massage.', 'en': 'Must-do experience: steam bath, scrub (kese), soap foam and massage.', 'tr': 'Kaçırılmaması gereken deneyim: buhar banyosu, kese, sabun köpüğü ve masaj.'},
        tags: ['détente', 'bain', 'massage'],
        price: '500-1500 TL selon le service',
        sections: [
          WikiSection(id: 'hammam-istanbul', title: {'fr': 'Meilleurs hammams à Istanbul', 'en': 'Best hammams in Istanbul', 'tr': 'İstanbul\'un en iyi hamamları'}, content: {'fr': 'Çemberlitaş Hamamı (1584), Cağaloğlu Hamamı (1741), Süleymaniye Hamamı (1557), Kılıç Ali Paşa Hamamı (1580).', 'en': 'Çemberlitaş Hamamı (1584), Cağaloğlu Hamamı (1741), Süleymaniye Hamamı (1557), Kılıç Ali Paşa Hamamı (1580).', 'tr': 'Çemberlitaş Hamamı (1584), Cağaloğlu Hamamı (1741), Süleymaniye Hamamı (1557), Kılıç Ali Paşa Hamamı (1580).'}),
        ],
      ),
      WikiItem(
        id: 'montgolfiere',
        city: 'general',
        category: 'activities',
        icon: Icons.flight_rounded,
        title: {'fr': 'Montgolfière en Cappadoce', 'en': 'Hot Air Balloon in Cappadocia', 'tr': 'Kapadokya\'da Balon Turu'},
        description: {'fr': 'Survolez les cheminées de fées au lever du soleil. Expérience magique et inoubliable.', 'en': 'Fly over fairy chimneys at sunrise. Magical and unforgettable experience.', 'tr': 'Gün doğumunda peri bacalarının üzerinde uçun. Büyülü ve unutulmaz bir deneyim.'},
        tags: ['ballon', 'cappadoce', 'vol'],
        price: '2000-5000 TL/pers',
        hours: 'Départ avant le lever du soleil',
      ),
      WikiItem(
        id: 'plages-antalya',
        city: 'antalya',
        category: 'activities',
        icon: Icons.beach_access_rounded,
        title: {'fr': 'Plages d\'Antalya', 'en': 'Antalya Beaches', 'tr': 'Antalya Plajları'},
        description: {'fr': 'Les plus belles plages : Konyaaltı (galets), Lara (sable fin), Kaputaş (crique), Patara (12km de sable), Olympos (naturiste).', 'en': 'Most beautiful beaches: Konyaaltı (pebbles), Lara (fine sand), Kaputaş (cove), Patara (12km sand), Olympos (naturist).', 'tr': 'En güzel plajlar: Konyaaltı (çakıl), Lara (ince kum), Kaputaş (koy), Patara (12km kum), Olympos (nudist).'},
        tags: ['plage', 'baignade', 'mer'],
        price: 'Gratuit (plages publiques), 50-200 TL (privées)',
      ),
      WikiItem(
        id: 'parapente',
        city: 'antalya',
        category: 'activities',
        icon: Icons.flight_takeoff_rounded,
        title: {'fr': 'Parapente à Ölüdeniz', 'en': 'Paragliding in Ölüdeniz', 'tr': 'Ölüdeniz\'de Yamaç Paraşütü'},
        description: {'fr': 'L\'un des meilleurs spots du monde pour le parapente. Vue spectaculaire sur la lagune bleue.', 'en': 'One of the best paragliding spots in the world. Spectacular view of the blue lagoon.', 'tr': 'Dünyanın en iyi yamaç paraşütü noktalarından biri. Mavi lagünün muhteşem manzarası.'},
        tags: ['parapente', 'sport', 'vol'],
        price: '2000-4000 TL',
      ),
    ],
  );

  static final _tips = WikiCategory(
    id: 'tips',
    name: {'fr': 'Conseils pratiques', 'en': 'Practical Tips', 'tr': 'Pratik İpuçları'},
    icon: Icons.lightbulb_rounded,
    items: [
      WikiItem(
        id: 'argent',
        city: 'general',
        category: 'tips',
        icon: Icons.monetization_on_rounded,
        title: {'fr': 'Argent & Budget', 'en': 'Money & Budget', 'tr': 'Para ve Bütçe'},
        description: {'fr': 'La monnaie est la Lire Turque (TRY). Retraits aux DAB, cartes acceptées dans les villes. Prévoyez du liquide pour les petits commerces.', 'en': 'Currency is Turkish Lira (TRY). ATM withdrawals, cards accepted in cities. Bring cash for small shops.', 'tr': 'Para birimi Türk Lirası (TRY). ATM\'lerden çekim, şehirlerde kart kabul edilir. Küçük dükkanlar için nakit bulundurun.'},
        tags: ['argent', 'budget', 'carte'],
        price: 'Budget journalier: 1500-3000 TL/pers',
      ),
      WikiItem(
        id: 'transport-istanbul',
        city: 'istanbul',
        category: 'tips',
        icon: Icons.directions_bus_rounded,
        title: {'fr': 'Transport à Istanbul', 'en': 'Transport in Istanbul', 'tr': 'İstanbul\'da Ulaşım'},
        description: {'fr': 'Métro, tramway, bus, ferry, et funiculaire. Achetez la carte Istanbulkart pour tous les transports.', 'en': 'Metro, tram, bus, ferry, and funicular. Buy the Istanbulkart card for all transport.', 'tr': 'Metro, tramvay, otobüs, feribot ve füniküler. Tüm ulaşım için İstanbulkart alın.'},
        tags: ['transport', 'metro', 'bus', 'ferry'],
        price: 'Istanbulkart: 130 TL, Trajet: 15-20 TL',
      ),
      WikiItem(
        id: 'etiquette',
        city: 'general',
        category: 'tips',
        icon: Icons.people_rounded,
        title: {'fr': 'Étiquette & Coutumes', 'en': 'Etiquette & Customs', 'tr': 'Görgü Kuralları ve Adetler'},
        description: {'fr': 'Les Turcs sont très hospitaliers. Enlevez vos chaussures dans les mosquées et maisons. Habillez-vous modestement.', 'en': 'Turks are very hospitable. Remove shoes in mosques and homes. Dress modestly.', 'tr': 'Türkler çok misafirperverdir. Camilerde ve evlerde ayakkabıları çıkarın. Mütevazı giyinin.'},
        tags: ['culture', 'coutumes', 'savoir-vivre'],
      ),
      WikiItem(
        id: 'telephone',
        city: 'general',
        category: 'tips',
        icon: Icons.phone_android_rounded,
        title: {'fr': 'Téléphone & Internet', 'en': 'Phone & Internet', 'tr': 'Telefon ve İnternet'},
        description: {'fr': 'Achetez une eSIM ou carte SIM Turkcell/Vodafone/Türk Telekom à l\'aéroport. Wi-Fi gratuit dans les cafés et hôtels.', 'en': 'Buy an eSIM or SIM card Turkcell/Vodafone/Türk Telekom at the airport. Free Wi-Fi in cafes and hotels.', 'tr': 'Havalimanında Turkcell/Vodafone/Türk Telekom eSIM veya SIM kart alın. Kafelerde ve otellerde ücretsiz Wi-Fi.'},
        tags: ['sim', 'internet', 'appel'],
        price: 'eSIM: 10-30€/semaine, Carte SIM: 500-1000 TL',
      ),
      WikiItem(
        id: 'securite',
        city: 'general',
        category: 'tips',
        icon: Icons.security_rounded,
        title: {'fr': 'Sécurité', 'en': 'Safety', 'tr': 'Güvenlik'},
        description: {'fr': 'La Turquie est sûre pour les touristes. Attention aux pickpockets dans les zones très fréquentées. Gardez une copie de vos papiers.', 'en': 'Turkey is safe for tourists. Watch for pickpockets in crowded areas. Keep a copy of your documents.', 'tr': 'Türkiye turistler için güvenlidir. Kalabalık alanlarda yankesicilere dikkat edin. Belgelerinizin bir kopyasını bulundurun.'},
        tags: ['sécurité', 'urgence', 'conseils'],
      ),
    ],
  );

  static final _transport = WikiCategory(
    id: 'transport',
    name: {'fr': 'Transport', 'en': 'Transport', 'tr': 'Ulaşım'},
    icon: Icons.directions_car_rounded,
    items: [
      WikiItem(
        id: 'aeroport-ist',
        city: 'istanbul',
        category: 'transport',
        icon: Icons.flight_rounded,
        title: {'fr': 'Aéroport d\'Istanbul (IST)', 'en': 'Istanbul Airport (IST)', 'tr': 'İstanbul Havalimanı (IST)'},
        description: {'fr': 'Le plus grand aéroport d\'Europe. Situé à 40km du centre. Havaist bus, métro (M11) et taxis disponibles.', 'en': 'Largest airport in Europe. Located 40km from center. Havaist bus, metro (M11) and taxis available.', 'tr': 'Avrupa\'nın en büyük havalimanı. Merkeze 40km uzaklıkta. Havaist otobüs, metro (M11) ve taksiler mevcut.'},
        tags: ['aéroport', 'arrivée', 'transfert'],
        price: 'Havaist bus: 150 TL, Taxi: 800-1200 TL',
      ),
      WikiItem(
        id: 'metro-istanbul',
        city: 'istanbul',
        category: 'transport',
        icon: Icons.subway_rounded,
        title: {'fr': 'Métro d\'Istanbul', 'en': 'Istanbul Metro', 'tr': 'İstanbul Metrosu'},
        description: {'fr': '11 lignes de métro reliant les principales zones. Propre, efficace et climatisé. De 6h à 0h.', 'en': '11 metro lines connecting main areas. Clean, efficient and air-conditioned. From 6am to midnight.', 'tr': 'Ana bölgeleri birbirine bağlayan 11 metro hattı. Temiz, verimli ve klimalı. Sabah 6\'dan gece yarısına.'},
        tags: ['metro', 'transport', 'souterrain'],
        price: '15-20 TL par trajet avec Istanbulkart',
      ),
      WikiItem(
        id: 'taxi',
        city: 'general',
        category: 'transport',
        icon: Icons.local_taxi_rounded,
        title: {'fr': 'Taxi', 'en': 'Taxi', 'tr': 'Taksi'},
        description: {'fr': 'Taxis jaunes, bon marché. Utilisez les applications BiTaksi ou Uber. Vérifiez que le compteur est activé.', 'en': 'Yellow taxis, cheap. Use BiTaksi or Uber apps. Make sure the meter is running.', 'tr': 'Sarı taksiler, ucuz. BiTaksi veya Uber uygulamalarını kullanın. Taksimetrenin açık olduğundan emin olun.'},
        tags: ['taxi', 'uber', 'transport'],
        price: 'Ouverture: 50 TL, 25 TL/km',
      ),
    ],
  );

  static final _shopping = WikiCategory(
    id: 'shopping',
    name: {'fr': 'Shopping', 'en': 'Shopping', 'tr': 'Alışveriş'},
    icon: Icons.shopping_bag_rounded,
    items: [
      WikiItem(
        id: 'bazar-epices',
        city: 'istanbul',
        category: 'shopping',
        icon: Icons.store_rounded,
        title: {'fr': 'Bazar aux Épices', 'en': 'Spice Bazaar', 'tr': 'Mısır Çarşısı'},
        description: {'fr': 'Marché couvert du XVIIe siècle. Épices, thés, fruits secs, loukoums et souvenirs.', 'en': '17th century covered market. Spices, teas, dried fruits, Turkish delights and souvenirs.', 'tr': '17. yüzyıldan kalma kapalı çarşı. Baharatlar, çaylar, kuru meyveler, lokumlar ve hediyelik eşyalar.'},
        tags: ['épices', 'thé', 'souvenirs'],
        price: 'Variable selon produit',
        hours: 'Lun-Dim 8h-19h',
        address: 'Eminönü, Fatih/İstanbul',
      ),
      WikiItem(
        id: 'shopping-malls',
        city: 'istanbul',
        category: 'shopping',
        icon: Icons.store_mall_directory_rounded,
        title: {'fr': 'Centres commerciaux', 'en': 'Shopping Malls', 'tr': 'Alışveriş Merkezleri'},
        description: {'fr': 'Les meilleurs centres : Istinye Park (luxe), Zorlu Center, Mall of Istanbul, Forum Istanbul, Akmerkez.', 'en': 'Best malls: Istinye Park (luxury), Zorlu Center, Mall of Istanbul, Forum Istanbul, Akmerkez.', 'tr': 'En iyi alışveriş merkezleri: İstinye Park (lüks), Zorlu Center, Mall of Istanbul, Forum İstanbul, Akmerkez.'},
        tags: ['shopping', 'centres', 'marques'],
        price: 'Variable',
      ),
    ],
  );

  static List<WikiItem> getAllItems() {
    return categories.expand((c) => c.items).toList();
  }

  static List<WikiItem> getItemsByCity(String city) {
    return getAllItems().where((i) => i.city == city || i.city == 'general').toList();
  }

  static List<WikiItem> search(String query) {
    final q = query.toLowerCase();
    return getAllItems().where((i) =>
      i.localizedTitle.toLowerCase().contains(q) ||
      i.localizedDescription.toLowerCase().contains(q) ||
      i.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  static WikiItem? getById(String id) {
    try {
      return getAllItems().firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
