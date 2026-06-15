import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TranslationService extends ChangeNotifier {
  static const String _cacheKey = 'translations_cache';
  
  final FlutterTts _flutterTts = FlutterTts();
  Map<String, String> _cache = {};
  bool _isOffline = false;

  static final List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'nativeName': 'Français'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
  ];

  static final Map<String, Map<String, String>> commonPhrases = {
    'fr': {
      // Greetings - Salutations
      'Bonjour': 'Merhaba',
      'Bonsoir': 'İyi akşamlar',
      'Au revoir': 'Hoşçakal',
      'Salut': 'Selam',
      'Comment allez-vous?': 'Nasılsınız?',
      'Je vais bien': 'İyiyim, teşekkürler',
      'Enchanté': 'Memnun oldum',
      'Bonne nuit': 'İyi geceler',
      'À bientôt': 'Görüşürüz',
      'Comment ça va?': 'Nasıl gidiyor?',
      
      // Essential - Essentiel
      'Merci': 'Teşekkür ederim',
      'Merci beaucoup': 'Çok teşekkürler',
      'S\'il vous plaît': 'Lütfen',
      'Excusez-moi': 'Affedersiniz',
      'Pardon': 'Pardon',
      'Oui': 'Evet',
      'Non': 'Hayır',
      'Je ne comprends pas': 'Anlamıyorum',
      'Je comprends': 'Anlıyorum',
      'Parlez-vous français?': 'Fransızca biliyor musunuz?',
      'Je ne parle pas turc': 'Türkçe konuşamıyorum',
      'Aide': 'Yardım',
      'Au secours!': 'Yardım!',
      'Attention': 'Dikkat',
      'Danger': 'Tehlike',
      'Je ne sais pas': 'Bilmiyorum',
      'D\'accord': 'Tamam',
      'Peut-être': 'Belki',
      'Aujourd\'hui': 'Bugün',
      'Demain': 'Yarın',
      'Hier': 'Dün',
      
      // Directions - Directions
      'Où est...?': '... nerede?',
      'À gauche': 'Sol',
      'À droite': 'Sağ',
      'Tout droit': 'Düz',
      'Loin': 'Uzak',
      'Près': 'Yakın',
      'ICI': 'Burada',
      'Là-bas': 'Şurada',
      'Carte': 'Harita',
      'Rue': 'Sokak',
      'Place': 'Meydan',
      
      // Transport - Transport
      'L\'addition': 'Hesap lütfen',
      'Combien ça coûte?': 'Ne kadar?',
      'Bathroom': 'Tuvalet',
      'Hotel': 'Otel',
      'Restaurant': 'Restoran',
      'Aéroport': 'Havalimanı',
      'Gare': 'İstasyon',
      'Bus': 'Otobüs',
      'Taxi': 'Taksi',
      'Train': 'Tren',
      'Métro': 'Metro',
      'Bateau': 'Vapur',
      'Voiture': 'Araba',
      'Avion': 'Uçak',
      'Billets': 'Bilet',
      'Prix': 'Fiyat',
      'Pas cher': 'Ucuz',
      'Cher': 'Pahalı',
      'Gratuit': 'Ücretsiz',
      'Fermé': 'Kapalı',
      'Ouvert': 'Açık',
      
      // Hotel
      'Chambre': 'Oda',
      'Clé': 'Anahtar',
      'Réception': 'Resepsiyon',
      'Bagages': 'Bagaj',
      'Ascenseur': 'Asansör',
      'Escalier': 'Merdiven',
      'WiFi': 'WiFi',
      'Climatisation': 'Klima',
      'Eau chaude': 'Sıcak su',
      'Serviettes': 'Havlu',
      'Coffre-fort': 'Kasa',
      
      // Restaurant
      'Menu': 'Menü',
      'L\'addition': 'Hesap',
      'Eau': 'Su',
      'Café': 'Kahve',
      'Thé': 'Çay',
      'Vin': 'Şarap',
      'Bière': 'Bira',
      'Pain': 'Ekmek',
      'Poisson': 'Balık',
      'Viande': 'Et',
      'Légumes': 'Sebze',
      'Fruits': 'Meyve',
      'Dessert': 'Tatlı',
      'Petit-déjeuner': 'Kahvaltı',
      'Déjeuner': 'Öğle yemeği',
      'Dîner': 'Akşam yemeği',
      'Je suis végétarien': 'Vejetaryenim',
      'Allergique': 'Alerjik',
      
      // Shopping
      'Magasin': 'Dükkan',
      'Marché': 'Pazar',
      'Prix': 'Fiyat',
      'Soldes': 'İndirim',
      'Acheté': 'Satın aldım',
      'Trop cher': 'Çok pahalı',
      'Plus cher': 'Daha pahalı',
      'Moins cher': 'Daha ucuz',
      'Payer': 'Ödeme',
      'Espèces': 'Nakit',
      'Carte': 'Kart',
      'Receipt': 'Fiş',
      'Taille': 'Beden',
      'Couleur': 'Renk',
      
      // Emergency
      'Le médecin': 'Doktor',
      'Pharmacie': 'Eczane',
      'Hôpital': 'Hastane',
      'Police': 'Polis',
      'Urgence': 'Acil',
      'Ambulance': 'Ambulans',
      'Pompiers': 'İtfaiye',
      'J\'ai besoin d\'aide': 'Yardıma ihtiyacım var',
      'Je suis perdu': 'Kayboldum',
      'Je suis malade': 'Hastayım',
      'Mal à la tête': 'Baş ağrısı',
      'Mal au ventre': 'Karın ağrısı',
      'Fièvre': 'Ateş',
      'Coupure': 'Kesik',
      
      // Time
      'Quelle heure est-il?': 'Saat kaç?',
      'Matin': 'Sabah',
      'Après-midi': 'Öğleden sonra',
      'Soir': 'Akşam',
      'Minute': 'Dakika',
      'Heure': 'Saat',
      'Jour': 'Gün',
      'Semaine': 'Hafta',
      'Mois': 'Ay',
      'Année': 'Yıl',
      
      // Numbers
      'Un': 'Bir',
      'Deux': 'İki',
      'Trois': 'Üç',
      'Quatre': 'Dört',
      'Cinq': 'Beş',
      'Six': 'Altı',
      'Sept': 'Yedi',
      'Huit': 'Sekiz',
      'Neuf': 'Dokuz',
      'Dix': 'On',
      'Vingt': 'Yirmi',
      'Trente': 'Otuz',
      'Cent': 'Yüz',
      'Mille': 'Bin',
      
      // Weather
      'Il fait beau': 'Hava güzel',
      'Il fait chaud': 'Hava sıcak',
      'Il fait froid': 'Hava soğuk',
      'Il pleut': 'Yağmur yağıyor',
      'Il neige': 'Kar yağıyor',
      'Le soleil': 'Güneş',
      'La lune': 'Ay',
      'Le vent': 'Rüzgar',
      'Nuage': 'Bulut',
      
      // Activities
      'Plage': 'Plaj',
      'Mer': 'Deniz',
      'Piscine': 'Havuz',
      'Musée': 'Müze',
      'Plaza': 'Saray',
      'Mosquée': 'Cami',
      'Église': 'Kilise',
      'Monument': 'Anıt',
      'Plaine': 'Park',
      'Randonnée': 'Yürüyüş',
      'Baignade': 'Yüzme',
      'Excursion': 'Gezi',
      
      // Beach
      'Plage': 'Plaj',
      'Sable': 'Kum',
      'Parasol': 'Şemsiye',
      'Serviette': 'Havlu',
      'Crème solaire': 'Güneş kremi',
      'Nager': 'Yüzmek',
      'Soleil': 'Güneş',
      'Marée': 'Gel-git',
      
      // Food
      'Kebab': 'Kebab',
      'Lahmacun': 'Lahmacun',
      'Pide': 'Pide',
      'Simit': 'Simit',
      'Baklava': 'Baklava',
      'Lokum': 'Lokum',
      'Döner': 'Döner',
      'Köfte': 'Köfte',
      'Mantı': 'Mantı',
      'Meze': 'Meze',
      'Ayran': 'Ayran',
      'Şeker': 'Şeker',
      
      // Health
      'Docteur': 'Doktor',
      'Hôpital': 'Hastane',
      'Pharmacie': 'Eczane',
      'Ordonnance': 'Reçete',
      'Vaccin': 'Aşı',
      'Allergie': 'Alerji',
      'Diabète': 'Şeker hastalığı',
      'Coeur': 'Kalp',
      'Pression': 'Tansiyon',
      
      // Customs
      'Bagages': 'Bagaj',
      'Passeport': 'Pasaport',
      'Visa': 'Vize',
      'Douane': 'Gümrük',
      'Déclarer': 'Bildirmek',
      'Rien à déclarer': 'Bildirecek bir şey yok',
      'Touriste': 'Turist',
      'Résident': 'Sakin',
    },
    'en': {
      'Hello': 'Merhaba',
      'Thank you': 'Teşekkür ederim',
      'Yes': 'Evet',
      'No': 'Hayır',
      'Help': 'Yardım',
      'Please': 'Lütfen',
      'Excuse me': 'Affedersiniz',
      'I don\'t understand': 'Anlamıyorum',
      'Where is...': '... nerede?',
      'The bill please': 'Hesap lütfen',
      'How much?': 'Ne kadar?',
      'Bathroom': 'Tuvalet',
      'Hotel': 'Otel',
      'Restaurant': 'Restoran',
      'Airport': 'Havalimanı',
      'Station': 'İstasyon',
      'Bus': 'Otobüs',
      'Taxi': 'Taksi',
      'Good morning': 'Günaydın',
      'Good evening': 'İyi akşamlar',
      'Goodbye': 'Hoşçakal',
      'How are you?': 'Nasılsınız?',
      'My name is...': 'My name is...',
      'Sorry': 'Özür dilerim',
      'I am lost': 'Kayboldum',
      'I need help': 'Yardıma ihtiyacım var',
      'Doctor': 'Doktor',
      'Pharmacy': 'Eczane',
      'Hospital': 'Hastane',
      'Police': 'Polis',
      'Emergency': 'Acil',
      'Water': 'Su',
      'Food': 'Yemek',
      'Hotels': 'Oteller',
      'Price': 'Fiyat',
      'Cheap': 'Ucuz',
      'Expensive': 'Pahalı',
      'Closed': 'Kapalı',
      'Open': 'Açık',
      
      // Additional phrases
      'Good morning': 'Günaydın',
      'See you later': 'Görüşürüz',
      'I am happy': 'Mutluyum',
      'I am tired': 'Yorgunum',
      'I am hungry': 'Açım',
      'I am thirsty': 'Susadım',
      'I am cold': 'Üşüdüm',
      'I am hot': 'Terledim',
      'Where is the bathroom?': 'Tuvalet nerede?',
      'Where is the hospital?': 'Hastane nerede?',
      'Where is the pharmacy?': 'Eczane nerede?',
      'Where is the police?': 'Polis nerede?',
      'Can you help me?': 'Bana yardım edebilir misiniz?',
      'I need a doctor': 'Doktora ihtiyacım var',
      'Call an ambulance': 'Ambulans çağırın',
      'I have been robbed': 'Soyuldum',
      'My passport was stolen': 'Pasaportum çalındı',
      'Where is the Turkish embassy?': 'Türkiye büyükelçiliği nerede?',
      'I want to go to the hotel': 'Otele gitmek istiyorum',
      'How do I get to the airport?': 'Havalimanına nasıl giderim?',
      'How much is a taxi to...?': '...e taksi ne kadar?',
      'Is there a bus to...?': '...e otobüs var mı?',
      'One ticket please': 'Bir bilet lütfen',
      'Return ticket': 'Gidiş dönüş bilet',
      'Single ticket': 'Tek yön bilet',
      'What time does it leave?': 'Saat kaçta kalkıyor?',
      'What time does it arrive?': 'Saat kaçta varıyor?',
      'I want to rent a car': 'Araba kiralamak istiyorum',
      'Where can I rent a car?': 'Nerede araba kiralayabilirim?',
      'I have a reservation': 'Rezervasyonum var',
      'Do you have a room available?': 'Boş odanız var mı?',
      'How much per night?': 'Gece ne kadar?',
      'Is breakfast included?': 'Kahvaltı dahil mi?',
      'What time is breakfast?': 'Kahvaltı saat kaçta?',
      'Can I see the room first?': 'Odayı önce görebilir miyim?',
      'The room is nice': 'Oda güzel',
      'I need a single room': 'Tek kişilik oda istiyorum',
      'I need a double room': 'Çift kişilik oda istiyorum',
      'Do you accept credit cards?': 'Kredi kartı kabul ediyor musunuz?',
      'Can I pay in cash?': 'Nakit ödeyebilir miyim?',
      'Do you have WiFi?': 'WiFi var mı?',
      'What is the WiFi password?': 'WiFi şifresi nedir?',
      'The air conditioning does not work': 'Klima çalışmıyor',
      'I need a towel': 'Havluya ihtiyacım var',
      'Can I have more soap?': 'Daha fazla sabun alabilir miyim?',
      'Room service': 'Oda servisi',
      'Wake up call please': 'Uyandırma servisi lütfen',
      'What is your name?': 'Adınız ne?',
      'My name is...': 'Adım...',
      'Where are you from?': 'Nerelisiniz?',
      'I am from...': '...den geliyorum',
      'Are you married?': 'Evli misiniz?',
      'Do you have children?': 'Çocuğunuz var mı?',
      'How old are you?': 'Kaç yaşındasın?',
      'I am ... years old': '... yaşındayım',
      'It is beautiful': 'Çok güzel',
      'I love Turkey': 'Türkiye\'yi seviyorum',
      'This is my first time here': 'Bu benim ilk burada oluşum',
      'I came here for vacation': 'Tatil için geldim',
      'I am here for business': 'İş için buradayım',
      'How long will you stay?': 'Ne kadar kalacaksınız?',
      'I will stay for ... days': '... gün kalacağım',
      'Can I take a photo?': 'Fotoğraf çekebilir miyim?',
      'Please do not take photos': 'Lütfen fotoğraf çekmeyin',
      'Is it allowed?': 'İzin var mı?',
      'I am sorry': 'Özür dilerim',
      'No problem': 'Problem yok',
      'It does not matter': 'Önemli değil',
      'Really?': 'Gerçekten mi?',
      'That is interesting': 'İlginç',
      'I do not know': 'Bilmiyorum',
      'Maybe later': 'Belki sonra',
      'Now': 'Şimdi',
      'Later': 'Sonra',
      'Before': 'Önce',
      'After': 'Sonra',
      'Again': 'Tekrar',
      'More': 'Daha fazla',
      'Less': 'Daha az',
      'A little': 'Biraz',
      'A lot': 'Çok',
      'Very': 'Çok',
      'Not very': 'Çok değil',
      'Enough': 'Yeterli',
      'Delicious': 'Lezzetli',
      'Not bad': 'Fena değil',
      'Bad': 'Kötü',
      'Good': 'İyi',
      'Excellent': 'Mükemmel',
      'I am full': 'Doydum',
      'The food was great': 'Yemek harika idi',
      'Can I have the menu?': 'Menüyü alabilir miyim?',
      'What do you recommend?': 'Ne önerirsiniz?',
      'I would like...': '...istiyorum',
      'Water please': 'Su lütfen',
      'Coffee please': 'Kahve lütfen',
      'Tea please': 'Çay lütfen',
      'Ice please': 'Buz lütfen',
      'Lemon please': 'Limon lütfen',
      'Sugar please': 'Şeker lütfen',
      'No sugar please': 'Şekersiz lütfen',
      'With milk': 'Sütlü',
      'Without milk': 'Sütsüz',
      'Is it spicy?': 'Baharatlı mı?',
      'I am vegetarian': 'Vejetaryenim',
      'I am vegan': 'Veganım',
      'I cannot eat...': '...yiyemiyorum',
      'I am allergic to...': '...e alerjim var',
      'No nuts please': 'Lütfen fıstık yok',
      'No gluten please': 'Lütfen glüten yok',
      'Halal': 'Helal',
      'Kosher': 'Koşer',
      'Is this halal?': 'Bu helal mi?',
      'The check please': 'Hesap lütfen',
      'Is service included?': 'Servis dahil mi?',
      'Tip': 'Bahşiş',
      'Keep the change': 'Üstü kalsın',
      'This is too much': 'Bu çok fazla',
      'I think there is a mistake': 'Sanırım bir hata var',
      'Can I pay by card?': 'Kartla ödeyebilir miyim?',
      'I will pay cash': 'Nakit ödeyeceğim',
      'Do you have smaller change?': 'Üstü daha küçük var mı?',
      'I need to exchange money': 'Para bozdurmam lazım',
      'Where is the bank?': 'Banka nerede?',
      'Where is the ATM?': 'Bankamatik nerede?',
      'What is the exchange rate?': 'Kur nedir?',
      'I want to exchange euros': 'Euro bozdurmak istiyorum',
      'I want to exchange dollars': 'Dolar bozdurmak istiyorum',
      'Where is the market?': 'Pazar nerede?',
      'Is it far from here?': 'Buradan uzak mı?',
      'Is it near here?': 'Buraya yakın mı?',
      'How far is it?': 'Ne kadar uzak?',
      'Can I walk there?': 'Yürüyerek gidebilir miyim?',
      'Do I need a taxi?': 'Taksiye ihtiyacım var mı?',
      'Please call a taxi': 'Lütfen taksi çağırın',
      'Wait here please': 'Lütfen burada bekleyin',
      'Stop here please': 'Lütfen burada durun',
      'Turn left': 'Sola dön',
      'Turn right': 'Sağa dön',
      'Go straight': 'Düz git',
      'At the traffic light': 'Trafic ışığında',
      'At the corner': 'Köşede',
      'Near the mosque': 'Cami yakınında',
      'Near the church': 'Kilise yakınında',
      'What is this?': 'Bu ne?',
      'How much is this?': 'Bu ne kadar?',
      'Too expensive': 'Çok pahalı',
      'Can you give a discount?': 'İndirim yapabilir misiniz?',
      'I will take it': 'Alıyorum',
      'I am just looking': 'Sadece bakıyorum',
      'Do you have a smaller size?': 'Daha küçük beden var mı?',
      'Do you have a larger size?': 'Daha büyük beden var mı?',
      'Can I try this on?': 'Bunu deneyebilir miyim?',
      'Where is the fitting room?': 'Prova odası nerede?',
      'This fits well': 'Bu tam size uyuyor',
      'This does not fit': 'Bu uymuyor',
      'Do you have this in another color?': 'Bu başka renkte var mı?',
      'Do you have this in another size?': 'Bu başka bedende var mı?',
      'I will come back tomorrow': 'Yarın geri geleceğim',
      'Is there a problem?': 'Problem var mı?',
      'I want to speak to the manager': 'Müdürle konuşmak istiyorum',
      'This is not what I wanted': 'Bu istediğim şey değil',
      'Can I return this?': 'Bunu iade edebilir miyim?',
      'Can I exchange this?': 'Bunu değiştirebilir miyim?',
      'I would like a receipt': 'Fiş istiyorum',
      'Do you have a bag?': 'Torba var mı?',
      'Thank you very much': 'Çok teşekkür ederim',
      'You are welcome': 'Rica ederim',
      'No thank you': 'Hayır teşekkürler',
      'Yes please': 'Evet lütfen',
    },
  };

  TranslationService() {
    _initTts();
    _loadCache();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('tr-TR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      _cache = Map<String, String>.from(json.decode(cached));
    }
    _isOffline = prefs.getBool('offline_mode') ?? false;
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(_cache));
  }

  String _getLanguageCode(String lang) {
    final codes = {
      'fr': 'fr',
      'en': 'en',
      'tr': 'tr',
      'es': 'es',
      'de': 'de',
      'it': 'it',
      'ar': 'ar',
      'ru': 'ru',
    };
    return codes[lang] ?? 'en';
  }

  Future<String> translate(String text, String fromLang, String toLang) async {
    if (text.trim().isEmpty) return '';
    
    final cacheKey = '${text.toLowerCase().trim()}_${fromLang}_$toLang';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final normalizedFrom = fromLang.toLowerCase();
    final normalizedTo = toLang.toLowerCase();

    if (commonPhrases.containsKey(normalizedFrom)) {
      final phrases = commonPhrases[normalizedFrom]!;
      for (final entry in phrases.entries) {
        if (entry.key.toLowerCase() == text.toLowerCase().trim()) {
          return entry.value;
        }
      }
    }

    if (_isOffline) {
      return text;
    }

    try {
      final fromCode = _getLanguageCode(normalizedFrom);
      final toCode = _getLanguageCode(normalizedTo);
      
      final response = await http.get(
        Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$fromCode|$toCode'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseStatus'] == 200 && data['responseData'] != null) {
          final translated = data['responseData']['translatedText'] as String;
          _cache[cacheKey] = translated;
          await _saveCache();
          return translated;
        }
      }
    } catch (e) {
      _isOffline = true;
    }

    try {
      final fromCode = _getLanguageCode(normalizedFrom);
      final toCode = _getLanguageCode(normalizedTo);
      
      final response = await http.get(
        Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$fromCode&tl=$toCode&dt=t&q=${Uri.encodeComponent(text)}'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[0] != null && data[0].isNotEmpty) {
          final translated = data[0][0][0] as String;
          _cache[cacheKey] = translated;
          await _saveCache();
          return translated;
        }
      }
    } catch (e) {
      _isOffline = true;
    }

    return text;
  }

  Future<void> speak(String text, String languageCode) async {
    final langMap = {
      'fr': 'fr-FR',
      'en': 'en-US',
      'tr': 'tr-TR',
      'es': 'es-ES',
      'de': 'de-DE',
      'it': 'it-IT',
      'ar': 'ar-SA',
      'ru': 'ru-RU',
    };
    
    await _flutterTts.setLanguage(langMap[languageCode] ?? 'tr-TR');
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  bool get isOffline => _isOffline;

  Map<String, String> getCommonPhrases(String languageCode) {
    final lang = languageCode.toLowerCase();
    if (commonPhrases.containsKey(lang)) {
      return commonPhrases[lang]!;
    }
    return commonPhrases['fr']!;
  }

  List<Map<String, String>> getAvailableLanguages() {
    return supportedLanguages;
  }

  Future<void> downloadLanguagePack(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedLanguages = prefs.getStringList('downloaded_languages') ?? [];
    if (!downloadedLanguages.contains(languageCode)) {
      downloadedLanguages.add(languageCode);
      await prefs.setStringList('downloaded_languages', downloadedLanguages);
    }
  }

  Future<bool> isLanguageDownloaded(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedLanguages = prefs.getStringList('downloaded_languages') ?? [];
    return downloadedLanguages.contains(languageCode);
  }

  Future<void> clearCache() async {
    _cache.clear();
    await _saveCache();
  }
}