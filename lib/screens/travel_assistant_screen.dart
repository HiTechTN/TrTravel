import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/travel_assistant_service.dart';
import '../models/trip_suggestion.dart';
import '../models/trip_day.dart';

class TravelAssistantScreen extends StatefulWidget {
  const TravelAssistantScreen({super.key});

  @override
  State<TravelAssistantScreen> createState() => _TravelAssistantScreenState();
}

class _TravelAssistantScreenState extends State<TravelAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedCity = 'Istanbul';

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<TravelAssistant>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFE30A17),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
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
                              child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assistant voyage',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Planifiez votre voyage parfait',
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
                  _buildQuickAsk(assistant),
                  const SizedBox(height: 20),
                  _buildCitySelector(),
                  const SizedBox(height: 20),
                  _buildTripDuration(assistant),
                  const SizedBox(height: 20),
                  _buildInterestSelector(assistant),
                  const SizedBox(height: 20),
                  _buildSuggestions(assistant),
                  const SizedBox(height: 20),
                  _buildTripPlanner(assistant),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAsk(TravelAssistant assistant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFFE30A17), size: 22),
              SizedBox(width: 8),
              Text(
                'Posez une question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              hintText: 'Ex: Que faire à Istanbul ce weekend?',
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFE30A17)),
                onPressed: () => _askQuestion(assistant),
              ),
            ),
            onSubmitted: (_) => _askQuestion(assistant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickChip('Que voir?', () => _quickAsk(assistant, 'Que voir à $_selectedCity?')),
              _quickChip('Restaurants?', () => _quickAsk(assistant, 'Meilleurs restaurants à $_selectedCity?')),
              _quickChip('Transport?', () => _quickAsk(assistant, 'Comment se déplacer à $_selectedCity?')),
              _quickChip('Shopping?', () => _quickAsk(assistant, 'Où faire du shopping à $_selectedCity?')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: const Color(0xFFE30A17).withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Color(0xFFE30A17)),
      onPressed: onTap,
    );
  }

  void _askQuestion(TravelAssistant assistant, [String? question]) {
    final q = question ?? _questionController.text;
    if (q.isEmpty) return;
    
    HapticFeedback.lightImpact();
    _questionController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnswerSheet(question: q, city: _selectedCity),
    );
  }

  void _quickAsk(TravelAssistant assistant, String question) {
    _questionController.text = question;
    _askQuestion(assistant, question);
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city, color: Color(0xFFE30A17), size: 22),
              SizedBox(width: 8),
              Text(
                'Sélectionnez une ville',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _cityButton('Istanbul', '🏛️'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cityButton('Antalya', '🏖️'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cityButton(String city, String emoji) {
    final isSelected = _selectedCity == city;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCity = city);
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE30A17) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE30A17) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              city,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDuration(TravelAssistant assistant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFFE30A17), size: 22),
              SizedBox(width: 8),
              Text(
                'Durée du voyage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final days = i + 1;
              final isSelected = assistant.tripDuration == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    assistant.setTripDuration(days);
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE30A17) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$days',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${assistant.tripDuration} jour${assistant.tripDuration > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSelector(TravelAssistant assistant) {
    final interests = [
      {'id': 'historical', 'icon': '🏛️', 'label': 'Histoire'},
      {'id': 'food', 'icon': '🍽️', 'label': 'Gastronomie'},
      {'id': 'shopping', 'icon': '🛍️', 'label': 'Shopping'},
      {'id': 'nature', 'icon': '🌿', 'label': 'Nature'},
      {'id': 'nightlife', 'icon': '🌙', 'label': 'Vie nocturne'},
      {'id': 'culture', 'icon': '🎭', 'label': 'Culture'},
      {'id': 'beach', 'icon': '🏖️', 'label': 'Plages'},
      {'id': 'adventure', 'icon': '🎢', 'label': 'Aventure'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.interests, color: Color(0xFFE30A17), size: 22),
              SizedBox(width: 8),
              Text(
                'Vos intérêts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = assistant.interests.contains(interest['id']);
              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(interest['icon']!),
                    const SizedBox(width: 4),
                    Text(interest['label']!),
                  ],
                ),
                selectedColor: const Color(0xFFE30A17).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFFE30A17),
                onSelected: (_) {
                  assistant.toggleInterest(interest['id']!);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(TravelAssistant assistant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.recommend, color: Color(0xFFE30A17), size: 22),
              SizedBox(width: 8),
              Text(
                'Suggestions personnalisées',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (assistant.suggestions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Sélectionnez vos intérêts pour recevoir des suggestions',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...assistant.suggestions.take(5).map((s) => _suggestionCard(s)),
        ],
      ),
    );
  }

  Widget _suggestionCard(TripSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(suggestion.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${suggestion.duration} • ${suggestion.estimatedCost}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE30A17)),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ajouté au planning!'),
                  backgroundColor: Color(0xFFE30A17),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripPlanner(TravelAssistant assistant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: Color(0xFFE30A17), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Planificateur de voyage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité en cours de développement'),
                      backgroundColor: Color(0xFF546E7A),
                    ),
                  );
                },
                child: const Text('Générer'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(Icons.location_on, _selectedCity),
                    _statItem(Icons.calendar_today, '${assistant.tripDuration} jours'),
                    _statItem(Icons.category, '${assistant.interests.length} intérêts'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Créer mon itinéraire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30A17),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Itinéraire généré!'),
                          backgroundColor: Color(0xFF43A047),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE30A17), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _AnswerSheet extends StatelessWidget {
  final String question;
  final String city;

  const _AnswerSheet({required this.question, required this.city});

  @override
  Widget build(BuildContext context) {
    final answers = _getAnswer();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.support_agent, color: Color(0xFFE30A17), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Assistant voyage',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final answer = answers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(answer['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              answer['title']!,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              answer['desc']!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getAnswer() {
    final lowerQ = question.toLowerCase();
    
    if (lowerQ.contains('voir') || lowerQ.contains('visiter')) {
      if (city == 'Istanbul') {
        return [
          {'icon': '🕌', 'title': 'Sainte-Sophie', 'desc': 'Chef-d\'œuvre byzantin, incontournable'},
          {'icon': '🕌', 'title': 'Mosquée Bleue', 'desc': 'Splendide mosquée du XVIe siècle'},
          {'icon': '🏛️', 'title': 'Palais Topkapi', 'desc': 'Ancien palais des sultans ottomans'},
          {'icon': '🛒', 'title': 'Grand Bazar', 'desc': 'Plus grand marché couvert du monde'},
          {'icon': '🌉', 'title': 'Pont du Bosphore', 'desc': 'Vue panoramique sur la ville'},
        ];
      } else {
        return [
          {'icon': '🏛️', 'title': 'Kaleici', 'desc': 'Vieux quartier historique d\'Antalya'},
          {'icon': '🏖️', 'title': 'Plage de Konyaalti', 'desc': 'Belle plage aux eaux turquoises'},
          {'icon': '瀑布', 'title': 'Kursunlu', 'desc': 'Magnifique cascade naturelle'},
          {'icon': '🏛️', 'title': 'Musée d\'Antalya', 'desc': 'Trésors archéologiques de la région'},
          {'icon': '🗿', 'title': 'Aspendos', 'desc': ' Théâtre romain parfaitement préservé'},
        ];
      }
    } else if (lowerQ.contains('restaurant') || lowerQ.contains('manger')) {
      if (city == 'Istanbul') {
        return [
          {'icon': '🍽️', 'title': 'Karaköy Lokantasi', 'desc': 'Cuisine ottomane raffinée'},
          {'icon': '🥙', 'title': 'Karadeniz Pidecisi', 'desc': 'Pide authentique et bon marché'},
          {'icon': '🍜', 'title': 'Çiya Sofrasi', 'desc': 'Cuisine turque locale متنوعة'},
          {'icon': '🥐', 'title': 'Kahvaltı & Co', 'desc': 'Petit-déjeuner turc traditionnel'},
          {'icon': '🍢', 'title': 'Balık Pazarı', 'desc': 'Marché aux poissons frais'},
        ];
      } else {
        return [
          {'icon': '🍖', 'title': 'Meyo', 'desc': 'Grillades locales avec vue mer'},
          {'icon': '🐟', 'title': 'Ser上一', 'desc': 'Poisson frais au bord de l\'eau'},
          {'icon': '🥙', 'title': 'Lara Köfte', 'desc': 'Köfte traditionnelle artisanale'},
          {'icon': '🍦', 'title': 'Dondurma', 'desc': 'Glace turque authentique'},
          {'icon': '🍽️', 'title': 'The Shed', 'desc': 'Cuisine internationale moderne'},
        ];
      }
    } else if (lowerQ.contains('transport') || lowerQ.contains('déplacer')) {
      return [
        {'icon': '🚋', 'title': 'Métro', 'desc': 'Rapide et bon marché dans la ville'},
        {'icon': '⛴️', 'title': 'Bosphor', 'desc': 'Bateaux publics entre continents'},
        {'icon': '🚕', 'title': 'Taxi', 'desc': 'Disponible mais négocier le prix'},
        {'icon': '🚌', 'title': 'Dolmuş', 'desc': 'Minibus partagé, économique'},
        {'icon': '🚶', 'title': 'Marcher', 'desc': 'Le meilleure moyen dans les quartiers'},
      ];
    } else if (lowerQ.contains('shopping')) {
      return [
        {'icon': '🛒', 'title': 'Grand Bazar', 'desc': 'Marché traditionnel, negotiatez!'},
        {'icon': '🛍️', 'title': 'Istinye Park', 'desc': 'Centre commercial moderne'},
        {'icon': '🧶', 'title': 'Arasta Bazaar', 'desc': 'Artisanat et souvenirs'},
        {'icon': '👗', 'title': 'Nisantasi', 'desc': 'Quartier branché pour mode'},
        {'icon': '🛍️', 'title': 'Mall of Istanbul', 'desc': 'Grand centre commercial'},
      ];
    }
    
    return [
      {'icon': '💡', 'title': 'Conseil', 'desc': 'Essayez une question plus précise'},
    ];
  }
}