import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        child: Row(
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
          content: '''
# Mekan: Lieux de Restauration

## Types de Restaurants

### Lokanta
Restaurants familiaux servant des plats traditionnels. Prix démocratiques.

### Meyhane
Restaurant offrant également des animations (musique, danse). Idéal pour le rakı.

### Kebapçı
Spécialisé dans les kebabs. Le durum ( wrap) est très populaire.

## Quartiers Gourmet
- **Kadırga**: Bons restaurants bon marché
- **Kumkapı**: Poisson et fruits de mer
- **Balat**: Cuisine traditionnelle
- **Karaköy**: Restaurants branchés
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
          content: '''
# Mosquée Bleue (Süleymaniye Camii)

## Présentation
Construite par le sultan Ahmed Ier entre 1609 et 1616, la Mosquée Bleue est connue pour ses 20 000 céramique bleu turquoise décorant ses murs intérieurs.

## Caractéristiques
- 6 minarets ( unique among mosques)
- Grande coupole de 43m de diamètre
- Entrée gratuite (hors heures de prière)

## Conseils de visite
- Éviter les heures de prière (prière du vendredi)
- S'habiller modestement
- Retirer ses chaussures
- Femmess doivent se couvrir les cheveux
          ''',
        ),
        WikiItem(
          icon: '🏛️',
          title: 'Palais Topkapi',
          subtitle: 'Centre du pouvoir ottoman',
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
- épée du prophète
- Casque d'or de Napoléon
- Diamant Spoonmaker

## Conseils
- Arriver tôt pour éviter les foules
- Prendre l_audio guide
- Prévoir 3-4 heures de visite
          ''',
        ),
        WikiItem(
          icon: '🛍️',
          title: 'Grand Bazar',
          subtitle: 'Plus grand marché couvert du monde',
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
      ];
    } else {
      return [
        WikiItem(
          icon: '🏰',
          title: 'Kaleici',
          subtitle: 'Le vieux ville d\'Antalya',
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
          subtitle: ' beaut的自然lles naturelles',
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
          content: '''
# Croisière sur le Bosphore

## Options
- **Bateaux publics (Vapur)**: 1.5 TL, traversées fréquentes
- **Croisières touristiques**: 15-25€, Includes guide
- **Bateaux privès**: Réserver via votre hôtel

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
          subtitle: ' Tradition millénaire',
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
- standard: 150-250 TL
- Avec massage: 300-500 TL
- Luxe: 500+ TL

## À apporter
- Maillot de bain (hommes)
- Serviette (ou fourni)
          ''',
        ),
        WikiItem(
          icon: '🎭',
          title: 'Spectacles Traditionnels',
          subtitle: 'Soirées culturelles',
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
          title: 'Rafting àantalya',
          subtitle: 'Adrénaline sur l\'Eurymédon',
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

## Coûts Moyens (en Lira Turque)

### Petit budget (< 300 TL/jour)
- Auberge: 100-150 TL
- Repas rapide: 30-50 TL
- Transport public: 10-20 TL

### Budget moyen (300-600 TL/jour)
- Hôtel 3*: 200-350 TL
- Restaurant local: 60-150 TL
- Visites: 50-150 TL

### Comfort (600+ TL/jour)
- Hôtel 4-5*: 400-800 TL
- Restaurant raffiné: 150-400 TL
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
          content: '''
# Quand Visiter Antalya

## Meilleures Périodes

### Avril-Mai
- Température: 20-25°C
- Avantages: Moins de monde, prix corrects
- Inconvénient:可能会有pluie

### Juin-Septembre
- Température: 28-35°C
- Avantages: Ideal pour la plage
- Inconvénient: Très touristes, cher

### Octubre-Novembre
- Température: 20-28°C
- Avantages: Meilleure période!
- Inconvénient: некоторыеfermetures

### Décembre-Mars
- Température: 10-18°C
- Avantages: Prix très bas
- Inconvénient: Pluie fréquente, certaines fermetures

## Festivals
- **Février**: Carnival d'Antalya
- **Avril**: Festival de musique classique
- **Octobre**: Festival du film
          ''',
        ),
        WikiItem(
          icon: '🏥',
          title: 'Santé et Sécurité',
          subtitle: 'Conseils pratiques',
          content: '''
# Santé et Sécurité à Antalya

## Santé
- **Hôpitaux**: Bon système médical
- Pharmacies dans tous les quartiers
- Attention au soleil (crème SPF 50+)
- Eau du robinet potable

## Sécurité
- Très safe pour les touristes
- Vols à la tirerare
- Encas de problème: police touristique

## Numéros d\'urgence
- Police: 155
- Ambulance: 112
- Pompiers: 110

## Astuces
- Souscrire une assurance voyage
- avoir ses médicaments
- Protéger ses effets personnels
          ''',
        ),
        WikiItem(
          icon: '🎒',
          title: 'Liste de Bagages',
          subtitle: 'Ce qu\'il faut emporter',
          content: '''
# Bagages pour Antalya

## Vêtements
- Maillot de bain obligatoire
- Vêtements légère (coton, lin)
- Vêtements couvre-epaule pour les mosquées
- Chaussures de marche
- Sandales

## Documents
- Passeport (valide 6 mois)
- Billet d'avion
- Réservations d'hôtel
- Assurance voyage

## Électronique
- Chargeur téléphone
- Appareil photo
- Adaptateur prise turque (type F)

## Trousse
- Crème solaire haute protection
- Lunettes de soleil
- Médicaments personnels
- Premier secoursbasique

## Pour la plage
- Serviette de plage
- Parasol pliable
- Snorkeling masque
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

  WikiItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.content,
  });
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
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    item.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
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
}