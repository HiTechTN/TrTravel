class TransportOption {
  final String name;
  final String nameTr;
  final String type;
  final String description;
  final String price;
  final String hours;
  final String frequency;
  final String icon;
  final List<String> tips;

  const TransportOption({
    required this.name,
    required this.nameTr,
    required this.type,
    required this.description,
    required this.price,
    required this.hours,
    required this.frequency,
    required this.icon,
    this.tips = const [],
  });
}

class TransportCity {
  final String city;
  final List<TransportOption> options;

  const TransportCity({required this.city, required this.options});
}

class TransportData {
  static final List<TransportCity> all = [
    TransportCity(city: 'Istanbul', options: [
      TransportOption(
        name: 'Métro',
        nameTr: 'Metro',
        type: 'metro',
        description: '11 lignes de métro modernes et climatisées. Relie les principales zones d\'Istanbul.',
        price: '15-20 TL par trajet (Istanbulkart)',
        hours: '06:00 - 00:00',
        frequency: 'Toutes les 3-8 minutes',
        icon: '🚇',
        tips: [
          'Achetez l\'Istanbulkart (130 TL) dans toutes les stations',
          'La ligne M11 relie l\'aéroport au centre',
          'Évitez les heures de pointe (8h-9h, 18h-19h)',
          'Application: Metro Istanbul pour les horaires temps réel',
        ],
      ),
      TransportOption(
        name: 'Tramway',
        nameTr: 'Tramvay',
        type: 'tram',
        description: 'Ligne T1 Kabataş-Bağcılar, idéale pour les touristes. Passe par Sultanahmet, Grand Bazar, Eminönü.',
        price: '15-20 TL par trajet (Istanbulkart)',
        hours: '06:00 - 00:00',
        frequency: 'Toutes les 2-5 minutes',
        icon: '🚊',
        tips: [
          'La ligne la plus utile pour les touristes (T1)',
          'Attention aux pickpockets aux heures d\'affluence',
          'La carte Istanbulkart fonctionne aussi sur le tram',
        ],
      ),
      TransportOption(
        name: 'Ferry',
        nameTr: 'Feribot',
        type: 'ferry',
        description: 'Traversées du Bosphore entre Europe et Asie. Vue magnifique sur Istanbul.',
        price: '20-30 TL par trajet (Istanbulkart)',
        hours: '06:30 - 23:00',
        frequency: 'Toutes les 15-30 minutes',
        icon: '⛴️',
        tips: [
          'Prenez le ferry Eminönü-Kadıköy pour la meilleure vue',
          'Les ferries sont ponctuels - arrivez 5 min avant',
          'Dernier ferry vers la plupart des destinations vers 23h',
          'Traversée Eminönü-Kadıköy: ~20 min',
        ],
      ),
      TransportOption(
        name: 'Taxi',
        nameTr: 'Taksi',
        type: 'taxi',
        description: 'Taxis jaunes omniprésents. Utilisez BiTaksi ou Uber pour plus de sécurité.',
        price: 'Ouverture: 50 TL, 25 TL/km',
        hours: '24h/24',
        frequency: 'Disponible partout',
        icon: '🚕',
        tips: [
          'Vérifiez que le compteur (taksimetre) est ACTIVÉ',
          'Évitez les taxis qui proposent un prix fixe',
          'Utilisez BiTaksi (application locale) pour commander',
          'Uber fonctionne aussi à Istanbul',
          'Un trajet aéroport-centre coûte 800-1200 TL',
        ],
      ),
      TransportOption(
        name: 'Bus',
        nameTr: 'Otobüs',
        type: 'bus',
        description: 'Vaste réseau de bus municipaux (İETT). Utile pour les destinations sans métro.',
        price: '15-20 TL par trajet (Istanbulkart)',
        hours: '06:00 - 00:00 (certaines lignes 24h)',
        frequency: 'Toutes les 10-30 minutes',
        icon: '🚌',
        tips: [
          'Les bus peuvent être bloqués dans les embouteillages',
          'Préférez le métro quand c\'est possible',
          'Les bus Metrobus ont leur propre voie (plus rapides)',
        ],
      ),
      TransportOption(
        name: 'Funiculaire',
        nameTr: 'Füniküler',
        type: 'funicular',
        description: 'Deux lignes: Taksim-Kabataş (F1) et Tünel (historique, 1875).',
        price: '15-20 TL',
        hours: '07:00 - 23:00',
        frequency: 'Toutes les 2-5 minutes',
        icon: '🚃',
        tips: [
          'Le Tünel est le 2e plus vieux métro du monde (1875)',
          'Relie Karaköy à Tünel (Istiklal) en 1 minute',
        ],
      ),
    ]),
    TransportCity(city: 'Antalya', options: [
      TransportOption(
        name: 'Tramway',
        nameTr: 'Tramvay',
        type: 'tram',
        description: 'Ligne T1 (Müze-Aksu) et T2 (Fatih-Meydan). Relie le centre à la plage Konyaaltı.',
        price: '12-15 TL par trajet (Antalyakart)',
        hours: '06:00 - 23:00',
        frequency: 'Toutes les 10-15 minutes',
        icon: '🚊',
        tips: [
          'Achetez l\'Antalyakart dans les stations',
          'La ligne T1 dessert l\'aéroport',
          'Tramway moderne et climatisé',
        ],
      ),
      TransportOption(
        name: 'Bus',
        nameTr: 'Otobüs',
        type: 'bus',
        description: 'Réseau de bus couvrant toute la ville et les plages.',
        price: '12-15 TL par trajet (Antalyakart)',
        hours: '06:00 - 23:00',
        frequency: 'Toutes les 15-30 minutes',
        icon: '🚌',
        tips: [
          'Les bus climatisés sont confortables',
          'La ligne LC07 va à la plage Konyaaltı',
          'Les bus pour Olympos/Çıralı partent du terminal',
        ],
      ),
      TransportOption(
        name: 'Taxi',
        nameTr: 'Taksi',
        type: 'taxi',
        description: 'Taxis disponibles en ville et à l\'aéroport. Moins chers qu\'à Istanbul.',
        price: 'Ouverture: 30 TL, 18 TL/km',
        hours: '24h/24',
        frequency: 'Disponible',
        icon: '🚕',
        tips: [
          'Utilisez BiTaksi pour commander',
          'De l\'aéroport à Kaleiçi: ~200-300 TL',
          'Négociez pour les trajets longs',
        ],
      ),
      TransportOption(
        name: 'Location Voiture',
        nameTr: 'Araç Kiralama',
        type: 'car',
        description: 'Idéal pour explorer la côte turquoise (Olympos, Kaputaş, Kas).',
        price: '300-800 TL/jour selon le véhicule',
        hours: '24h/24',
        frequency: 'Disponible à l\'aéroport et en ville',
        icon: '🚗',
        tips: [
          'Comparez les prix sur Rentalcars.com ou directement',
          'Les routes côtières sont sinueuses - conduite prudente',
          'Stationnement payant dans le centre (20-30 TL/h)',
          'Assurance tous risques recommandée',
        ],
      ),
    ]),
  ];
}
