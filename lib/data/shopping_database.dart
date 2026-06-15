class ShoppingCenter {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String district;
  final String city;
  final String type; // mall, outlet, market
  final String? category;
  final List<String> brands;
  final String? openingHours;
  final String? phone;
  final String? website;
  final double? rating;
  final String? priceRange;

  ShoppingCenter({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.district,
    required this.city,
    required this.type,
    this.category,
    this.brands = const [],
    this.openingHours,
    this.phone,
    this.website,
    this.rating,
    this.priceRange,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'district': district,
    'city': city,
    'type': type,
    'category': category,
    'brands': brands,
    'openingHours': openingHours,
    'phone': phone,
    'website': website,
    'rating': rating,
    'priceRange': priceRange,
  };

  factory ShoppingCenter.fromJson(Map<String, dynamic> json) => ShoppingCenter(
    id: json['id'],
    name: json['name'],
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    address: json['address'] ?? '',
    district: json['district'] ?? '',
    city: json['city'] ?? '',
    type: json['type'] ?? 'mall',
    category: json['category'],
    brands: List<String>.from(json['brands'] ?? []),
    openingHours: json['openingHours'],
    phone: json['phone'],
    website: json['website'],
    rating: (json['rating'] ?? 4.0).toDouble(),
    priceRange: json['priceRange'],
  );
}

class ShoppingDatabase {
  static final List<ShoppingCenter> allShoppingCenters = [
    // ==================== İSTANBUL MALLS & OUTLETS ====================
    
    // Maslak / Levent Area
    ShoppingCenter(
      id: 'm_ist_001',
      name: 'Mall of Istanbul',
      latitude: 41.0655,
      longitude: 29.0185,
      address: 'Mall of Istanbul, Büyükdere Cad. 181, Şişli',
      district: 'Maslak',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'Mango', 'LCW', 'Defacto', 'Beymen', 'Marks & Spencer', 'Nike', 'Adidas', 'Vakko', 'LCW'],
      openingHours: '10:00-22:00',
      phone: '+90 212 604 4444',
      website: 'https://www.mallofistanbul.com',
      rating: 4.5,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_002',
      name: 'İstinye Park',
      latitude: 41.1125,
      longitude: 29.0325,
      address: 'İstinye Mah. İstinye Bayırı Cad. No:108, Sarıyer',
      district: 'İstinye',
      city: 'Istanbul',
      type: 'mall',
      category: 'Luxury Mall',
      brands: ['Gucci', 'Prada', 'Louis Vuitton', 'Chanel', 'Dior', 'Cartier', 'Apple Store', 'Tesla Showroom'],
      openingHours: '10:00-22:00',
      phone: '+90 212 345 6789',
      website: 'https://www.istinyepark.com.tr',
      rating: 4.7,
      priceRange: '₽₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_003',
      name: 'Kanyon',
      latitude: 41.0575,
      longitude: 29.0265,
      address: 'Levent Mah. Büyükdere Cad. No:185, Şişli',
      district: 'Levent',
      city: 'Istanbul',
      type: 'mall',
      category: 'Lifestyle Mall',
      brands: ['Beymen', 'Zara', 'Bershka', 'Stradivarius', 'Mavi', 'W Collection', 'Dogo', 'Muff'],
      openingHours: '10:00-22:00',
      phone: '+90 212 284 4444',
      website: 'https://www.kanyon.com.tr',
      rating: 4.4,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_004',
      name: 'Forum Istanbul',
      latitude: 41.0465,
      longitude: 29.0525,
      address: 'Huzur Mah. Huzur Sok. No:4, Ataşehir',
      district: 'Ataşehir',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'Mango', 'Defacto', 'LCW', 'Koton', 'Mavi', 'Nike', 'Adidas', 'Puma'],
      openingHours: '10:00-22:00',
      phone: '+90 216 574 0505',
      website: 'https://www.forumistanbul.com',
      rating: 4.3,
      priceRange: '₽₽',
    ),

    // Kadıköy / Moda Area
    ShoppingCenter(
      id: 'm_ist_005',
      name: 'Kadıköy Çarşı',
      latitude: 41.0085,
      longitude: 29.0245,
      address: 'Kadıköy Bazar Area, Kadıköy',
      district: 'Kadıköy',
      city: 'Istanbul',
      type: 'market',
      category: 'Traditional Bazaar',
      brands: [],
      openingHours: '08:00-20:00',
      rating: 4.5,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ist_006',
      name: 'Bahariye Caddesi',
      latitude: 41.0125,
      longitude: 29.0315,
      address: 'Bahariye Cad. from Kadıköy to Moda',
      district: 'Moda',
      city: 'Istanbul',
      type: 'market',
      category: 'Street Shopping',
      brands: [],
      openingHours: '09:00-21:00',
      rating: 4.4,
      priceRange: '₽',
    ),

    // Beşiktaş / Nişantaşı Area
    ShoppingCenter(
      id: 'm_ist_007',
      name: 'Nişantaşı Shopping District',
      latitude: 41.0465,
      longitude: 29.0095,
      address: 'Nişantaşı, Teşvikiye, Şişli',
      district: 'Nişantaşı',
      city: 'Istanbul',
      type: 'market',
      category: 'Luxury Street',
      brands: ['Gucci', 'Prada', 'Valentino', 'Balmain', 'Versace', 'Dolce & Gabbana'],
      openingHours: '10:00-21:00',
      rating: 4.8,
      priceRange: '₽₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_008',
      name: 'Küçük Caddesi',
      latitude: 41.0425,
      longitude: 29.0115,
      address: 'Abide-i Hürriyet Cad., Şişli',
      district: 'Şişli',
      city: 'Istanbul',
      type: 'market',
      category: 'Street Shopping',
      brands: [],
      openingHours: '09:00-21:00',
      rating: 4.3,
      priceRange: '₽',
    ),

    // Taksim / Beyoğlu Area
    ShoppingCenter(
      id: 'm_ist_009',
      name: 'İstiklal Avenue Shops',
      latitude: 41.0365,
      longitude: 28.9738,
      address: 'İstiklal Cad. from Taksim to Tünel',
      district: 'Beyoğlu',
      city: 'Istanbul',
      type: 'market',
      category: 'Historic Street',
      brands: ['Beymen', 'Mavi', 'Koton', 'Defacto', 'LCW'],
      openingHours: '09:00-22:00',
      rating: 4.6,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_010',
      name: 'Grand Bazaar',
      latitude: 41.0092,
      longitude: 28.9695,
      address: 'Beyazıt, Fatih',
      district: 'Grand Bazaar',
      city: 'Istanbul',
      type: 'market',
      category: 'Traditional Bazaar',
      brands: [],
      openingHours: '08:30-19:00',
      phone: '+90 212 519 1248',
      rating: 4.9,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ist_011',
      name: 'Spice Bazaar',
      latitude: 41.0185,
      longitude: 28.9715,
      address: 'Rüstem Paşa Mah. Hasırcılar Cad. No:88, Eminönü',
      district: 'Eminönü',
      city: 'Istanbul',
      type: 'market',
      category: 'Spice Market',
      brands: [],
      openingHours: '08:00-19:00',
      rating: 4.7,
      priceRange: '₽',
    ),

    // Fatih / Aksaray Area
    ShoppingCenter(
      id: 'm_ist_012',
      name: 'Aksaray Aksa Park',
      latitude: 41.0115,
      longitude: 28.9605,
      address: 'Aksaray Mah. İstanbul Cad. No:45',
      district: 'Aksaray',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Beymen', 'Defacto'],
      openingHours: '09:00-21:00',
      rating: 4.1,
      priceRange: '₽',
    ),

    // Bakırköy Area
    ShoppingCenter(
      id: 'm_ist_013',
      name: 'Carousel AVM',
      latitude: 40.9875,
      longitude: 28.8715,
      address: 'Yeşilyurt Mah. Feneryolu Cad. No:88, Bakırköy',
      district: 'Bakırköy',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'Mango', 'Mavi', 'Koton', 'LCW', 'Beymen', 'Nike'],
      openingHours: '10:00-22:00',
      phone: '+90 212 560 8080',
      website: 'https://www.carousel.com.tr',
      rating: 4.3,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_014',
      name: 'Aqua Florya',
      latitude: 40.9815,
      longitude: 28.8125,
      address: 'Florya Cad. No:88, Bakırköy',
      district: 'Florya',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'Bershka', 'Stradivarius', 'Mavi', 'Koton'],
      openingHours: '10:00-22:00',
      phone: '+90 212 573 0808',
      rating: 4.2,
      priceRange: '₽₽',
    ),

    // Avcılar Area
    ShoppingCenter(
      id: 'm_ist_015',
      name: 'Marmara Park AVM',
      latitude: 40.9965,
      longitude: 28.7215,
      address: 'Cihangir Mah. Marmara Cad. No:88, Avcılar',
      district: 'Avcılar',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'LCW', 'Koton', 'Mavi', 'Defacto', 'Puma'],
      openingHours: '10:00-22:00',
      phone: '+90 212 590 3030',
      rating: 4.0,
      priceRange: '₽',
    ),

    // Beylikdüzü Area
    ShoppingCenter(
      id: 'm_ist_016',
      name: 'Akbatı AVM',
      latitude: 41.0055,
      longitude: 28.6525,
      address: 'Beylikdüzü Cad. No:125, Beylikdüzü',
      district: 'Beylikdüzü',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'Koton', 'Mavi', 'LCW', 'Defacto'],
      openingHours: '10:00-22:00',
      phone: '+90 212 850 8080',
      rating: 4.1,
      priceRange: '₽',
    ),

    // Airport Area
    ShoppingCenter(
      id: 'm_ist_017',
      name: 'İstanbul Airport Duty Free',
      latitude: 41.2752,
      longitude: 28.7515,
      address: 'İstanbul Havalimanı Terminal A, Arnavutköy',
      district: 'Airport',
      city: 'Istanbul',
      type: 'outlet',
      category: 'Duty Free',
      brands: ['Gucci', 'Prada', 'Chanel', 'Dior', 'Rolex', 'Hugo Boss', 'Tommy Hilfiger'],
      openingHours: '24 Saat',
      phone: '+90 212 463 1234',
      rating: 4.6,
      priceRange: '₽₽₽',
    ),
    ShoppingCenter(
      id: 'm_ist_018',
      name: 'Sabiha Gökçen Duty Free',
      latitude: 40.8985,
      longitude: 29.3082,
      address: 'Sabiha Gökçen Havalimanı, Pendik',
      district: 'Airport',
      city: 'Istanbul',
      type: 'outlet',
      category: 'Duty Free',
      brands: ['Gucci', 'Prada', 'Chanel', 'Hugo Boss'],
      openingHours: '24 Saat',
      rating: 4.4,
      priceRange: '₽₽',
    ),

    // Anadolu Hisarı / Üsküdar Area
    ShoppingCenter(
      id: 'm_ist_019',
      name: 'Anadolu Hisarı Çarşı',
      latitude: 41.0455,
      longitude: 29.0585,
      address: 'Anadolu Hisarı Mah. Tersane Cad.',
      district: 'Anadolu Hisarı',
      city: 'Istanbul',
      type: 'market',
      category: 'Traditional Market',
      brands: [],
      openingHours: '08:00-20:00',
      rating: 4.2,
      priceRange: '₽',
    ),

    // Umraniye Area
    ShoppingCenter(
      id: 'm_ist_020',
      name: 'Umraniye AVM',
      latitude: 41.0285,
      longitude: 29.0925,
      address: 'Umraniye Mah. Atatürk Cad. No:88, Üsküdar',
      district: 'Üsküdar',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'LCW', 'Koton', 'Mavi'],
      openingHours: '10:00-22:00',
      rating: 4.0,
      priceRange: '₽',
    ),

    // Pendik / Kurtköy Area
    ShoppingCenter(
      id: 'm_ist_021',
      name: 'Kurtköy AVM',
      latitude: 40.9185,
      longitude: 29.2725,
      address: 'Kurtköy Mah. Ankara Cad. No:125, Pendik',
      district: 'Pendik',
      city: 'Istanbul',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'Koton', 'Mavi', 'LCW'],
      openingHours: '10:00-21:00',
      rating: 4.1,
      priceRange: '₽',
    ),

    // ==================== ANTALYA MALLS & OUTLETS ====================

    // Lara / Kundu Area
    ShoppingCenter(
      id: 'm_ant_001',
      name: 'Mall of Antalya',
      latitude: 36.8525,
      longitude: 30.7835,
      address: 'Lara Mah. Fener Cad. No:1, Muratpaşa',
      district: 'Lara',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'Mango', 'LCW', 'Defacto', 'Beymen', 'Koton', 'Mavi', 'Puma', 'Nike', 'Adidas', 'Vakko', 'Beymen'],
      openingHours: '10:00-22:00',
      phone: '+90 242 324 4444',
      website: 'https://www.mallofantalya.com',
      rating: 4.6,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ant_002',
      name: 'Terracity AVM',
      latitude: 36.8595,
      longitude: 30.7495,
      address: 'Fener Mah. Çakırlar Cad. No:125, Muratpaşa',
      district: 'Lara',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'H&M', 'Mango', 'LCW', 'Koton', 'Mavi', 'Beymen', 'Defacto', 'Nike', 'Adidas'],
      openingHours: '10:00-22:00',
      phone: '+90 242 312 1212',
      website: 'https://www.terracity.com.tr',
      rating: 4.5,
      priceRange: '₽₽',
    ),
    ShoppingCenter(
      id: 'm_ant_003',
      name: 'Mark Antalya',
      latitude: 36.8795,
      longitude: 30.7015,
      address: 'Muratpaşa Mah. Cumhuriyet Cad. No:88, Muratpaşa',
      district: 'Muratpaşa',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'LCW', 'Koton', 'Mavi', 'Defacto', 'Bershka', 'Stradivarius'],
      openingHours: '10:00-21:00',
      phone: '+90 242 248 8080',
      rating: 4.3,
      priceRange: '₽',
    ),

    // Konyaaltı Area
    ShoppingCenter(
      id: 'm_ant_004',
      name: 'Migros Shopping Center Konyaaltı',
      latitude: 36.8815,
      longitude: 30.6415,
      address: 'Konyaaltı Mah. Akdeniz Cad. No:125, Konyaaltı',
      district: 'Konyaaltı',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi', 'Defacto'],
      openingHours: '09:00-21:00',
      phone: '+90 242 259 5050',
      rating: 4.0,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ant_005',
      name: 'Outlet Center Antalya',
      latitude: 36.8695,
      longitude: 30.6285,
      address: 'Konyaaltı Arapsuyu Mah. 88. Cad. No:15',
      district: 'Konyaaltı',
      city: 'Antalya',
      type: 'outlet',
      category: 'Factory Outlet',
      brands: ['Zara Outlet', 'H&M Outlet', 'Beymen Outlet', 'LCW Outlet', 'Defacto Outlet', 'Koton Outlet'],
      openingHours: '10:00-21:00',
      phone: '+90 242 252 6060',
      rating: 4.2,
      priceRange: '₽',
    ),

    // Kepez Area
    ShoppingCenter(
      id: 'm_ant_006',
      name: 'Antalya Kepez AVM',
      latitude: 36.8965,
      longitude: 30.6985,
      address: 'Kepez Mah. Şarampol Cad. No:225, Kepez',
      district: 'Kepez',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'LCW', 'Koton', 'Mavi', 'Defacto'],
      openingHours: '09:00-21:00',
      rating: 3.9,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ant_007',
      name: 'Özkanlar AVM',
      latitude: 36.9085,
      longitude: 30.6815,
      address: 'Özkanlar Mah. Gazi Bulvarı No:125, Kepez',
      district: 'Kepez',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi', 'Beymen'],
      openingHours: '09:00-20:00',
      rating: 4.0,
      priceRange: '₽',
    ),

    // Alanya Area
    ShoppingCenter(
      id: 'm_ant_008',
      name: 'Alanyum AVM',
      latitude: 36.2515,
      longitude: 32.0115,
      address: 'Cumhuriyet Mah. Saray Cad. No:88, Alanya',
      district: 'Alanya',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'LCW', 'Koton', 'Mavi', 'Defacto', 'Nike', 'Adidas'],
      openingHours: '10:00-22:00',
      phone: '+90 242 514 1010',
      rating: 4.3,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ant_009',
      name: 'Alanya Outlet',
      latitude: 36.2455,
      longitude: 32.0055,
      address: 'Kargıcak Mah. D-400 Cad. No:45, Alanya',
      district: 'Alanya',
      city: 'Antalya',
      type: 'outlet',
      category: 'Factory Outlet',
      brands: ['LCW Outlet', 'Koton Outlet', 'Mavi Outlet', 'Defacto Outlet'],
      openingHours: '10:00-20:00',
      phone: '+90 242 515 2020',
      rating: 4.1,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ant_010',
      name: 'Alanya Bazaar',
      latitude: 36.2475,
      longitude: 31.9995,
      address: 'Alanya City Center, Alanya',
      district: 'Alanya',
      city: 'Antalya',
      type: 'market',
      category: 'Traditional Bazaar',
      brands: [],
      openingHours: '08:00-20:00',
      rating: 4.5,
      priceRange: '₽',
    ),

    // Side Area
    ShoppingCenter(
      id: 'm_ant_011',
      name: 'Side Mall',
      latitude: 36.7695,
      longitude: 31.3915,
      address: 'Side Mah. Kumköy Cad. No:88, Manavgat',
      district: 'Side',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi', 'Defacto'],
      openingHours: '10:00-20:00',
      phone: '+90 242 753 3030',
      rating: 4.0,
      priceRange: '₽',
    ),
    ShoppingCenter(
      id: 'm_ant_012',
      name: 'Manavgat AVM',
      latitude: 36.7865,
      longitude: 31.4415,
      address: 'Side Cad. No:125, Manavgat',
      district: 'Manavgat',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['Zara', 'LCW', 'Koton', 'Mavi', 'Defacto'],
      openingHours: '10:00-21:00',
      phone: '+90 242 754 4040',
      rating: 4.1,
      priceRange: '₽',
    ),

    // Belek Area
    ShoppingCenter(
      id: 'm_ant_013',
      name: 'Kadriye Market',
      latitude: 36.8525,
      longitude: 31.0625,
      address: 'Kadriye Mah. Atatürk Cad. No:88, Belek',
      district: 'Belek',
      city: 'Antalya',
      type: 'market',
      category: 'Local Market',
      brands: [],
      openingHours: '08:00-21:00',
      rating: 4.2,
      priceRange: '₽',
    ),

    // Kemer Area
    ShoppingCenter(
      id: 'm_ant_014',
      name: 'Kemer AVM',
      latitude: 36.6015,
      longitude: 30.5635,
      address: 'Kemer Mah. Atatürk Cad. No:125, Kemer',
      district: 'Kemer',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi', 'Defacto'],
      openingHours: '10:00-20:00',
      phone: '+90 242 814 4040',
      rating: 3.8,
      priceRange: '₽',
    ),

    // Kumluca / Finike Area
    ShoppingCenter(
      id: 'm_ant_015',
      name: 'Kumluca AVM',
      latitude: 36.3715,
      longitude: 30.4015,
      address: 'Kumluca Mah. Cumhuriyet Cad. No:88, Kumluca',
      district: 'Kumluca',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi'],
      openingHours: '09:00-19:00',
      rating: 3.9,
      priceRange: '₽',
    ),

    // Kaş Area
    ShoppingCenter(
      id: 'm_ant_016',
      name: 'Kaş Market',
      latitude: 36.2005,
      longitude: 29.6475,
      address: 'Kaş Mah. Cumhuriyet Cad. No:45, Kaş',
      district: 'Kaş',
      city: 'Antalya',
      type: 'market',
      category: 'Local Market',
      brands: [],
      openingHours: '08:00-20:00',
      rating: 4.3,
      priceRange: '₽',
    ),

    // Döşemealtı Area
    ShoppingCenter(
      id: 'm_ant_017',
      name: 'Döşemealtı AVM',
      latitude: 36.9515,
      longitude: 30.6415,
      address: 'Yeşilbayır Mah. Cad. No:125, Döşemealtı',
      district: 'Döşemealtı',
      city: 'Antalya',
      type: 'mall',
      category: 'Shopping Mall',
      brands: ['LCW', 'Koton', 'Mavi', 'Beymen'],
      openingHours: '09:00-20:00',
      phone: '+90 242 427 3030',
      rating: 4.0,
      priceRange: '₽',
    ),
  ];

  static List<ShoppingCenter> getByCity(String city) {
    return allShoppingCenters.where((s) => s.city == city).toList();
  }

  static List<ShoppingCenter> getByType(String type) {
    return allShoppingCenters.where((s) => s.type == type).toList();
  }

  static List<String> get cities {
    return allShoppingCenters.map((s) => s.city).toSet().toList()..sort();
  }

  static List<String> get districts {
    return allShoppingCenters.map((s) => s.district).toSet().toList()..sort();
  }

  static List<String> get types {
    return allShoppingCenters.map((s) => s.type).toSet().toList();
  }

  static List<ShoppingCenter> search(String query) {
    final q = query.toLowerCase();
    final results = allShoppingCenters.where((s) => 
      s.name.toLowerCase().contains(q) ||
      s.district.toLowerCase().contains(q) ||
      s.city.toLowerCase().contains(q) ||
      s.brands.any((b) => b.toLowerCase().contains(q))
    );
    return results.toList();
  }

  static int get totalCount => allShoppingCenters.length;
  
  static int getIstanbulCount() => allShoppingCenters.where((s) => s.city == 'Istanbul').length;
  
  static int getAntalyaCount() => allShoppingCenters.where((s) => s.city == 'Antalya').length;
}