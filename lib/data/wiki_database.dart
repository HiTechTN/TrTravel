class WikiSection {
  final String id;
  final String title;
  final String titleTr;
  final String titleEn;
  final String content;
  final String contentTr;
  final String contentEn;
  final String? imageUrl;
  final List<WikiSection> subsections;

  WikiSection({
    required this.id,
    required this.title,
    required this.titleTr,
    required this.titleEn,
    required this.content,
    required this.contentTr,
    required this.contentEn,
    this.imageUrl,
    this.subsections = const [],
  });

  String getLocalizedTitle(String lang) {
    if (lang == 'tr') return titleTr;
    if (lang == 'en') return titleEn;
    return title;
  }

  String getLocalizedContent(String lang) {
    if (lang == 'tr') return contentTr;
    if (lang == 'en') return contentEn;
    return content;
  }
}

class WikiLocation {
  final String id;
  final String name;
  final String nameTr;
  final String nameEn;
  final String description;
  final String descriptionTr;
  final String descriptionEn;
  final List<WikiSection> sections;
  final List<String> tags;
  final String? imageUrl;
  final List<String> relatedWikis;

  WikiLocation({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameEn,
    required this.description,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.sections,
    this.tags = const [],
    this.imageUrl,
    this.relatedWikis = const [],
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
}

class TravelWiki {
  final String id;
  final String title;
  final String titleTr;
  final String titleEn;
  final String description;
  final String descriptionTr;
  final String descriptionEn;
  final String category;
  final List<WikiLocation> locations;
  final List<WikiSection> generalSections;
  final List<String> tags;
  final String? imageUrl;
  final String city;

  TravelWiki({
    required this.id,
    required this.title,
    required this.titleTr,
    required this.titleEn,
    required this.description,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.category,
    required this.locations,
    this.generalSections = const [],
    this.tags = const [],
    this.imageUrl,
    this.city = 'Istanbul',
  });

  String getLocalizedTitle(String lang) {
    if (lang == 'tr') return titleTr;
    if (lang == 'en') return titleEn;
    return title;
  }

  String getLocalizedDesc(String lang) {
    if (lang == 'tr') return descriptionTr;
    if (lang == 'en') return descriptionEn;
    return description;
  }
}

class WikiDatabase {
  static final List<TravelWiki> allWikis = [
    TravelWiki(
      id: 'wiki_istanbul_history',
      title: 'Histoire d\'Istanbul',
      titleTr: 'İstanbul Tarihi',
      titleEn: 'History of Istanbul',
      description: 'De Byzance à Constantinople, 2600 ans d\'histoire.',
      descriptionTr: 'Bizans\'tan Konstantinopolis\'e, 2600 yıl tarih.',
      descriptionEn: 'From Byzantium to Constantinople, 2600 years of history.',
      category: 'history',
      city: 'Istanbul',
      tags: ['Byzantin', 'Ottoman', 'UNESCO'],
      generalSections: [
        WikiSection(
          id: 'intro',
          title: 'Introduction',
          titleTr: 'Giriş',
          titleEn: 'Introduction',
          content: 'Istanbul, anciennement connue sous le nom de Byzance puis Constantinople, est la plus grande ville de Turquie. Elle est la seule ville au monde située sur deux continents, l\'Europe et l\'Asie.',
          contentTr: 'Eski adıyla Bizans, sonra Konstantinopolis olan İstanbul, Türkiye\'nin en büyük şehridir. İki kıtada (Avrupa ve Asya) yer alan dünyanın tek şehridir.',
          contentEn: 'Istanbul, formerly known as Byzantium then Constantinople, is the largest city in Turkey. It is the only city in the world located on two continents, Europe and Asia.',
        ),
        WikiSection(
          id: 'byzantine',
          title: 'Période byzantine',
          titleTr: 'Bizans dönemi',
          titleEn: 'Byzantine period',
          content: 'Fondée en 667 av. J.-C., Byzance devient Constantinople en 330 après J.-C. sous l\'empereur Constantin. Sainte-Sophie, construite en 537, symbolise cette époque glorieuse.',
          contentTr: 'MÖ 667\'de kurulan Bizans, MS 330\'da İmparator Konstantin döneminde Konstantinopolis oldu. 537\'de inşa edilen Ayasofya bu görkemli dönemin sembolüdür.',
          contentEn: 'Founded in 667 BC, Byzantium became Constantinople in 330 AD under Emperor Constantine. Hagia Sophia, built in 537, symbolizes this glorious era.',
          subsections: [
            WikiSection(
              id: 'byzantine_sophia',
              title: 'Sainte-Sophie',
              titleTr: 'Ayasofya',
              titleEn: 'Hagia Sophia',
              content: 'Basilique construite en 537 par l\'empereur Justinien. Elle fut successivement cathédrale orthodoxe, mosquée, puis musée, et est maintenant redevenue mosquée.',
              contentTr: '537\'de İmparator Justinyen tarafından inşa edilen bazilika. Sırasıyla Ortodoks katedrali, cami, sonra müze oldu ve şimdi tekrar cami olarak hizmet veriyor.',
              contentEn: 'Basilica built in 537 by Emperor Justinian. It was successively an Orthodox cathedral, a mosque, then a museum, and is now a mosque again.',
            ),
            WikiSection(
              id: 'byzantine_walls',
              title: 'Les murailles de Constantinople',
              titleTr: 'Konstantinopolis Sur Duvarları',
              titleEn: 'The Walls of Constantinople',
              content: 'Les murailles thégodosiennes, construites entre 408 et 450, protégeaient la ville sur 6,5 km.',
              contentTr: '408 ile 450 yılları arasında inşa edilen Theodosian surları, şehri 6,5 km boyunca koruyordu.',
              contentEn: 'The Theodosian walls, built between 408 and 450, protected the city over 6.5 km.',
            ),
          ],
        ),
        WikiSection(
          id: 'ottoman',
          title: 'Période ottomane',
          titleTr: 'Osmanlı dönemi',
          titleEn: 'Ottoman period',
          content: 'En 1453, le sultan Mehmet II conquiert Constantinople. La ville devient la capitale de l\'Empire ottoman pendant près de 500 ans. Palais, mosquées et bains témoignent de cette époque.',
          contentTr: '1453\'te Sultan Mehmet II Konstantinopolis\'i fethetti. Şehir yaklaşık 500 yıl boyunca Osmanlı İmparatorluğu\'nun başkenti oldu. Saraylar, camiler ve hamamlar bu döneme tanıklık ediyor.',
          contentEn: 'In 1453, Sultan Mehmet II conquered Constantinople. The city became the capital of the Ottoman Empire for nearly 500 years. Palaces, mosques and baths bear witness to this era.',
          subsections: [
            WikiSection(
              id: 'ottoman_suleymaniye',
              title: 'Mosquée Süleymaniye',
              titleTr: 'Süleymaniye Camii',
              titleEn: 'Süleymaniye Mosque',
              content: 'Chef-d\'œuvre de Mimar Sinan (1550-1557), cette mosquée domine la ville de ses 4 minarets.',
              contentTr: 'Mimar Sinan\'ın şaheseri (1550-1557), 4 minaresiyle şehre hükmediyor.',
              contentEn: 'Masterpiece of Mimar Sinan (1550-1557), this mosque dominates the city with its 4 minarets.',
            ),
            WikiSection(
              id: 'ottoman_topkapi',
              title: 'Palais de Topkapi',
              titleTr: 'Topkapı Sarayı',
              titleEn: 'Topkapi Palace',
              content: 'Résidence des sultans pendant 400 ans (1465-1856), le palais abrite des trésors inestimables.',
              contentTr: '400 yıl boyunca (1465-1856) sultanların ikametgahı olan saray, paha biçilmez hazineleri barındırıyor.',
              contentEn: 'Residence of sultans for 400 years (1465-1856), the palace houses invaluable treasures.',
            ),
          ],
        ),
        WikiSection(
          id: 'modern',
          title: 'Istanbul moderne',
          titleTr: 'Modern İstanbul',
          titleEn: 'Modern Istanbul',
          content: 'Depuis 1923 et la République de Türkiye, Istanbul reste le cœur économique et culturel du pays, avec ses 16 millions d\'habitants.',
          contentTr: '1923\'teki Türkiye Cumhuriyeti\'nden bu yana İstanbul, 16 milyon sakiniyle ülkenin ekonomik ve kültürel kalbi olmaya devam ediyor.',
          contentEn: 'Since 1923 and the Republic of Türkiye, Istanbul remains the economic and cultural heart of the country, with its 16 million inhabitants.',
        ),
      ],
      locations: [],
    ),
    TravelWiki(
      id: 'wiki_istanbul_food',
      title: 'Gastronomie istanbuliote',
      titleTr: 'İstanbul Mutfağı',
      titleEn: 'Istanbul Cuisine',
      description: 'Un voyage culinaire de 2600 ans, du meyhane au kebab.',
      descriptionTr: '2600 yıllık mutfak yolculuğu.',
      descriptionEn: 'A 2600-year culinary journey.',
      category: 'food',
      city: 'Istanbul',
      tags: ['Cuisine', 'Restaurants', 'Marché'],
      generalSections: [
        WikiSection(
          id: 'intro',
          title: 'Introduction',
          titleTr: 'Giriş',
          titleEn: 'Introduction',
          content: 'La cuisine d\'Istanbul reflète son histoire: byzantine, ottomane et moderne. Des meyhanes aux kebabs, en passant par les marchés d\'épices, Istanbul est un paradis gastronomique.',
          contentTr: 'İstanbul mutfağı tarihini yansıtıyor: Bizans, Osmanlı ve modern. Meyhanelerden kebapçılara, baharat pazarlarına kadar İstanbul gastronomi cenneti.',
          contentEn: 'Istanbul cuisine reflects its history: Byzantine, Ottoman and modern. From meyhanes to kebabs, through spice markets, Istanbul is a gastronomic paradise.',
        ),
        WikiSection(
          id: 'breakfast',
          title: 'Kahvaltı (Petit-déjeuner)',
          titleTr: 'Kahvaltı',
          titleEn: 'Kahvaltı (Breakfast)',
          content: 'Le petit-déjeuner turc est un festin: fromage, olives, tomates, concombres, œufs, miel, confiture, saucisses et thé.',
          contentTr: 'Türk kahvaltısı bir şölen: peynir, zeytin, domates, salatalık, yumurta, bal, reçel, salam ve çay.',
          contentEn: 'Turkish breakfast is a feast: cheese, olives, tomatoes, cucumbers, eggs, honey, jam, sausages and tea.',
        ),
        WikiSection(
          id: 'street_food',
          title: 'Street food',
          titleTr: 'Sokak yemeği',
          titleEn: 'Street food',
          content: 'Simit (pain sésame), balık ekmek (poisson pain), kokoreç, midye dolma (moules farcies), et tant d\'autres délices des rues.',
          contentTr: 'Simit (susamlı ekmek), balık ekmek, kokoreç, midye dolma ve daha birçok sokak lezzeti.',
          contentEn: 'Simit (sesame bread), balık ekmek (fish bread), kokoreç, midye dolma (stuffed mussels), and many other street delights.',
        ),
        WikiSection(
          id: 'restaurants',
          title: 'Meyhanes et restaurants',
          titleTr: 'Meyhane ve restoranlar',
          titleEn: 'Meyhanes and restaurants',
          content: 'Le meyhane est le restaurant traditionnel ottoman où l\'on déguste le rakı avec des mezze.',
          contentTr: 'Meyhane, rakı ve mezelerin tadını çıkardığınız geleneksel Osmanlı restoranıdır.',
          contentEn: 'The meyhane is the traditional Ottoman restaurant where you taste rakı with mezze.',
        ),
      ],
      locations: [],
    ),
    TravelWiki(
      id: 'wiki_antalya_history',
      title: 'Histoire d\'Antalya',
      titleTr: 'Antalya Tarihi',
      titleEn: 'History of Antalya',
      description: 'De la Pamphylie à la Riviera turque.',
      descriptionTr: 'Pamfilya\'dan Türk Rivierası\'na.',
      descriptionEn: 'From Pamphylia to the Turkish Riviera.',
      category: 'history',
      city: 'Antalya',
      tags: ['Romain', 'Lycien', 'Ottoman'],
      generalSections: [
        WikiSection(
          id: 'intro',
          title: 'Introduction',
          titleTr: 'Giriş',
          titleEn: 'Introduction',
          content: 'Antalya, fondée vers 150 av. J.-C., est la porte d\'entrée de la Riviera turque. Ses ruines antiques et ses plages en font une destination majeure.',
          contentTr: 'MÖ 150 civarında kurulan Antalya, Türk Rivierası\'nın kapısıdır. Antik kalıntıları ve plajlarıyla önemli bir destinasyondur.',
          contentEn: 'Antalya, founded around 150 BC, is the gateway to the Turkish Riviera. Its ancient ruins and beaches make it a major destination.',
        ),
        WikiSection(
          id: 'ancient',
          title: 'Antiquité',
          titleTr: 'Antik dönem',
          titleEn: 'Ancient era',
          content: 'La Pamphylie et la Lycie regorgent de cités antiques: Perge, Aspendos, Side, Termessos, Myra.',
          contentTr: 'Pamfilya ve Likya, antik kentlerle dolu: Perge, Aspendos, Side, Termessos, Myra.',
          contentEn: 'Pamphylia and Lycia are full of ancient cities: Perge, Aspendos, Side, Termessos, Myra.',
        ),
        WikiSection(
          id: 'ottoman',
          title: 'Période ottomane',
          titleTr: 'Osmanlı dönemi',
          titleEn: 'Ottoman period',
          content: 'Antalya fut ottomane du 15e siècle à 1922. Kaleiçi conserve son charme ottoman.',
          contentTr: 'Antalya 15. yüzyıldan 1922\'ye kadar Osmanlı\'nın parçasıydı. Kaleiçi Osmanlı cazibesini koruyor.',
          contentEn: 'Antalya was Ottoman from the 15th century to 1922. Kaleiçi preserves its Ottoman charm.',
        ),
      ],
      locations: [],
    ),
    TravelWiki(
      id: 'wiki_bosphorus',
      title: 'Le Bosphore',
      titleTr: 'Boğaz',
      titleEn: 'The Bosphorus',
      description: 'Le détroit légendaire qui sépare l\'Europe de l\'Asie.',
      descriptionTr: 'Avrupa ve Asya\'yı ayıran efsanevi geçit.',
      descriptionEn: 'The legendary strait separating Europe from Asia.',
      category: 'landmark',
      city: 'Istanbul',
      tags: ['Bosphore', 'Vue', 'Croisière'],
      generalSections: [
        WikiSection(
          id: 'intro',
          title: 'Introduction',
          titleTr: 'Giriş',
          titleEn: 'Introduction',
          content: 'Le Bosphore long de 31 km relie la mer Noire à la mer de Marmara. Ses rives sont bordées de palais ottomans, de maisons en bois et de mosquées.',
          contentTr: '31 km uzunluğundaki Boğaz, Karadeniz\'i Marmara Denizi\'ne bağlıyor. Kıyıları Osmanlı sarayları, ahşap evler ve camilerle süslenmiş.',
          contentEn: 'The 31 km Bosphorus connects the Black Sea to the Sea of Marmara. Its shores are lined with Ottoman palaces, wooden houses and mosques.',
        ),
        WikiSection(
          id: 'palaces',
          title: 'Palais du Bosphore',
          titleTr: 'Boğaz\'daki saraylar',
          titleEn: 'Bosphorus palaces',
          content: 'Dolmabahçe, Beylerbeyi, Çırağan... les palais ottomans longent le détroit.',
          contentTr: 'Dolmabahçe, Beylerbeyi, Çırağan... Osmanlı sarayları boğaz boyunca uzanıyor.',
          contentEn: 'Dolmabahçe, Beylerbeyi, Çırağan... Ottoman palaces line the strait.',
        ),
        WikiSection(
          id: 'cruise',
          title: 'Croisière sur le Bosphore',
          titleTr: 'Boğaz turu',
          titleEn: 'Bosphorus cruise',
          content: 'La croisière de 2 heures offre les plus belles vues sur Istanbul, ses palais et ses forteresses.',
          contentTr: '2 saatlik tur, İstanbul\'un, saraylarının ve kalelerinin en güzel manzaralarını sunuyor.',
          contentEn: 'The 2-hour cruise offers the finest views of Istanbul, its palaces and fortresses.',
        ),
      ],
      locations: [],
    ),
    TravelWiki(
      id: 'wiki_turkish_bath',
      title: 'Le Hammam turc',
      titleTr: 'Türk Hamamı',
      titleEn: 'Turkish Hammam',
      description: 'L\'art du bain ottoman, une expérience millénaire.',
      descriptionTr: 'Osmanlı hamam sanatı, bin yıllık deneyim.',
      descriptionEn: 'The art of the Ottoman bath, a thousand-year experience.',
      category: 'culture',
      city: 'Istanbul',
      tags: ['Hammam', 'Spa', 'Tradition'],
      generalSections: [
        WikiSection(
          id: 'intro',
          title: 'Introduction',
          titleTr: 'Giriş',
          titleEn: 'Introduction',
          content: 'Le hammam est bien plus qu\'un bain: c\'est un rituel social importé des bains romains par les Ottomans.',
          contentTr: 'Hamam sadece bir yıkanma yeri değil: Osmanlı\'nın Roma hamamlarından getirdiği sosyal bir ritüeldir.',
          contentEn: 'The hammam is much more than a bath: it is a social ritual imported from Roman baths by the Ottomans.',
        ),
        WikiSection(
          id: 'ritual',
          title: 'Le rituel',
          titleTr: 'Ritüel',
          titleEn: 'The ritual',
          content: 'Détente sur le marbre chaud, gommage au gant de crin, bain de vapeur, puis repos.',
          contentTr: 'Sıcak mermerde gevşeme, kılıfla ovma, buhar banyosu ve dinlenme.',
          contentEn: 'Relaxation on warm marble, scrub with loofah, steam bath, then rest.',
        ),
        WikiSection(
          id: 'famous',
          title: 'Hammams célèbres',
          titleTr: 'Ünlü hamamlar',
          titleEn: 'Famous hammams',
          content: 'Çemberlitaş (1584), Galata (15e siècle), Ayasofya Hürrem (1556) sont les plus emblématiques.',
          contentTr: 'Çemberlitaş (1584), Galata (15. yüzyıl), Ayasofya Hürrem (1556) en ünlüleridir.',
          contentEn: 'Çemberlitaş (1584), Galata (15th century), Ayasofya Hürrem (1556) are the most emblematic.',
        ),
      ],
      locations: [],
    ),
  ];

  static List<TravelWiki> getByCity(String city) =>
      allWikis.where((w) => w.city.toLowerCase() == city.toLowerCase()).toList();

  static List<TravelWiki> getByCategory(String category) =>
      allWikis.where((w) => w.category == category).toList();

  static TravelWiki? getById(String id) {
    try {
      return allWikis.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> getCategories() =>
      allWikis.map((w) => w.category).toSet().toList()..sort();

  static List<String> getCities() =>
      allWikis.map((w) => w.city).toSet().toList()..sort();

  static int get totalWikis => allWikis.length;
}