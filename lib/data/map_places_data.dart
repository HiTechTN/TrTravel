import 'package:latlong2/latlong.dart';
import '../models/map_place.dart';

class MapPlacesData {
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
      name: 'Palais de Topkapi', nameTr: 'Topkapı Sarayı', description: 'Résidence principale des sultans ottomans pendant 400 ans. Abrita l\'un des plus riches trésors impériaux avec des bijoux, des armes et des reliques.',
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
      name: 'Palais Dolmabahçe', nameTr: 'Dolmabahçe Sarayı', description: 'Résidence officielle des sultans ottomans après Topkapi. Le plus grand palais de Turquie avec 285 pièces et un lustre en cristal de Bohême de 4,5 tonnes.',
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
}
