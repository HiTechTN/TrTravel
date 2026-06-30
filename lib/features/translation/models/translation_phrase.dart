class TranslationPhrase {
  final String french;
  final String turkish;
  final String? english;
  final String category;

  const TranslationPhrase({
    required this.french,
    required this.turkish,
    this.english,
    required this.category,
  });
}

class PhraseCategory {
  final String name;
  final String emoji;
  final List<TranslationPhrase> phrases;

  const PhraseCategory({
    required this.name,
    required this.emoji,
    required this.phrases,
  });
}

class TranslationPhraseBook {
  static List<PhraseCategory> get all => [
    _salutations,
    _directions,
    _food,
    _shopping,
    _emergency,
    _transport,
    _accommodation,
    _numbers,
    _time,
    _health,
  ];

  static const _salutations = PhraseCategory(
    name: 'Salutations',
    emoji: '👋',
    phrases: [
      TranslationPhrase(french: 'Bonjour', turkish: 'Merhaba', english: 'Hello', category: 'salutations'),
      TranslationPhrase(french: 'Au revoir', turkish: 'Hoşça kal', english: 'Goodbye', category: 'salutations'),
      TranslationPhrase(french: 'Merci', turkish: 'Teşekkür ederim', english: 'Thank you', category: 'salutations'),
      TranslationPhrase(french: 'S\'il vous plaît', turkish: 'Lütfen', english: 'Please', category: 'salutations'),
      TranslationPhrase(french: 'Pardon', turkish: 'Özür dilerim', english: 'Sorry', category: 'salutations'),
      TranslationPhrase(french: 'Comment allez-vous ?', turkish: 'Nasılsınız?', english: 'How are you?', category: 'salutations'),
      TranslationPhrase(french: 'Bien, merci', turkish: 'İyiyim, teşekkürler', english: 'Fine, thanks', category: 'salutations'),
      TranslationPhrase(french: 'Oui', turkish: 'Evet', english: 'Yes', category: 'salutations'),
      TranslationPhrase(french: 'Non', turkish: 'Hayır', english: 'No', category: 'salutations'),
      TranslationPhrase(french: 'Au revoir', turkish: 'Güle güle', english: 'Goodbye (said by person leaving)', category: 'salutations'),
    ],
  );

  static const _directions = PhraseCategory(
    name: 'Directions',
    emoji: '🗺️',
    phrases: [
      TranslationPhrase(french: 'Où est le musée ?', turkish: 'Müze nerede?', english: 'Where is the museum?', category: 'directions'),
      TranslationPhrase(french: 'Tournez à gauche', turkish: 'Sola dönün', english: 'Turn left', category: 'directions'),
      TranslationPhrase(french: 'Tournez à droite', turkish: 'Sağa dönün', english: 'Turn right', category: 'directions'),
      TranslationPhrase(french: 'Tout droit', turkish: 'Düz git', english: 'Go straight', category: 'directions'),
      TranslationPhrase(french: 'Près d\'ici', turkish: 'Buraya yakın', english: 'Near here', category: 'directions'),
      TranslationPhrase(french: 'Loin', turkish: 'Uzak', english: 'Far', category: 'directions'),
      TranslationPhrase(french: 'À quelle distance ?', turkish: 'Ne kadar uzak?', english: 'How far?', category: 'directions'),
      TranslationPhrase(french: 'Pouvez-vous me montrer sur la carte ?', turkish: 'Haritada gösterebilir misiniz?', english: 'Can you show me on the map?', category: 'directions'),
    ],
  );

  static const _food = PhraseCategory(
    name: 'Nourriture',
    emoji: '🍽️',
    phrases: [
      TranslationPhrase(french: 'Je voudrais commander', turkish: 'Sipariş vermek istiyorum', english: 'I would like to order', category: 'food'),
      TranslationPhrase(french: 'L\'addition, s\'il vous plaît', turkish: 'Hesap lütfen', english: 'The bill, please', category: 'food'),
      TranslationPhrase(french: 'C\'est délicieux', turkish: 'Çok lezzetli', english: 'It\'s delicious', category: 'food'),
      TranslationPhrase(french: 'Je suis végétarien', turkish: 'Vejetaryenim', english: 'I am vegetarian', category: 'food'),
      TranslationPhrase(french: 'Sans gluten', turkish: 'Glutensiz', english: 'Gluten-free', category: 'food'),
      TranslationPhrase(french: 'Épicé', turkish: 'Acılı', english: 'Spicy', category: 'food'),
      TranslationPhrase(french: 'Eau', turkish: 'Su', english: 'Water', category: 'food'),
      TranslationPhrase(french: 'Thé', turkish: 'Çay', english: 'Tea', category: 'food'),
      TranslationPhrase(french: 'Café', turkish: 'Kahve', english: 'Coffee', category: 'food'),
      TranslationPhrase(french: 'Combien ça coûte ?', turkish: 'Ne kadar?', english: 'How much is it?', category: 'food'),
    ],
  );

  static const _shopping = PhraseCategory(
    name: 'Shopping',
    emoji: '🛍️',
    phrases: [
      TranslationPhrase(french: 'Combien ça coûte ?', turkish: 'Bu ne kadar?', english: 'How much is this?', category: 'shopping'),
      TranslationPhrase(french: 'C\'est trop cher', turkish: 'Çok pahalı', english: 'It\'s too expensive', category: 'shopping'),
      TranslationPhrase(french: 'Pouvez-vous réduire le prix ?', turkish: 'Fiyatı düşürebilir misiniz?', english: 'Can you reduce the price?', category: 'shopping'),
      TranslationPhrase(french: 'Je peux payer par carte ?', turkish: 'Kartla ödeyebilir miyim?', english: 'Can I pay by card?', category: 'shopping'),
      TranslationPhrase(french: 'Je veux juste regarder', turkish: 'Sadece bakıyorum', english: 'I\'m just looking', category: 'shopping'),
      TranslationPhrase(french: 'Avez-vous une taille plus grande ?', turkish: 'Daha büyük bedeniniz var mı?', english: 'Do you have a larger size?', category: 'shopping'),
      TranslationPhrase(french: 'Je prends ça', turkish: 'Bunu alıyorum', english: 'I\'ll take this', category: 'shopping'),
    ],
  );

  static const _emergency = PhraseCategory(
    name: 'Urgence',
    emoji: '🆘',
    phrases: [
      TranslationPhrase(french: 'Aidez-moi !', turkish: 'Yardım edin!', english: 'Help me!', category: 'emergency'),
      TranslationPhrase(french: 'Appelez une ambulance !', turkish: 'Ambulans çağırın!', english: 'Call an ambulance!', category: 'emergency'),
      TranslationPhrase(french: 'Où est l\'hôpital ?', turkish: 'Hastane nerede?', english: 'Where is the hospital?', category: 'emergency'),
      TranslationPhrase(french: 'J\'ai perdu mon passeport', turkish: 'Pasaportumu kaybettim', english: 'I lost my passport', category: 'emergency'),
      TranslationPhrase(french: 'Police !', turkish: 'Polis!', english: 'Police!', category: 'emergency'),
      TranslationPhrase(french: 'Je suis malade', turkish: 'Hastayım', english: 'I am sick', category: 'emergency'),
      TranslationPhrase(french: 'Pharmacie', turkish: 'Eczane', english: 'Pharmacy', category: 'emergency'),
      TranslationPhrase(french: 'Je ne me sens pas bien', turkish: 'İyi hissetmiyorum', english: 'I don\'t feel well', category: 'emergency'),
    ],
  );

  static const _transport = PhraseCategory(
    name: 'Transport',
    emoji: '🚕',
    phrases: [
      TranslationPhrase(french: 'Où est la station de métro ?', turkish: 'Metro istasyonu nerede?', english: 'Where is the metro station?', category: 'transport'),
      TranslationPhrase(french: 'Ce bus va à... ?', turkish: 'Bu otobüs...e gidiyor mu?', english: 'Does this bus go to...?', category: 'transport'),
      TranslationPhrase(french: 'Combien coûte le billet ?', turkish: 'Bilet ne kadar?', english: 'How much is the ticket?', category: 'transport'),
      TranslationPhrase(french: 'Taxi !', turkish: 'Taksi!', english: 'Taxi!', category: 'transport'),
      TranslationPhrase(french: 'Arrêtez ici, s\'il vous plaît', turkish: 'Burada durun lütfen', english: 'Stop here, please', category: 'transport'),
      TranslationPhrase(french: 'Combien pour aller à... ?', turkish: '...e gitmek ne kadar?', english: 'How much to go to...?', category: 'transport'),
      TranslationPhrase(french: 'Où est l\'arrêt de bus ?', turkish: 'Otobüs durağı nerede?', english: 'Where is the bus stop?', category: 'transport'),
    ],
  );

  static const _accommodation = PhraseCategory(
    name: 'Hébergement',
    emoji: '🏨',
    phrases: [
      TranslationPhrase(french: 'Avez-vous une chambre libre ?', turkish: 'Boş odanız var mı?', english: 'Do you have a free room?', category: 'accommodation'),
      TranslationPhrase(french: 'Combien par nuit ?', turkish: 'Bir gece ne kadar?', english: 'How much per night?', category: 'accommodation'),
      TranslationPhrase(french: 'Je voudrais réserver', turkish: 'Rezervasyon yapmak istiyorum', english: 'I would like to book', category: 'accommodation'),
      TranslationPhrase(french: 'Quelle heure est le petit-déjeuner ?', turkish: 'Kahvaltı saat kaçta?', english: 'What time is breakfast?', category: 'accommodation'),
      TranslationPhrase(french: 'Y a-t-il Wi-Fi ?', turkish: 'Wi-Fi var mı?', english: 'Is there Wi-Fi?', category: 'accommodation'),
      TranslationPhrase(french: 'Je peux voir la chambre ?', turkish: 'Odayı görebilir miyim?', english: 'Can I see the room?', category: 'accommodation'),
    ],
  );

  static const _numbers = PhraseCategory(
    name: 'Nombres',
    emoji: '🔢',
    phrases: [
      TranslationPhrase(french: 'Un', turkish: 'Bir', english: 'One', category: 'numbers'),
      TranslationPhrase(french: 'Deux', turkish: 'İki', english: 'Two', category: 'numbers'),
      TranslationPhrase(french: 'Trois', turkish: 'Üç', english: 'Three', category: 'numbers'),
      TranslationPhrase(french: 'Quatre', turkish: 'Dört', english: 'Four', category: 'numbers'),
      TranslationPhrase(french: 'Cinq', turkish: 'Beş', english: 'Five', category: 'numbers'),
      TranslationPhrase(french: 'Dix', turkish: 'On', english: 'Ten', category: 'numbers'),
      TranslationPhrase(french: 'Cent', turkish: 'Yüz', english: 'Hundred', category: 'numbers'),
      TranslationPhrase(french: 'Mille', turkish: 'Bin', english: 'Thousand', category: 'numbers'),
    ],
  );

  static const _time = PhraseCategory(
    name: 'Temps',
    emoji: '⏰',
    phrases: [
      TranslationPhrase(french: 'Quelle heure est-il ?', turkish: 'Saat kaç?', english: 'What time is it?', category: 'time'),
      TranslationPhrase(french: 'Aujourd\'hui', turkish: 'Bugün', english: 'Today', category: 'time'),
      TranslationPhrase(french: 'Demain', turkish: 'Yarın', english: 'Tomorrow', category: 'time'),
      TranslationPhrase(french: 'Hier', turkish: 'Dün', english: 'Yesterday', category: 'time'),
      TranslationPhrase(french: 'Matin', turkish: 'Sabah', english: 'Morning', category: 'time'),
      TranslationPhrase(french: 'Après-midi', turkish: 'Öğleden sonra', english: 'Afternoon', category: 'time'),
      TranslationPhrase(french: 'Soir', turkish: 'Akşam', english: 'Evening', category: 'time'),
      TranslationPhrase(french: 'Nuit', turkish: 'Gece', english: 'Night', category: 'time'),
    ],
  );

  static const _health = PhraseCategory(
    name: 'Santé',
    emoji: '🏥',
    phrases: [
      TranslationPhrase(french: 'J\'ai mal à la tête', turkish: 'Başım ağrıyor', english: 'I have a headache', category: 'health'),
      TranslationPhrase(french: 'J\'ai de la fièvre', turkish: 'Ateşim var', english: 'I have a fever', category: 'health'),
      TranslationPhrase(french: 'Allergie', turkish: 'Alerji', english: 'Allergy', category: 'health'),
      TranslationPhrase(french: 'Médicament', turkish: 'İlaç', english: 'Medicine', category: 'health'),
      TranslationPhrase(french: 'Dentiste', turkish: 'Dişçi', english: 'Dentist', category: 'health'),
      TranslationPhrase(french: 'Médecin', turkish: 'Doktor', english: 'Doctor', category: 'health'),
    ],
  );

  static String translate(String text, {required String from, required String to}) {
    final lower = text.toLowerCase().trim();
    for (final cat in all) {
      for (final phrase in cat.phrases) {
        if (from == 'fr' && phrase.french.toLowerCase() == lower) {
          return to == 'tr' ? phrase.turkish : (phrase.english ?? phrase.french);
        }
        if (from == 'tr' && phrase.turkish.toLowerCase() == lower) {
          return to == 'fr' ? phrase.french : (phrase.english ?? phrase.turkish);
        }
        if (from == 'en' && phrase.english?.toLowerCase() == lower) {
          return to == 'fr' ? phrase.french : phrase.turkish;
        }
      }
    }
    return '';
  }
}
