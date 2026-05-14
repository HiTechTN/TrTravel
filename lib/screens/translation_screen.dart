import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/translation_service.dart';
import 'camera_translation_screen.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  String _sourceLang = 'fr';
  String _targetLang = 'tr';
  bool _isTranslating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_controller.text.isEmpty) return;
    
    setState(() => _isTranslating = true);
    
    final service = context.read<TranslationService>();
    final result = await service.translate(
      _controller.text, 
      _sourceLang, 
      _targetLang
    );
    
    setState(() {
      _translatedText = result;
      _isTranslating = false;
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _translatedText = '';
    });
  }

  Future<void> _speak() async {
    final service = context.read<TranslationService>();
    final text = _translatedText.isNotEmpty ? _translatedText : _controller.text;
    await service.speak(text, _targetLang);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TranslationService>();
    final languages = service.getAvailableLanguages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traducteur'),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraTranslationScreen()));
            },
          ),
          IconButton(
            icon: Icon(service.isOffline ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () {
              service.setOfflineMode(!service.isOffline);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sourceLang,
                        isExpanded: true,
                        items: languages.map((lang) => DropdownMenuItem(
                          value: lang['code'],
                          child: Text(lang['nativeName']!),
                        )).toList(),
                        onChanged: (val) => setState(() => _sourceLang = val!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _swapLanguages,
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _targetLang,
                        isExpanded: true,
                        items: languages.map((lang) => DropdownMenuItem(
                          value: lang['code'],
                          child: Text(lang['nativeName']!),
                        )).toList(),
                        onChanged: (val) => setState(() => _targetLang = val!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Entrez le texte à traduire...',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.mic),
                          label: const Text('Dictée'),
                          onPressed: () {},
                        ),
                        ElevatedButton(
                          onPressed: _translate,
                          child: _isTranslating 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Traduire'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFE3F2FD),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.translate, size: 20),
                          const SizedBox(width: 8),
                          const Text('Traduction:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: _speak,
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _translatedText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copié!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translatedText,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Phrases utiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._buildCommonPhrases(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCommonPhrases() {
    final service = context.read<TranslationService>();
    final phrases = service.getCommonPhrases(_sourceLang);
    
    if (phrases.isEmpty) {
      return [
        const Card(
          child: ListTile(
            title: Text('Aucune phrase disponible', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ];
    }

    final categories = {
      'Greetings': ['Bonjour', 'Bonsoir', 'Au revoir', 'Salut', 'Comment allez-vous?', 'Enchanté', 'Bonne nuit', 'À bientôt'],
      'Essential': ['Merci', 'Merci beaucoup', 'S\'il vous plaît', 'Excusez-moi', 'Pardon', 'Oui', 'Non', 'Je ne comprends pas', 'Je comprends', 'Aide', 'Au secours!', 'Attention', 'Danger'],
      'Directions': ['Où est...?', 'À gauche', 'À droite', 'Tout droit', 'Loin', 'Près', 'ICI', 'Là-bas', 'Rue', 'Place'],
      'Transport': ['L\'addition', 'Combien ça coûte?', 'Bathroom', 'Hotel', 'Restaurant', 'Aéroport', 'Gare', 'Bus', 'Taxi', 'Train', 'Métro', 'Bateau', 'Voiture', 'Avion', 'Billets', 'Prix', 'Fermé', 'Ouvert'],
      'Hotel': ['Chambre', 'Clé', 'Réception', 'Bagages', 'Ascenseur', 'Escalier', 'WiFi', 'Climatisation', 'Eau chaude', 'Serviettes', 'Coffre-fort'],
      'Restaurant': ['Menu', 'Eau', 'Café', 'Thé', 'Vin', 'Bière', 'Pain', 'Poisson', 'Viande', 'Légumes', 'Fruits', 'Dessert', 'Petit-déjeuner', 'Déjeuner', 'Dîner', 'Je suis végétarien'],
      'Shopping': ['Magasin', 'Marché', 'Prix', 'Soldes', 'Trop cher', 'Payer', 'Espèces', 'Carte', 'Taille', 'Couleur'],
      'Emergency': ['Le médecin', 'Pharmacie', 'Hôpital', 'Police', 'Urgence', 'Ambulance', 'Pompiers', 'J\'ai besoin d\'aide', 'Je suis perdu', 'Je suis malade', 'Fièvre'],
      'Time': ['Quelle heure est-il?', 'Matin', 'Après-midi', 'Soir', 'Minute', 'Heure', 'Jour', 'Semaine', 'Mois', 'Année'],
      'Numbers': ['Un', 'Deux', 'Trois', 'Quatre', 'Cinq', 'Six', 'Sept', 'Huit', 'Neuf', 'Dix', 'Vingt', 'Trente', 'Cent'],
      'Weather': ['Il fait beau', 'Il fait chaud', 'Il fait froid', 'Il pleut', 'Il neige', 'Le soleil', 'La lune', 'Le vent'],
      'Activities': ['Plage', 'Mer', 'Piscine', 'Musée', 'Palace', 'Mosquée', 'Église', 'Monument', 'Plaine', 'Randonnée', 'Baignade', 'Excursion'],
      'Food': ['Kebab', 'Lahmacun', 'Pide', 'Simit', 'Baklava', 'Lokum', 'Döner', 'Köfte', 'Mantı', 'Meze', 'Ayran', 'Şeker'],
    };

    List<Widget> widgets = [];
    
    for (final category in categories.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            category.key,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFFE30A17)
            ),
          ),
        ),
      );
      
      for (final phraseKey in category.value) {
        final translation = phrases[phraseKey];
        if (translation != null) {
          widgets.add(
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(phraseKey, style: const TextStyle(fontSize: 14)),
                subtitle: Text(translation, style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5)
                )),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: () async {
                    await service.speak(translation, _targetLang);
                  },
                ),
                onTap: () {
                  _controller.text = phraseKey;
                  setState(() => _translatedText = translation);
                },
              ),
            ),
          );
        }
      }
    }
    
    return widgets;
  }
}