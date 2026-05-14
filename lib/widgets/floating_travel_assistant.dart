import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/travel_assistant_service.dart';

class FloatingTravelAssistant extends StatefulWidget {
  final VoidCallback onQuickActions;

  const FloatingTravelAssistant({super.key, required this.onQuickActions});

  @override
  State<FloatingTravelAssistant> createState() => _FloatingTravelAssistantState();
}

class _FloatingTravelAssistantState extends State<FloatingTravelAssistant>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isChatMode = false;
  final TextEditingController _chatController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isChatMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistant = context.watch<TravelAssistant>();

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showQuickMenu();
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isExpanded)
              _buildExpandedPanel(assistant),
            _buildFloatingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () {
        widget.onQuickActions();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE30A17).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _isExpanded ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isExpanded ? Icons.close : Icons.support_agent,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(TravelAssistant assistant) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Container(
              height: _isChatMode ? 280 : 260,
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _isChatMode
                    ? _buildChatView(assistant)
                    : _buildMainFeatures(assistant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Assistant Voyage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: _toggleExpanded,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures(TravelAssistant assistant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(assistant),
          const SizedBox(height: 12),
          _buildCitySelector(assistant),
          const SizedBox(height: 12),
          _buildQuickQuestions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(TravelAssistant assistant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _actionChip('💬 Chat',
                () => setState(() => _isChatMode = true)),
            _actionChip('📍 Lieux', () => _showPlacesInfo(assistant)),
            _actionChip('🍽️ Restaurant', () => _showRestaurantInfo(assistant)),
            _actionChip('🚕 Transport', () => _showTransportInfo(assistant)),
            _actionChip('🛍️ Shopping', () => _showShoppingInfo(assistant)),
          ],
        ),
      ],
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE30A17).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildCitySelector(TravelAssistant assistant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ville',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _cityButton('Istanbul', '🏛️',
                  assistant.currentCity == 'Istanbul', () {
                assistant.setCity('Istanbul');
                HapticFeedback.selectionClick();
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _cityButton('Antalya', '🏖️',
                  assistant.currentCity == 'Antalya', () {
                assistant.setCity('Antalya');
                HapticFeedback.selectionClick();
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cityButton(String city, String emoji, bool isSelected,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE30A17) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji),
            const SizedBox(width: 4),
            Text(city,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    final questions = ['Que voir?', 'Restaurants?', 'Transport?', 'Shopping?'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Questions rapides',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: questions
              .map((q) => GestureDetector(
                    onTap: () => _answerQuestion(q),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(q, style: const TextStyle(fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _answerQuestion(String question) {
    final assistant = context.read<TravelAssistant>();
    final city = assistant.currentCity;

    String answer = '';
    if (question.contains('voir')) {
      answer = city == 'Istanbul'
          ? '🏛️ Sainte-Sophie, Mosquée Bleue, Palais Topkapi, Grand Bazar, Tour de Galata'
          : '🏖️ Kaleici, Plage de Lara, Cascade de Düden, Aspendos, Musée d\'Antalya';
    } else if (question.contains('Restaurant')) {
      answer = city == 'Istanbul'
          ? '🍽️ Karaköy Lokantasi, Çiya Sofrasi, Balık Pazarı, Karadeniz Pidecisi'
          : '🍽️ Meyo, Lara Köfte, Ser上一, Dondurma';
    } else if (question.contains('Transport')) {
      answer = '🚋 Métro, Bateau (Vapur), Taxi, Dolmuş, Walk';
    } else if (question.contains('Shopping')) {
      answer = city == 'Istanbul'
          ? '🛍️ Grand Bazar, Istinye Park, Arasta Bazaar, Nisantasi'
          : '🛍️ Mall of Antalya, Lara AVM, Kaleici bazar';
    }

    _showAnswerDialog(answer);
  }

  void _showAnswerDialog(String answer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Color(0xFFE30A17)),
            SizedBox(width: 8),
            Text('Réponse'),
          ],
        ),
        content: Text(answer),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(TravelAssistant assistant) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildChatBubble(
                  'Bonjour! Comment puis-je vous aider?',
                  isUser: false),
              _buildChatBubble(
                  'Je veux découvrir les lieux touristiques',
                  isUser: true),
              _buildChatBubble(
                  'Parfait! Ville: ${assistant.currentCity}. Types: Histoire, Gastronomie, Shopping, Nature?',
                  isUser: false),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(assistant),
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.send, color: Color(0xFFE30A17)),
                onPressed: () => _sendMessage(assistant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String message, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE30A17) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey[800],
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _sendMessage(TravelAssistant assistant) {
    if (_chatController.text.isEmpty) return;

    final message = _chatController.text;
    _chatController.clear();

    _answerQuestion(message.contains('voir')
        ? 'Que voir?'
        : message.contains('restaurant')
            ? 'Restaurant?'
            : message.contains('transport')
                ? 'Transport?'
                : 'Que voir?');
  }

  void _showQuickMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.chat, color: Color(0xFFE30A17)),
              title: const Text('Ouvrir le chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isExpanded = true;
                  _isChatMode = true;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city,
                  color: Color(0xFFE30A17)),
              title: const Text('Changer de ville'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.info_outline, color: Color(0xFFE30A17)),
              title: const Text('À propos'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlacesInfo(TravelAssistant assistant) {
    final city = assistant.currentCity;
    String info = city == 'Istanbul'
        ? '🏛️ Sainte-Sophie, Mosquée Bleue (Sultan Ahmed), Palais Topkapi, Grand Bazar, Basilique Cistern, Tour de Galata, Palais Dolmabahçe'
        : '🏛️ Kaleici (vieux ville), Hadrien\'s Gate, Clock Tower, Musée d\'Antalya, Plage de Konyaaltı, Plage de Lara';
    _showAnswerDialog(info);
  }

  void _showRestaurantInfo(TravelAssistant assistant) {
    final city = assistant.currentCity;
    String info = city == 'Istanbul'
        ? '🍽️ Karaköy Lokantasi (cuisine ottomane), Çiya Sofrasi (cuisine locale), Balık Pazarı (poisson), Karadeniz Pidecisi (pide), Mikla ( rooftop)'
        : '🍽️ Meyo (grillades), Lara Köfte (köfte), Ser上一 (poisson), The Shed (moderne), Dondurma (glace turque)';
    _showAnswerDialog(info);
  }

  void _showTransportInfo(TravelAssistant assistant) {
    final city = assistant.currentCity;
    String info = city == 'Istanbul'
        ? '🚋 Métro + Tramway (Istanbulkart), Bateau (Vapur) pour Bosphore, Taxi (Bitaksi), Dolmuş (minibus), Walk pour les quartiers'
        : '🚋 Métro à Antalya, Bus (Aktur), Taxi, Dolmuş, Location de voiture';
    _showAnswerDialog(info);
  }

  void _showShoppingInfo(TravelAssistant assistant) {
    final city = assistant.currentCity;
    String info = city == 'Istanbul'
        ? '🛍️ Grand Bazar (traditionnel), Istinye Park (moderne), Arasta Bazaar (artisanat), Nisantasi (mode), Mall of Istanbul'
        : '🛍️ Mall of Antalya, Lara AVM, Kaleici (artisanat), Mark Antalya (centre-ville)';
    _showAnswerDialog(info);
  }
}