class ShoppingCenter {
  final String id;
  final String name;
  final String type;
  final String city;
  final String district;
  final String description;
  final String address;
  final double rating;
  final String? priceRange;
  final String? openingHours;
  final String? phone;
  final String? website;
  final List<String> brands;
  final bool hasParking;

  const ShoppingCenter({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.district,
    required this.description,
    required this.address,
    this.rating = 0,
    this.priceRange,
    this.openingHours,
    this.phone,
    this.website,
    this.brands = const [],
    this.hasParking = true,
  });
}

class ShoppingData {
  static final List<ShoppingCenter> centers = [
    // === Istanbul - Malls ===
    ShoppingCenter(id: 'm1', name: 'Istinye Park', type: 'Centre Commercial', city: 'Istanbul', district: 'Istinye',
        description: 'Centre de luxe avec plus de 300 boutiques, restaurants et cinéma. Marques internationales et designers turcs.',
        address: 'Istinye Park, Sarıyer/İstanbul', rating: 4.5, priceRange: 'Premium', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm2', name: 'Zorlu Center', type: 'Centre Commercial', city: 'Istanbul', district: 'Beşiktaş',
        description: 'Centre moderne avec boutiques de luxe, restaurant gastronomique et salle de concert.',
        address: 'Zorlu Center, Beşiktaş/İstanbul', rating: 4.6, priceRange: 'Premium', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm3', name: 'Mall of Istanbul', type: 'Centre Commercial', city: 'Istanbul', district: 'Başakşehir',
        description: 'L\'un des plus grands centres d\'Europe avec plus de 350 boutiques, patinoire et parc d\'attractions.',
        address: 'Mall of Istanbul, Başakşehir/İstanbul', rating: 4.3, priceRange: 'Moyen', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm4', name: 'Forum Istanbul', type: 'Centre Commercial', city: 'Istanbul', district: 'Bayrampaşa',
        description: 'Grand centre commercial familial avec de nombreuses marques accessibles.',
        address: 'Forum Istanbul, Bayrampaşa/İstanbul', rating: 4.2, priceRange: 'Moyen', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm5', name: 'Akmerkez', type: 'Centre Commercial', city: 'Istanbul', district: 'Etiler',
        description: 'Premier centre commercial d\'Istanbul. Boutiques, restaurants, et cafés.',
        address: 'Akmerkez, Etiler/İstanbul', rating: 4.3, priceRange: 'Premium', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm6', name: 'Cevahir Mall', type: 'Centre Commercial', city: 'Istanbul', district: 'Şişli',
        description: 'Grand centre commercial avec aquarium, cinéma IMAX et nombreuses boutiques.',
        address: 'Cevahir, Şişli/İstanbul', rating: 4.1, priceRange: 'Moyen', openingHours: '10:00-22:00'),

    // === Istanbul - Bazars ===
    ShoppingCenter(id: 'b1', name: 'Grand Bazar (Kapalıçarşı)', type: 'Bazar', city: 'Istanbul', district: 'Beyazıt',
        description: 'Plus grand marché couvert du monde. Bijoux, tapis, céramiques, épices, textiles. Négociation obligatoire !',
        address: 'Kapalıçarşı, Beyazıt/İstanbul', rating: 4.4, priceRange: 'Variable', openingHours: '09:00-19:00 (dim: fermé)',
        brands: ['Bijoux', 'Tapis', 'Céramique', 'Textile', 'Épices']),
    ShoppingCenter(id: 'b2', name: 'Bazar aux Épices (Mısır Çarşısı)', type: 'Bazar', city: 'Istanbul', district: 'Eminönü',
        description: 'Marché historique du 17e siècle. Épices, thés, fruits secs, loukoums et souvenirs.',
        address: 'Mısır Çarşısı, Eminönü/İstanbul', rating: 4.3, priceRange: 'Moyen', openingHours: '08:00-19:00',
        brands: ['Épices', 'Thé', 'Loukoums', 'Fruits secs']),
    ShoppingCenter(id: 'b3', name: 'Arasta Bazaar', type: 'Bazar', city: 'Istanbul', district: 'Sultanahmet',
        description: 'Petit bazar calme près de la Mosquée Bleue. Idéal pour les souvenirs de qualité.',
        address: 'Arasta Çarşısı, Sultanahmet/İstanbul', rating: 4.2, priceRange: 'Moyen', openingHours: '09:00-19:00'),

    // === Antalya ===
    ShoppingCenter(id: 'm7', name: 'MarkAntalya', type: 'Centre Commercial', city: 'Antalya', district: 'Kepez',
        description: 'Grand centre commercial avec boutiques, restauration et aires de jeux.',
        address: 'MarkAntalya, Kepez/Antalya', rating: 4.1, priceRange: 'Moyen', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'm8', name: 'TerraCity', type: 'Centre Commercial', city: 'Antalya', district: 'Muratpaşa',
        description: 'Centre moderne au cœur d\'Antalya. Marques internationales et restaurants.',
        address: 'TerraCity, Muratpaşa/Antalya', rating: 4.3, priceRange: 'Moyen', openingHours: '10:00-22:00'),
    ShoppingCenter(id: 'b4', name: 'Bazar Kaleiçi', type: 'Bazar', city: 'Antalya', district: 'Kaleiçi',
        description: 'Boutiques artisanales dans les ruelles historiques de Kaleiçi. Tapis, bijoux, céramiques.',
        address: 'Kaleiçi, Muratpaşa/Antalya', rating: 4.2, priceRange: 'Moyen', openingHours: '09:00-20:00'),
  ];

  static List<ShoppingCenter> getByCity(String city) =>
      centers.where((c) => c.city == city).toList();

  static List<ShoppingCenter> getByType(String type) =>
      centers.where((c) => c.type == type).toList();
}
