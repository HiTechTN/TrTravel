import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class TravelWikisScreen extends StatefulWidget {
  const TravelWikisScreen({super.key});

  @override
  State<TravelWikisScreen> createState() => _TravelWikisScreenState();
}

class _TravelWikisScreenState extends State<TravelWikisScreen> {
  String _selectedCity = 'Istanbul';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wiki Voyage',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Encyclopédie complète de voyage',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCityFilter(),
                  const SizedBox(height: 16),
                  _buildWikiSection('Histoire & Culture', Icons.history_edu, const Color(0xFF5D4037), _getHistoryWikis()),
                  const SizedBox(height: 16),
                  _buildWikiSection('Gastronomie', Icons.restaurant, const Color(0xFFE65100), _getFoodWikis()),
                  const SizedBox(height: 16),
                  _buildWikiSection('Lieux à Visiter', Icons.place, const Color(0xFF1565C0), _getPlacesWikis()),
                  const SizedBox(height: 16),
                  _buildWikiSection('Activités', Icons.sports, const Color(0xFF7B1FA2), _getActivitiesWikis()),
                  const SizedBox(height: 16),
                  _buildWikiSection('Conseils Pratiques', Icons.lightbulb, const Color(0xFF00838F), _getTipsWikis()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _cityTab('Istanbul', '🏛️'),
          ),
          Expanded(
            child: _cityTab('Antalya', '🏖️'),
          ),
        ],
      ),
    );
  }

  Widget _cityTab(String city, String emoji) {
    final isSelected = _selectedCity == city;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCity = city);
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              city,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWikiSection(String title, IconData icon, Color color, List<WikiItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
          ...items.map((item) => _wikiItem(item, color)),
        ],
      ),
    );
  }

  Widget _wikiItem(WikiItem item, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WikiDetailScreen(item: item, color: color),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.price != null || item.hours != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (item.price != null)
                    _wikiTag(Icons.monetization_on, item.price!, color),
                  if (item.hours != null)
                    _wikiTag(Icons.access_time, item.hours!, color),
                  if (item.phone != null)
                    _wikiTag(Icons.phone, item.phone!, color),
                ],
              ),
            ],
            if (item.bookingUrl != null || item.website != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (item.bookingUrl != null)
                    _wikiActionButton('R\u00E9server', Icons.confirmation_number, color, item.bookingUrl!),
                  if (item.website != null)
                    _wikiActionButton('Site web', Icons.language, color, item.website!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _wikiTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _wikiActionButton(String label, IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  List<WikiItem> _getHistoryWikis() {
    if (_selectedCity == 'Istanbul') {
      return [
        WikiItem(
          icon: '🏛️',
          title: 'Histoire de Constantinople',
          subtitle: 'De Byzance à Istanbul, 2700 ans d\'histoire',
          content: '''
# Constantinople: Capitale du Monde

## Les Origines (667 av. J.-C.)
La ville fut fondée sous le nom de Byzance par des colons grecs de Mégare en 667 av. J.-C. Sa position stratégique sur le Bosphore en fit rapidement une ville importante.

## L'Ère Byzantine (330-1453)
En 330 apr. J.-C., l'empereur Constantin fonde Constantinople et en fait la capitale de l'Empire romain d'Orient. La ville devient le centre du christianisme orthodoxe et l'une des plus grandes villes du monde médiéval.

### Principaux monuments de l'époque:
- **Sainte-Sophie** (537): Chef-d'œuvre de l'architecture byzantine
- **Les murailles de Théodose**: Les plus grandes fortifications médiévales
- **Palais des Blachernes**: Résidence impériale

## La Conquête Ottomane (1453)
Le 29 mai 1453, le sultan Mehmed II conquiert Constantinople après un siège de 53 jours. La ville devient la capitale de l'Empire ottoman et prend le nom d'Istanbul.

### Impact de la conquête:
- Fin de l'Empire byzantin
- Transformation des églises en mosquées
- Début de l'ère ottomane à Istanbul
          ''',
        ),
        WikiItem(
          icon: '🕌',
          title: 'L\'Empire Ottoman à Istanbul',
          subtitle: '500 ans de splendeur ottomane',
          content: '''
# L'Empire Ottoman à Istanbul

## L'Âge d'Or (XVIe siècle)
Sous les sultans Soliman le Magnifique (1520-1566), Istanbul devient l'une des plus belles et puissantes villes du monde.

### Architecture Ottomane
- **Mosquée Süleymaniye**: Chef-d'œuvre de Sinan
- **Palais Topkapi**: Centre du pouvoir pendant 400 ans
- **Bazaars**: Grand Bazar, plus grand marché couvert

## Déclin et Modernisation (XIXe-XXe siècles)
La Tanzimat (réformes) modernise la ville:
- Construction de bâtiments néoclassiques
- Création de nouveaux quartiers (Beyoğlu)
- Chemins de fer et industrialisation
          ''',
        ),
        WikiItem(
          icon: '⚓',
          title: 'Le Bosphore à Travers les Âges',
          subtitle: 'Un détroit stratégique depuis l\'Antiquité',
          content: '''
# Le Bosphore: Carrefour des Civilisations

## Importance Historique
Le Bosphore a toujours été un point de passage crucial entre l'Europe et l'Asie. Les Grecs, les Romains, les Byzantins et les Ottomans ont tous contrôlé ce détroit stratégique.

## Les Palais du Bosphore
- **Palais de Dolmabahçe**: Splendeur ottomane du XIXe
- **Palais de Beylerbeyi**: Résidence d'été des sultans
- **Palais de Çırağan**: Aujourd'hui hôtel de luxe
          ''',
        ),
      ];
    } else {
      return [
        WikiItem(
          icon: '🏛️',
          title: 'Histoire d\'Antalya',
          subtitle: 'De l\'Antiquité à la modernisation',
          content: '''
# Antalya: Perle de la Méditerranée

## L'Antiquité (150 av. J.-C.)
Fondée par les Attalides en 150 av. J.-C., la ville fut nommée Attaleia en l'honneur du roi Attalos II. Elle devint un port important de l'Empire romain.

## Période Byzantine
Après la chute de Rome, Antalya devint un évêché important et un centre de pèlerinage vers les lieux saints.

## L'Époque Ottomane
 conquise par les Ottomans au XIVe siècle, la ville prospéra comme port commercial et base navale.

## Antalya Moderne
Aujourd'hui, Antalya est l'une des destinations touristiques les plus populaires de Méditerranée avec plus de 15 millions de visiteurs par an.
          ''',
        ),
        WikiItem(
          icon: '🗿',
          title: 'Ruines Antiques de la Région',
          subtitle: 'Un musée à ciel ouvert',
          content: '''
# Sites Archéologiques d'Antalya

## Aspendos
- Théâtre romain parfaitement conservé (IIe siècle)
- Capacité: 15 000 spectateurs
-仍 utilisé pour des concerts et opéras

## Perge
- Stade grec et romain
- Portiques et colonnes impressionnants
- Théâtre de la période hellénistique

## Side
- Temple d'Athéna
- Théâtre romain
- Bains romains transformés en musée

## Termessos
- Cité perchée dans les montagnes
- Théâtre grec alpin le plus haut de Méditerranée
- Tombe royale imminente
          ''',
        ),
        WikiItem(
          icon: '👑',
          title: 'Les Sulaymanides',
          subtitle: 'Dynastie turkmène de la région',
          content: '''
# Les Sulaymanides d'Antalya

## Origines
La dynastie sulaymanide fut fondée par des chefs turkmènes au начале du XIVe siècle. Ils contrôlèrent la région d'Antalya et développèrent une culture florissante.

## Contribution architecturale
- Mosquées et madrasas dans Kaleici
- Bâtiments karavan-sérails
- Ponts et infrastructures
          ''',
        ),
      ];
    }
  }

  List<WikiItem> _getFoodWikis() {
    if (_selectedCity == 'Istanbul') {
      return [
        WikiItem(
          icon: '🥙',
          title: 'La Cuisine Istanbouliote',
          subtitle: 'Un mélange de traditions',
          content: '''
# Gastronomie d'Istanbul

## Spécialités Incontournables

### Pide
Painplat turc garni de viande, fromage ou légumes. Le pide karaman (au fromage kaşar) est particulièrement délicieux.

### Simit
Bread en forme d'anneau, parsemé de sésame. On le trouve partout dans les rues.

### Lokum (Turkish Delight)
Confiseries traditionnelles aux saveurs diverses (rose, pistache, noix).

### Baklava
Feuilles de pâte garnies de pistaches et de miel. Idéal avec un thé turc.

## Marchés à Découvrir
- **Grand Bazar**: Épices, noix, douceurs
- **Marché aux Épices (Mısır Çarşısı)**: Épices colorées
- **Balık Pazarı**: Poisson frais et fruits de mer
          ''',
        ),
        WikiItem(
          icon: '☕',
          title: 'Le Thé Turc',
          subtitle: 'Une tradition millénaire',
          content: '''
# Le Çay: Thé Turc

## Présentation
Le thé turc est préparé avec deux-thé noir et servi dans de petits verres en forme de tulipe. C'est la boissons la plus consommée en Turquie.

## Où le boire?
- **Çay bahçesi**: Jardins de thé traditionnels
- **Kahvehane**: Café turc historique
- En traversant le Bosphore en bateau

## Accompagnement
Le thé est souvent accompagné de:
- Lokum (douceurs)
- Poudre deengel (gelée de groseille)
- Fruits secs
          ''',
        ),
        WikiItem(
          icon: '🥘',
          title: 'Mekanlar: Les Restaurants Locaux',
          subtitle: 'Où manger comme un local',
          price: 'Lokanta: 100-200 TL; Meyhane: 200-500 TL',
          hours: 'Restaurants: 11:00 - 23:00 (selon établissement)',
          bookingUrl: 'https://www.tripadvisor.fr/Restaurants-g293974-Istanbul.html',
          content: '''
# Mekan: Les Meilleurs Restaurants d\'Istanbul

## Restaurants Recommandés

### Hamdi Restaurant (Eminönü)
Spécialités de kebabs avec vue sur la Corne d\'Or.
📍 Rıhtım Cd., Eminönü | 🕐 11:00 - 23:00
📞 +90 212 528 03 90
Lien: https://www.hamdirestaurant.com

### Çiya Sofrası (Kadıköy)
Cuisine anatolienne authentique. L\'un des meilleurs restaurants d\'Istanbul.
📍 Caferağa Mh., Kadıköy | 🕐 11:00 - 22:00
📞 +90 216 418 51 51
Lien: https://www.ciya.com.tr

### Karaköy Lokantası (Karaköy)
Cuisine turque moderne dans un cadre branché.
📍 Kemankeş Cd., Karaköy | 🕐 12:00 - 23:00
📞 +90 212 243 52 22
Lien: https://www.karakoylokantasi.com

### Pandeli (Éminönü - Marché aux Épices)
Cuisine turque classique dans un cadre historique (depuis 1901).
📍 Mısır Çarşısı, Eminönü | 🕐 12:00 - 17:00
📞 +90 212 522 55 34

### Balıkçı Sabahattin (Sultanahmet)
Poisson et fruits de mer de première qualité.
📍 Seyit Hasan Koyu Sk., Sultanahmet | 🕐 12:00 - 23:00
📞 +90 212 458 18 24

## Types de Restaurants

### Lokanta
Restaurants familiaux servant des plats traditionnels. Prix démocratiques (100-200 TL).

### Meyhane
Restaurant offrant également des animations (musique, danse). Idéal pour le rakı (200-500 TL).

### Kebapçı
Spécialisé dans les kebabs. Le durum (wrap) est très populaire (80-150 TL).

## Réservation
- Recommandé pour les restaurants populaires
- Utiliser les sites web des restaurants
- Ou via votre hôtel
          ''',
        ),
      ];
    } else {
      return [
        WikiItem(
          icon: '🐟',
          title: 'Spécialités d\'Antalya',
          subtitle: 'Saveurs méditerranéennes',
          content: '''
# Gastronomie d'Antalya

## Fruits de Mer
En raison de sa position côtière, Antalya propose d'excellents poissons et fruits de mer:
- **Levrek**: Bar grillé
- **Çupra**: Dorade
- **Kefal**: Muge
- **Karpuz**: Pastèque locale très sucrée

## Cuisine Locale

### Tantuni
Spécialité de la région: viande hachée revenus dans une pâte spéciale, servie dans un pain lavash.

### Gözleme
Pâtes farcies (fromage, épinards, pomme de terre) cuites sur plaque métallique.

### Piyaz
Salade de haricots blancs avec sauce tahini.

## Accompagnement
- Pain frit turc (sac ekmek)
- Yaourt local
- Herbes sauvages méditerranéennes
          ''',
        ),
        WikiItem(
          icon: '🍦',
          title: 'Dondurma: Glace Turque',
          subtitle: 'La incontourn able',
          content: '''
# Dondurma: Glace Turque

## Particularités
La glace turque est plus dense et élastique que les glaces occidentales grâce à la présence de salep (farine d'orchidée).

## Où en trouver?
- **Bezirgan**: Glacier historique à Kaleici
- Marchands dans la vieille ville
- Sur la promenade Lara

## Saveurs traditionnelles
- Vanille (en çok)
- Pistache (ante)
- Fraise (çilek)
- Citron (limon)
          ''',
        ),
        WikiItem(
          icon: '🍇',
          title: 'Vins de la Région',
          subtitle: 'Vignobles de la Côte Turquoise',
          content: '''
# Vins d'Antalya

## Régions Viticoles
La région d'Antalya produit des vins de qualité:
- **Kemer**: Vignobles de montagne
- **Kumluca**: Vins rouges corsés
- **Elmalı**: Vins blancs rafraîchissants

## Cépages
- **Öküzgözü**: Rouge puissant
- **Boğazkere**: Rouge tannique
- **Narince**: Blanc aromatique
- **Emir**: Blanc sec

## Dégustation
De nombreuses caves proposent des dégustations. La route des vins d'Antalya est en développement touristique.
          ''',
        ),
      ];
    }
  }

  List<WikiItem> _getPlacesWikis() {
    if (_selectedCity == 'Istanbul') {
      return [
        WikiItem(
          icon: '🕌',
          title: 'Mosquée Bleue',
          subtitle: 'Chef-d\'œuvre ottoman',
          price: 'Gratuit',
          hours: '08:00 - 18:00 (fermé pendant les prières)',
          address: 'Sultan Ahmet Mahallesi, Istanbul',
          content: '''
# Mosquée Bleue (Sultan Ahmet Camii)

## Présentation
Construite par le sultan Ahmed Ier entre 1609 et 1616, la Mosquée Bleue est connue pour ses 20 000 céramiques bleu turquoise décorant ses murs intérieurs.

## Caractéristiques
- 6 minarets (unique au monde)
- Grande coupole de 43m de diamètre
- Entrée gratuite (hors heures de prière)

## Conseils de visite
- Éviter les heures de prière (prière du vendredi)
- S'habiller modestement
- Retirer ses chaussures
- Femmes doivent se couvrir les cheveux
          ''',
        ),
        WikiItem(
          icon: '🏛️',
          title: 'Palais Topkapi',
          subtitle: 'Centre du pouvoir ottoman',
          price: '750 TL adulte (2025)',
          hours: '09:00 - 17:00 (fermé mardi)',
          bookingUrl: 'https://www.muze.gov.tr/en/muze/step',
          website: 'https://topkapisarayi.gov.tr',
          phone: '+90 212 512 04 80',
          address: 'Cankurtaran Mahallesi, Istanbul',
          content: '''
# Palais Topkapi (Topkapı Sarayı)

## Histoire
Résidence des sultans ottomans pendant près de 400 ans (1465-1856). C'était le centre administratif et spirituel de l'Empire.

## Sections à voir
- **Premier Cour**: Place d'armes, fontaine du Sacrement
- **Deuxième Cour**: Cuisine impériale, salle du Conseil
- **Troisième Cour**: Trésor, bibliothèque, salle d'audience
- **Quatrième Cour**: Pavillons, jardins, vue sur le Bosphore

## Bijoux du Trésor
- Épée du prophète
- Casque d'or de Napoléon
- Diamant Spoonmaker (86 carats)

## Conseils
- Arriver tôt pour éviter les foules
- Prendre l'audio guide (disponible en français)
- Prévoir 3-4 heures de visite
- Réserver en ligne sur le site officiel de Muze
          ''',
        ),
        WikiItem(
          icon: '🛍️',
          title: 'Grand Bazar',
          subtitle: 'Plus grand marché couvert du monde',
          hours: '08:30 - 19:00 (fermé dimanche)',
          price: 'Gratuit (entrée)',
          website: 'https://www.kapalicarsi.com.tr',
          address: 'Beyazıt Mahallesi, Istanbul',
          content: '''
# Grand Bazar (Kapalı Çarşı)

## Présentation
Plus ancien et plus grand marché couvert du monde avec 61 ruelles et plus de 3000 boutiques. Fondé en 1455.

## Ce qu\'on trouve
- Bijoux et orfèvrerie
- Tapis et textiles
- Cuir et maroquinerie
- Épices et thé
- Souvenirs et artisanat

## Conseils
- Marchander obligatoire (commencer à 50% du prix)
- Se perdre fait partie de l'expérience
- Faire attention aux pickpockets
- Bargagner avec le sourire

## Quartiers environnants
- Bazar aux épices (Mısır Çarşısı)
- Bazar des bijoutiers (Zincirlikuyu)
          ''',
        ),
        WikiItem(
          icon: '⛲',
          title: 'Sainte-Sophie (Ayasofya)',
          subtitle: 'Chef-d\'œuvre byzantin et ottoman',
          price: 'Gratuit (mosquée ouverte)',
          hours: '09:00 - 19:00 (fermé pendant les prières)',
          website: 'https://muze.gen.tr/muze-detay/ayasofya',
          address: 'Sultanahmet Meydanı, Istanbul',
          content: '''
# Sainte-Sophie (Ayasofya-i Kebir)

## Histoire
Construite en 537 par l\'empereur byzantin Justinien, Sainte-Sophie fut la plus grande cathédrale du monde pendant près de 1000 ans. Convertie en mosquée en 1453, puis en musée en 1935, elle est redevenue mosquée en 2020.

## Architecture
- Dôme de 31m de diamètre, 56m de hauteur
- 40 fenêtres autour de la coupole
- Mosaïques byzantines du IXe siècle
- Marbres rares de l\'Empire romain

## À voir absolument
- La porte impériale en bois (VIe siècle)
- Les médaillons calligraphiques géants
- La galerie des impératrices
- La colonne des souhaits (colonne de Saint Grégoire)
          ''',
        ),
        WikiItem(
          icon: '💧',
          title: 'Citerne Basilique (Yerebatan)',
          subtitle: 'Palais souterrain byzantin',
          price: '450 TL adulte (2025)',
          hours: '09:00 - 18:30',
          bookingUrl: 'https://www.muze.gov.tr/en/muze/step',
          website: 'https://yerebatan.com',
          phone: '+90 212 512 15 70',
          address: 'Yerebatan Cd. 1/3, Sultanahmet, Istanbul',
          content: '''
# Citerne Basilique (Yerebatan Sarnıcı)

## Présentation
Construite en 532 par l\'empereur Justinien, la Citerne Basilique est la plus grande citerne souterraine d\'Istanbul, avec 336 colonnes de marbre.

## Caractéristiques
- Capacité initiale: 80 000 m³ d\'eau
- 336 colonnes hautes de 9m
- Deux colonnes avec tête de Méduse
- Colonne des larmes (colonne dédiée aux esclaves)

## Ambiance
Éclairage tamisé, eau calme, musique classique en fond. Une des expériences les plus magiques d\'Istanbul.

## Conseils
- Peu de monde en semaine à l\'ouverture
- Prévoir 30-45 minutes de visite
- Photos possibles sans flash
          ''',
        ),
        WikiItem(
          icon: '🗼',
          title: 'Tour de Galata',
          subtitle: 'Vue panoramique sur Istanbul',
          price: '350 TL adulte (2025)',
          hours: '08:30 - 22:00',
          website: 'https://muze.gov.tr/muze-detay?SectionId=GAL01&CityId=34',
          phone: '+90 212 249 03 44',
          address: 'Bereketzade Mh., Beyoğlu, Istanbul',
          content: '''
# Tour de Galata (Galata Kulesi)

## Histoire
Construite en 1348 par les Génois, la tour de Galata servait de fortification et d\'observatoire. Elle offre une vue à 360° sur la Corne d\'Or, le Bosphore et la vieille ville.

## Caractéristiques
- Hauteur: 66,90m
- 9 étages accessibles par ascenseur
- Plateforme d\'observation au sommet
- Restaurant panoramique au 8e étage

## Conseils
- Meilleur moment: coucher du soleil
- Arriver 30 min avant pour éviter la queue
- Le vent peut être fort au sommet

## Alentours
- Rue Istiklal (shopping et animations)
- Tunnel de Galata (2e plus vieux métro du monde)
- Quartier de Karaköy (restaurants branchés)
          ''',
        ),
        WikiItem(
          icon: '🏛️',
          title: 'Palais de Dolmabahçe',
          subtitle: 'Splendeur ottomane du XIXe siècle',
          price: '900 TL adulte (2025)',
          hours: '09:00 - 16:00 (fermé lundi)',
          bookingUrl: 'https://www.muze.gov.tr/en/muze/step',
          website: 'https://www.dolmabahcepalace.com',
          phone: '+90 212 327 26 26',
          address: 'Vişnezade Mh., Beşiktaş, Istanbul',
          content: '''
# Palais de Dolmabahçe (Dolmabahçe Sarayı)

## Histoire
Construit entre 1843 et 1856 par le sultan Abdülmecid Ier, ce palais de style baroque-ottoman fut la résidence principale des sultans après Topkapi.

## Points forts
- Grand lustre de cristal de 4,5 tonnes (offert par la reine Victoria)
- 285 chambres et 44 salles de réception
- Escalier de cristal en forme de fer à cheval
- Salle du Trône (Muayede Salonu)

## Jardins
- Parcs magnifiques en bord de Bosphore
- Horloge monumentale de la tour de l\'horloge
- Palais des princes héritiers

## Attention
- Visite guidée obligatoire (incluse dans le billet)
- Photos interdites à l\'intérieur
- Prévoir 2 heures de visite
          ''',
        ),
        WikiItem(
          icon: '🕌',
          title: 'Mosquée Süleymaniye',
          subtitle: 'Chef-d\'œuvre de l\'architecte Sinan',
          price: 'Gratuit (mosquée ouverte)',
          hours: '09:00 - 18:00 (fermé pendant les prières)',
          website: 'https://www.suleymaniyecamii.org',
          address: 'Süleymaniye Mh., Fatih, Istanbul',
          content: '''
# Mosquée Süleymaniye (Süleymaniye Camii)

## Histoire
Construite entre 1550 et 1557 par l\'architecte ottoman Sinan pour le sultan Soliman le Magnifique. C\'est l\'une des plus grandes mosquées d\'Istanbul.

## Architecture
- 4 minarets (symbolisant Soliman comme 4e sultan après la conquête)
- Coupole de 26,5m de diamètre, 53m de hauteur
- Vue panoramique sur la Corne d\'Or
- Jardin avec les tombeaux de Soliman et Roxelane

## Complexe
- Médersa (école coranique)
- Bibliothèque
- Hammam (bain turc)
- Marché aux épices souterrain

## Conseils
- Moins touristique que la Mosquée Bleue
- Vue magnifique depuis la cour arrière
- Visiter aussi le tombeau de Sinan à côté
          ''',
        ),
      ];
    } else {
      return [
        WikiItem(
          icon: '🏰',
          title: 'Kaleici',
          subtitle: 'Le vieux ville d\'Antalya',
          price: 'Gratuit (quartier historique)',
          hours: 'Accessible 24h/24',
          website: 'https://www.antalyakaleici.com',
          phone: '+90 242 249 50 00',
          address: 'Kaleiçi Mh., Muratpaşa, Antalya',
          content: '''
# Kaleici: Vieille Ville d'Antalya**

## Présentation
Kaleici est le quartier historique d'Antalya, préservation les vestiges de l'époque romaine et ottomane. Ses ruelles étroites et ses maisons ottomanes en bois en font un endroit romantique.

## À voir
- **Port de Hadrien**: Entrée monumentale romaine du IIe siècle
- **Maison de Flûteur**: Musée du patrimoine local
- **Clock Tower (Saat Kulesi)**: Tour d'horloge du XIXe siècle
- **Mosquée Муezzınlik**: Ancienne église byzantine convertie

## Architecture
- Maisons ottomanes à bow-windows
- Portes anciennes en bois sculpté
- Petites places ombragées

## Conseils
- Porter des chaussures de marche
- Explorer tôt le matin
- Dîner dans les restaurants de rue
          ''',
        ),
        WikiItem(
          icon: '🏖️',
          title: 'Plages d\'Antalya',
          subtitle: 'Les plus belles plages',
          price: 'Gratuit (plages publiques)',
          hours: 'Plages ouvertes 24h/24, sauveteurs 09:00 - 19:00',
          website: 'https://www.antalyakulturturizm.gov.tr',
          address: 'Littoral d\'Antalya (Konyaaltı, Lara)',
          content: '''
# Plages d'Antalya

## Konyaalti Beach
- Plage de graviers face aux montagnes
- Eaux cristallines
- Animations et cafés

## Lara Beach
- Plage de sable longue de 12km
- Hôtels de luxe en front de mer
- Couchers de soleil spectaculaires

## Phasélis
- Ruines antiques sur la plage
- Baie protégée
- Pins et eaux turquoise

## Patara
- Plus longue plage de Méditerranée
- Tortues Caretta caretta
- Village authentique proche
          ''',
        ),
        WikiItem(
          icon: '💧',
          title: 'Cascades de la Région',
          subtitle: ' beautés naturelles d\'Antalya',
          price: 'Düden: Gratuit (parc), Kurşunlu: 75 TL',
          hours: 'Parc Düden: 08:00 - 21:00; Kurşunlu: 08:00 - 19:00',
          website: 'https://www.antalyakulturturizm.gov.tr',
          address: 'Düden: Lara, Antalya / Kurşunlu: Aksu, Antalya',
          content: '''
# Cascades d'Antalya

## Düden Waterfall
- Cascade de 40m en plein centre
- Vue depuis le parc
- Photo parfaite

## Kursunlu Waterfall
- Cascade entourée de forêt
- Sentier de randonnée
- Pique-nique possible

## Manavgat Waterfall
- Large cascade puissants
- Bateaux disponibles
- Marché local à proximité

## Karpuzkaldiran
- Cascade de 50m derrière un temple
- Vue imprenable
- Accessible en taxi
          ''',
        ),
        WikiItem(
          icon: '🏛️',
          title: 'Musée d\'Antalya',
          subtitle: 'Un des plus grands musées de Turquie',
          price: '450 TL adulte (2025)',
          hours: '08:30 - 17:30 (fermé lundi)',
          website: 'https://www.antalyamuzesi.gov.tr',
          phone: '+90 242 238 56 88',
          address: 'Konyaaltı Cd. 88, Muratpaşa, Antalya',
          content: '''
# Musée d\'Antalya (Antalya Müzesi)

## Présentation
Un des plus importants musées de Turquie avec 14 salles d\'exposition sur 30 000 m². Collections allant du Paléolithique à l\'époque ottomane.

## Salles à ne pas manquer
- Salle des statues (Perge, Side, Aphrodisias)
- Salle des mosaïques (exceptionnelles)
- Salle des sarcophages (dont le sarcophage d\'Héraclès)
- Salle des icônes et monnaies

## Points forts
- Statue d\'Hercule (IIe siècle)
- Sarcophage de Domitien
- Collection de bijoux antiques
- Maquettes des cités antiques de la région

## Conseils
- Prévoir 2-3 heures de visite
- Audio guide disponible en français
- Combiné avec Porte d\'Hadrien (20 min à pied)
          ''',
        ),
        WikiItem(
          icon: '🏗️',
          title: 'Porte d\'Hadrien',
          subtitle: 'Arc de triomphe romain du IIe siècle',
          price: 'Gratuit (monument en plein air)',
          hours: 'Accessible 24h/24',
          address: 'Kaleiçi, Antalya (entrée de la vieille ville)',
          content: '''
# Porte d\'Hadrien (Hadrian Kapısı)

## Histoire
Arc de triomphe romain construit en 130 apr. J.-C. en l\'honneur de l\'empereur Hadrien. Restauré, c\'est aujourd\'hui l\'entrée principale de Kaleiçi.

## Architecture
- 3 arches en marbre blanc
- Colonnes corinthiennes
- Frises décoratives représentant des fleurs et motifs géométriques
- Tour nord et tour sud bien conservées

## Informations
- Accès libre, passage piéton
- Belle lumière pour les photos au coucher du soleil
- Point de départ idéal pour explorer Kaleiçi
          ''',
        ),
        WikiItem(
          icon: '🎭',
          title: 'Aspendos (Théâtre Antique)',
          subtitle: 'Théâtre romain le mieux conservé du monde',
          price: '500 TL adulte (2025)',
          hours: '08:00 - 19:00 (avril-octobre), 08:00 - 17:00 (novembre-mars)',
          website: 'https://www.muze.gov.tr/en/muze/step',
          phone: '+90 242 243 38 30',
          address: 'Serik Mahallesi, Belkıs, Antalya (45km à l\'est)',
          content: '''
# Aspendos (Aspendos Antik Kenti)

## Présentation
Le théâtre romain d\'Aspendos est le mieux conservé du monde antique. Construit au IIe siècle par l\'architecte romain Zénon, il peut accueillir 15 000 spectateurs.

## Caractéristiques
- Scène de 96m de large, parfaitement conservée
- Acoustique exceptionnelle
- Toujours utilisé pour des festivals et concerts
- Galeries voûtées pour l\'entrée/sortie

## Festival
Festival international d\'opéra et de ballet d\'Aspendos (juin-juillet)
Programmation: https://aspendosfestival.gov.tr

## À voir aussi sur le site
- Aqueduc romain
- Nymphée (fontaine monumentale)
- Bouleutérion (salle du conseil)
- Stade antique

## Conseils
- Meilleure visite en fin d\'après-midi (lumière dorée)
- Site peu ombragé, prévoir eau et chapeau
- Combiner avec la visite de Side (30 min)
          ''',
        ),
        WikiItem(
          icon: '🚡',
          title: 'Téléphérique Olympos',
          subtitle: 'Sommet du mont Tahtalı à 2365m',
          price: '1200 TL adulte aller-retour (2025)',
          hours: '09:00 - 18:00 (juin-septembre), 09:00 - 17:00 (octobre-mai)',
          bookingUrl: 'https://www.olymposteleferik.com',
          website: 'https://www.olymposteleferik.com',
          phone: '+90 242 242 00 00',
          address: 'Çıralı Mh., Kemer, Antalya',
          content: '''
# Téléphérique Olympos (Olympos Teleferik)

## Présentation
Téléphérique panoramique du mont Tahtalı (Olympos). La cabine monte de 726m à 2365m en 10 minutes, offrant une vue à 360° sur la côte lycienne.

## Expérience
- Vue sur le golfe d\'Antalya, Kemer, Phasélis
- Restaurant panoramique au sommet
- Parapente au départ du sommet
- Coucher de soleil magique

## À savoir
- Cabine: 80 personnes, départ toutes les 15 min
- Prévoir vêtements chauds (10-15°C de moins qu\'en bas)
- Meilleur moment: fin d\'après-midi pour le coucher du soleil

## Combiné possible
- Plage d\'Olympos (antique cité lycienne)
- Çıralı (plage des tortues Caretta caretta)
- Yanartaş (flamme éternelle du mont Chimère)
          ''',
        ),
        WikiItem(
          icon: '🏛️',
          title: 'Termessos (Cité Antique)',
          subtitle: 'Cité lycienne perchée à 1050m',
          price: '450 TL adulte (2025)',
          hours: '08:00 - 19:00 (avril-octobre), 08:00 - 17:00 (novembre-mars)',
          website: 'https://www.muze.gov.tr/en/muze/step',
          address: 'Güllük Dağı, Antalya (35km au nord-ouest)',
          content: '''
# Termessos (Termessos Antik Kenti)

## Présentation
Cité antique lycienne perchée à 1050m d\'altitude dans le parc national de Güllük Dağı. Surnommée "le nid d\'aigle" pour sa position imprenable.

## À voir
- Théâtre antique avec vue panoramique époustouflante
- Agora (place publique)
- Nécropole monumentale avec sarcophages
- Temple d\'Artémis
- Murs d\'enceinte cyclopéens

## Parc National
- Randonnée dans le parc Güllük Dağı
- Faune: bouquetins, aigles, tortues
- Pique-nique possible dans le parc

## Conseils
- Bonnes chaussures de marche indispensables
- Apporter eau et provisions (pas de restaurant sur place)
- Prévoir 3-4 heures de visite
- Meilleure saison: printemps et automne (chaud en été)
          ''',
        ),
      ];
    }
  }

  List<WikiItem> _getActivitiesWikis() {
    if (_selectedCity == 'Istanbul') {
      return [
        WikiItem(
          icon: '⛵',
          title: 'Croisière sur le Bosphore',
          subtitle: 'L\'essentiel de la ville depuis l\'eau',
          price: 'Vapur: 20 TL; Croisière touristique: 25-40€',
          hours: 'Vapur: 06:00 - 23:00; Croisières: départs 10:00, 14:00, 18:00',
          bookingUrl: 'https://www.sehirhatlari.com.tr',
          website: 'https://www.sehirhatlari.com.tr',
          phone: '+90 212 444 18 66',
          address: 'Eminönü İskelesi, Fatih, Istanbul',
          content: '''
# Croisière sur le Bosphore

## Options
- **Bateaux publics (Şehir Hatları)**: 20 TL, traversées fréquentes
- **Croisières touristiques**: 25-40€, Includes guide multilingue
- **Bateaux privés**: 100-200€, réserver via votre hôtel ou les agences

## Ce qu\'on voit
- Palais de Dolmabahçe
- Palais de Çırağan
- Forteresse de Rumeli
- Villages historiques (Arnavutköy, Bebek)
- Bosphore Bridge

## Meilleurs moments
- Lever du soleil: lumière douce
- Coucher du soleil: couleurs magiques
- Nuit: Illuminations des palais

## Durée
- Traversée simple: 20 minutes
- Croisière complète: 2-3 heures
          ''',
        ),
        WikiItem(
          icon: '🛁',
          title: 'Hammam: Bain Turc',
          subtitle: 'Tradition millénaire',
          price: 'Plusieurs hammams: 150-500+ TL selon services',
          hours: 'Généralement 08:00 - 22:00',
          website: 'https://www.cemberlitashamami.com.tr',
          address: 'Çemberlitaş (Istanbul), Kaleiçi (Antalya)',
          content: '''
# Hammam: Bain Turc

## Qu\'est-ce?
Le hammam est un bain public traditionnel turc, hérité des bains romains et byzantins. C'est une expérience culturelle incontourn able.

## Déroulement classique
1. **Relaxation**:Salle chaude pour transpirer
2. **Savonnage**:Nettoyage par le maître savonnier
3. **Massage**:Gommage avec gant de crin
4. **Repos**:Thé dans la salle de repos

## Hammams Recommandés
- **Çemberlitaş Hamamı**: Historique, près du Grand Bazar
- **Galatasaray Hamamı**: Dans le quartier branché
- **Kılıç Ali Paşa**: Superbe carrelage Ottoman
- **Ayasofya Hürrem Sultan**: Luxe près de la Mosquée Bleue

## Prix
- Standard: 300-500 TL
- Avec massage: 600-1000 TL
- Luxe (Ayasofya etc.): 1000-2000 TL

## Réservation
- **Çemberlitaş Hamamı**: +90 212 520 18 50 | https://www.cemberlitashamami.com.tr
- **Galatasaray Hamamı**: +90 212 252 42 42 | https://www.galatasarayhamami.com
- **Ayasofya Hürrem Sultan**: +90 212 517 35 35 | https://www.ayasofyahamami.com

## À apporter
- Maillot de bain
- Serviette (généralement fournie)
- Savon (optionnel)
          ''',
        ),
        WikiItem(
          icon: '🎭',
          title: 'Spectacles Traditionnels',
          subtitle: 'Soirées culturelles',
          price: 'Derviches: 250-500 TL; Danse ventre: 300-600 TL',
          hours: 'Spectacles: généralement 19:00 - 21:00',
          bookingUrl: 'https://www.hodjapasha.com',
          website: 'https://www.hodjapasha.com',
          phone: '+90 212 522 67 34',
          address: 'Hodjapasha, Eminönü, Istanbul',
          content: '''
# Spectacles à Istanbul

## Danse du Ventre
Nombreux restaurants proposent des spectacles:
- **Hodjapasha**: Spectacle incontourn able
- **Skylight**: Vue sur le Bosphore

## Whirling Dervishes (Sema)
Danse mystique des derviches tourneurs:
- **Galata Mevlevi Museum**: Samedi
- **Hodjapasha**: Plusieurs soirs/semaine

## Türkü (Musique traditionnelle)
Bars à musique dans les quartiers:
- **Cihangir**: Bars authentiques
- **Beyoğlu**: Plus touristique
- **Kadırga**: Ambiance locale

## Réservation
- Acheter sur place ou via votre hôtel
- Éviter les "tours" proposent trop cher
- Lire les avis avant de réserver
          ''',
        ),
      ];
    } else {
      return [
        WikiItem(
          icon: '🤿',
          title: 'Plongée à Antalya',
          subtitle: 'Explorez les profondeurs',
          price: 'Baptême: 50-80€; Plongée: 40-60€; Open Water: 300-400€',
          hours: 'Sessions: 09:00 - 15:00 (selon centre)',
          bookingUrl: 'https://www.olymposdiving.com',
          website: 'https://www.olymposdiving.com',
          phone: '+90 242 814 37 37',
          address: 'Kemer, Kaş, Alanya (selon centre)',
          content: '''
# Plongée à Antalya

## Sites de Plongée
- **Kemer**: Epaves et vida marine
- **Kaş**: Grottes sous-marines
- **Kalkan**: Coraux et poissons

## Centres de Plongée
- **Olympos Diving**: Multiples sites
- **Alanya Dive Center**: Pour débutants

## Conditions
- Temperature: 18-26°C selon saison
- Meilleure période: Mai-Octobre
- visibility: 20-40m

## Prix
- Baptême: 50-80€
- Plongée: 40-60€
- Cours Open Water: 300-400€
          ''',
        ),
        WikiItem(
          icon: '🧗',
          title: 'Randonnée dans les Monts Taurus',
          subtitle: 'Aventure en montagne',
          price: 'Gratuit (sentiers publics); Guide: 500-1000 TL/jour',
          hours: 'Meilleure période: mars-juin, septembre-novembre',
          website: 'https://www.lycianway.com',
          address: 'Parc national Güllük Dağı, Antalya',
          content: '''
# Randonnée dans le Taurus

## Sentiers Recommandés
- **Lycian Way**: 500km de sentiers balisés
- **Üçards**: Vue panoramique
- **Gömbe**: Vallée isolé

## Ce qu\'on voit
- Villages traditionnels
- Antiquités
- Fauna (chèvres sauvages, rapaces)
- Paysages variés

## Conseils
- Partir tôt le matin
- Emporter足够的水
- Chaussures de randonnée
- Guide recommandé pour certains itinéraires
          ''',
        ),
        WikiItem(
          icon: '🛶',
          title: 'Rafting à Antalya',
          subtitle: 'Adrénaline sur l\'Eurymédon',
          price: 'Demi-journée: 250-400 TL; Journée complète: 500-800 TL',
          hours: 'Mai-septembre, sessions: 09:00 - 16:00',
          bookingUrl: 'https://www.koprulucanyonpark.com',
          website: 'https://www.koprulucanyonpark.com',
          phone: '+90 242 752 30 00',
          address: 'Köprülü Canyon, Antalya',
          content: '''
# Rafting à Antalya

## Rivière Köprülü Canyon
- Grade II-III: Débutant
- Distance: 14km
- Durée: 2-3 heures

## En été
- Mai-Septembre
- Température de l'eau: 15-20°C
- Combiner avec baignade

## Prestataires
- **Köprülü Canyon Park**
- **Toros Rafting**

## Prix
- Demi-journée: 250-400 TL
- Inclus: équipement, guide, déjeuner
          ''',
        ),
      ];
    }
  }

  List<WikiItem> _getTipsWikis() {
    if (_selectedCity == 'Istanbul') {
      return [
        WikiItem(
          icon: '💰',
          title: 'Budget à Istanbul',
          subtitle: 'Comment gérer son argent',
          content: '''
# Budget à Istanbul

## Coûts Moyens (en Lira Turque - 2025)

### Petit budget (< 1000 TL/jour)
- Auberge: 300-500 TL
- Repas rapide: 80-150 TL
- Transport public: 30-50 TL

### Budget moyen (1000-2500 TL/jour)
- Hôtel 3*: 800-1500 TL
- Restaurant local: 200-400 TL
- Visites: 100-500 TL

### Comfort (2500+ TL/jour)
- Hôtel 4-5*: 2000-5000 TL
- Restaurant raffiné: 500-1500 TL
- Shopping: variable

## Économiser
- Manger dans les lokantas
- Utiliser le métro et les ferries
- Acheter dans les marchés locaux
- Marchander dans les bazar

## Payer
- Liquide: Préférez pour petits montants
- Carte: Accepté partout pour gros montants
- Retrait: DAB dans les quartiers, éviter les changeurs
          ''',
        ),
        WikiItem(
          icon: '🚇',
          title: 'Se Déplacer à Istanbul',
          subtitle: 'Transports en commun',
          price: 'Istanbulkart: 130 TL (carte); Trajet: 20 TL',
          hours: 'Métro: 06:00 - 00:00; Vapur: 06:00 - 23:00',
          website: 'https://www.metro.istanbul',
          phone: '+90 212 444 18 66',
          address: 'Istanbul (réseau de transports)',
          content: '''
# Transports à Istanbul

## Métro et Tramway
- **Metro**: Rapide, fiable, pas cher
- **Tramway T1**: Sultanahmet - Kabataş
- **Tramway T5**: Eminönü - Cibala

## Bateaux (Vapur)
- Bosphore: Traversée 5 TL
- Île-Princes: Bateau+ferry
- Le meilleur moyen de traverser!

## Bus et Dolmuş
- Bus municipal (IETT): Bon marché
- Dolmuş: Minibus partagé, plus rapide

## Taxi
- Utiliser BiTaksi ou Yandex
- Négocier pour les courses rurales
- Attention aux embouteillages

## Conseils
- Acheter Istanbulkart (transport illimité)
- Éviter les heures de pointe (8-9h, 17-19h)
- Le周末, la circulation est fluide
          ''',
        ),
        WikiItem(
          icon: '📱',
          title: 'Applications Utiles',
          subtitle: 'Outils numériques pour Istanbul',
          website: 'https://www.istanbulkart.istanbul',
          content: '''
# Applications pour Istanbul

## Transport
- **BiTaksi**: Commander un taxi
- **Istanbul Metro**: Plan du métro
- **Moovit**: Bus et temps réel

## Food
- **Yemeksepeti**: Livraison
- **TripAdvisor**: Restaurants notés
- **Foursquare**: Bons plans locaux

## Communication
- **Google Translate**: Indispensable
- **Duolingo**: Apprendre les bases turques

## Shopping
- **Grand Bazar**: Site officiel
- **Trendyol**: Amazon local

## Vie quotidienne
- **Airbnb**: Réservation
- **Booking**: Hôtels
- **Maps.me**: Hors ligne

## Astuce
- Télécharger离线 carte de la ville
          ''',
        ),
      ];
    } else {
      return [
        WikiItem(
          icon: '🌡️',
          title: 'Quand Partir à Antalya',
          subtitle: 'Calendrier saisonnier',
          website: 'https://www.antalyakulturturizm.gov.tr',
          content: '''
# Quand Visiter Antalya

## Meilleures Périodes

### Avril-Mai
- Température: 20-25°C
- Avantages: Moins de monde, prix corrects
- Inconvénient: Pluie possible

### Juin-Septembre
- Température: 28-35°C
- Avantages: Idéal pour la plage
- Inconvénient: Très touristique, cher

### Octobre-Novembre
- Température: 20-28°C
- Avantages: Meilleure période!
- Inconvénient: Certaines fermetures saisonnières

### Décembre-Mars
- Température: 10-18°C
- Avantages: Prix très bas
- Inconvénient: Pluie fréquente, certaines fermetures

## Festivals
- **Février**: Carnaval d'Antalya
- **Avril**: Festival de musique classique
- **Octobre**: Festival du film d'Antalya
          ''',
        ),
        WikiItem(
          icon: '🏥',
          title: 'Santé et Sécurité',
          subtitle: 'Conseils pratiques',
          phone: 'Police: 155 | Ambulance: 112 | Pompiers: 110',
          website: 'https://www.antalyakulturturizm.gov.tr',
          content: '''
# Santé et Sécurité à Antalya

## Santé
- **Hôpitaux**: Bon système médical, plusieurs hôpitaux privés avec services en anglais
- Pharmacies (eczane) dans tous les quartiers (ouvertes 08:00 - 24:00)
- Attention au soleil (crème SPF 50+ obligatoire)
- Eau du robinet potable (mais préférez l\'eau en bouteille)

## Sécurité
- Très sûr pour les touristes
- Vols à la tire rares mais possibles dans les zones très touristiques
- Police touristique (Turizm Polisi): +90 242 248 97 62
- En cas de problème: contacter l\'ambassade

## Numéros d\'urgence
- Police: 155
- Ambulance: 112
- Pompiers: 110
- Gendarmerie: 156
- Assistance routière: 159

## Hôpitaux recommandés
- **Medikal Park Antalya**: +90 242 314 14 14
- **Memorial Antalya**: +90 242 314 44 44

## Astuces
- Souscrire une assurance voyage
- Avoir ses médicaments personnels
- Protéger ses effets personnels à la plage
          ''',
        ),
        WikiItem(
          icon: '🎒',
          title: 'Liste de Bagages',
          subtitle: 'Ce qu\'il faut emporter',
          website: 'https://www.antalyakulturturizm.gov.tr',
          content: '''
# Bagages pour Antalya

## Vêtements
- Maillot de bain (obligatoire!)
- Vêtements légers (coton, lin)
- Vêtements couvrant les épaules et genoux pour les mosquées
- Chaussures de marche
- Sandales et tongs
- Veste légère pour le soir (surtout hors été)

## Documents
- Passeport (valide 6 mois après le retour)
- Billet d\'avion (version numérique et papier)
- Réservations d\'hôtel imprimées
- Assurance voyage
- Permis de conduire international (si location voiture)
- VISA électronique (e-Visa) imprimé

## Électronique
- Chargeur téléphone
- Banque d\'alimentation externe
- Appareil photo
- Adaptateur prise turque (type F, 230V)
- Carte SIM turque ou eSIM

## Trousse de toilette
- Crème solaire haute protection (SPF 50+)
- Lunettes de soleil
- Médicaments personnels (avec ordonnance si nécessaire)
- Trousse de premiers secours basique
- Anti-moustique (surtout en été)
- Gel hydroalcoolique

## Pour la plage
- Serviette de plage (microfibre conseillée)
- Masque et tuba (snorkeling)
- Sac étanche pour téléphone/portefeuille
- Chaussures d\'eau (pour plages de galets)

## Spécifique Ramadan
- Si pendant le ramadan: prévoir collations pour la journée
          ''',
        ),
      ];
    }
  }
}

class WikiItem {
  final String icon;
  final String title;
  final String subtitle;
  final String content;
  final String? price;
  final String? hours;
  final String? bookingUrl;
  final String? website;
  final String? phone;
  final String? address;

  WikiItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.content,
    this.price,
    this.hours,
    this.bookingUrl,
    this.website,
    this.phone,
    this.address,
  });
}

void _openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {}
}

class WikiDetailScreen extends StatelessWidget {
  final WikiItem item;
  final Color color;

  const WikiDetailScreen({super.key, required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (item.price != null || item.hours != null || item.phone != null || item.address != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.price != null)
                            _detailInfoRow(Icons.monetization_on, 'Prix', item.price!),
                          if (item.hours != null)
                            _detailInfoRow(Icons.access_time, 'Horaires', item.hours!),
                          if (item.phone != null)
                            _detailInfoRow(Icons.phone, 'T\u00E9l\u00E9phone', item.phone!),
                          if (item.address != null)
                            _detailInfoRow(Icons.location_on, 'Adresse', item.address!),
                          if (item.bookingUrl != null || item.website != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (item.bookingUrl != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openUrl(item.bookingUrl!),
                                      icon: const Icon(Icons.confirmation_number, size: 18),
                                      label: const Text('R\u00E9server', style: TextStyle(fontSize: 13)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: color,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                if (item.bookingUrl != null && item.website != null)
                                  const SizedBox(width: 8),
                                if (item.website != null)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openUrl(item.website!),
                                      icon: const Icon(Icons.language, size: 18),
                                      label: const Text('Site web', style: TextStyle(fontSize: 13)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: color,
                                        side: BorderSide(color: color),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  SelectableLinkify(
                    text: item.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                    linkStyle: TextStyle(
                      color: color,
                      decoration: TextDecoration.underline,
                    ),
                    onOpen: (link) => _openUrl(link.url),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}