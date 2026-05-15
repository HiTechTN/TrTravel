import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackingChecklistScreen extends StatefulWidget {
  const PackingChecklistScreen({super.key});

  @override
  State<PackingChecklistScreen> createState() => _PackingChecklistScreenState();
}

class _PackingChecklistScreenState extends State<PackingChecklistScreen> {
  Map<String, List<_ChecklistItem>> _categories = {};
  bool _loaded = false;
  double _progress = 0;

  static const _defaultItems = {
    'V\u00EAtements': [
      'T-shirts l\u00E9gers (4-5)',
      'Chemises manches longues (2)',
      'Pantalons l\u00E9gers (3)',
      'Short (2-3)',
      'Robe/sandales pour le soir',
      'Veste l\u00E9g\u00E8re ou sweat',
      'Impermeable / K-Way',
      'Sous-v\u00EAtements (7+)',
      'Chaussettes (7 paires)',
      'Maillot de bain (2)',
      'Pyjama',
      'Chaussures de marche',
      'Sandales / Tongues',
      'Chapeau / Casquette',
      'Foulard / \u00C9tole (mosqu\u00E9es)',
    ],
    'Documents': [
      'Passeport (valide 6 mois)',
      'Visa \u00E9lectronique (e-Visa) imprim\u00E9',
      'Billets d\'avion (copies)',
      'Assurance voyage',
      'Permis de conduire international',
      'R\u00E9servations h\u00F4tel (confirmations)',
      'Cartes bancaires (2 minimum)',
      'Esp\u00E8ces (Euros / Dollars / Lires)',
      'Copies des documents (21 cm)',
    ],
    '\u00C9lectronique': [
      'T\u00E9l\u00E9phone + chargeur',
      'Carte SIM turque / eSIM',
      'Adaptateur prise (Type F)',
      'Batterie externe (power bank)',
      '\u00C9couteurs / Casque',
      'Appareil photo',
      'C\u00E2bles USB (2+)',
      'Tablette / ordinateur (optionnel)',
    ],
    'Toilette': [
      'Brosse \u00E0 dents + dentifrice',
      'Shampoing + apr\u00E8s-shampoing',
      'Gel douche + savon',
      'D\u00E9odorant',
      'Protection solaire (SPF50+)',
      'Apr\u00E8s-soleil',
      'Anti-moustique',
      'Lingettes humides',
      'Gel hydroalcoolique',
      'Mouchoirs en paquet',
      'Serviette microfibre (voyage)',
      'N\u00E9cessaire \u00E0 raser',
      'Trousse \u00E0 pharmacie',
    ],
    'Pharmacie': [
      'Parac\u00E9tamol / Ibuprof\u00E8ne',
      'Antihistaminique (allergies)',
      'Traitement intestinal (Smecta)',
      'M\u00E9dicaments personnels',
      'Ordonnances (traduites)',
      'Pansements + d\u00E9sinfectant',
      'Bandes \u00E9lastiques',
      'S\u00E9rum physiologique',
    ],
    'Plage & Baignade': [
      'Serviette de plage',
      'Masque + tuba',
      'Cr\u00E8me solaire waterproof',
      'Sac \u00E9tanche (t\u00E9l\u00E9phone)',
      'Lunettes de soleil',
      'Bouchons d\'oreilles (natation)',
    ],
    'Divers': [
      'Sac \u00E0 dos de jour (daypack)',
      'Sac de voyage pliable',
      'Cadenas (pour casiers)',
      'Guide de voyage / carte',
      'Carnet + stylo',
      'Gourde r\u00E9utilisable',
      'Lama de poche',
      'Couvertures pliables',
      'Sacs poubelle (linge sale)',
      '\u00C9lastiques / attaches',
    ],
    'Ramadan (si concern\u00E9)': [
      'Applications horaires pri\u00E8re',
      'Collations pour rupture du je\u00FBne',
      'V\u00EAtements couvrants suppl\u00E9mentaires',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('packing_checklist');
    if (saved != null) {
      final decoded = json.decode(saved) as Map<String, dynamic>;
      _categories = decoded.map((k, v) => MapEntry(k, (v as List).map((e) => _ChecklistItem.fromJson(e)).toList()));
    } else {
      _categories = _defaultItems.map((k, v) => MapEntry(k, v.map((e) => _ChecklistItem(e)).toList()));
    }
    _updateProgress();
    setState(() => _loaded = true);
  }

  Future<void> _saveChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_categories.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    await prefs.setString('packing_checklist', encoded);
  }

  Future<void> _toggleItem(String category, int index) async {
    setState(() {
      _categories[category]![index].checked = !_categories[category]![index].checked;
      _updateProgress();
    });
    await _saveChecklist();
  }

  Future<void> _addItem(String category) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom de l\'article',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _categories[category]!.add(_ChecklistItem(result));
        _updateProgress();
      });
      await _saveChecklist();
    }
  }

  Future<void> _removeItem(String category, int index) async {
    final item = _categories[category]![index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer \u00AB ${item.name} \u00BB ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _categories[category]!.removeAt(index);
        _updateProgress();
      });
      await _saveChecklist();
    }
  }

  Future<void> _resetChecklist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('R\u00E9initialiser'),
        content: const Text('Cocher tout ou r\u00E9initialiser ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tout cocher')),
          FilledButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tout d\u00E9cocher')),
        ],
      ),
    );
    if (confirm != null) {
      setState(() {
        for (final items in _categories.values) {
          for (final item in items) {
            item.checked = confirm;
          }
        }
        _updateProgress();
      });
      await _saveChecklist();
    }
  }

  void _updateProgress() {
    int total = 0, checked = 0;
    for (final items in _categories.values) {
      for (final item in items) {
        total++;
        if (item.checked) checked++;
      }
    }
    _progress = total > 0 ? checked / total : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B9A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.checklist, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text('Checklist de bagages',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${(_progress * 100).toInt()}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _resetChecklist),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categories.entries.map((entry) => _buildCategory(entry.key, entry.value)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String name, List<_ChecklistItem> items) {
    final checkedCount = items.where((i) => i.checked).length;
    final catProgress = items.isNotEmpty ? checkedCount / items.length : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A2E))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$checkedCount/${items.length}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: catProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        catProgress == 1 ? Colors.green : const Color(0xFF6A1B9A),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _addItem(name),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.add_circle_outline, size: 22, color: Color(0xFF6A1B9A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Dismissible(
              key: Key('${item.name}_$i'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.shade100,
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              onDismissed: (_) => _removeItem(name, i),
              child: InkWell(
                onTap: () => _toggleItem(name, i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: item.checked ? const Color(0xFF6A1B9A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: item.checked ? const Color(0xFF6A1B9A) : Colors.grey[400]!),
                        ),
                        child: item.checked
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: item.checked ? Colors.grey[400] : Colors.grey[800],
                            decoration: item.checked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (item.checked)
                        Icon(Icons.check_circle, color: Colors.green[400], size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChecklistItem {
  final String name;
  bool checked;

  _ChecklistItem(this.name, {this.checked = false});

  factory _ChecklistItem.fromJson(Map<String, dynamic> json) {
    return _ChecklistItem(json['name'] as String, checked: json['checked'] as bool? ?? false);
  }

  Map<String, dynamic> toJson() => {'name': name, 'checked': checked};
}
