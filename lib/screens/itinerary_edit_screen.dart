import 'package:flutter/material.dart';
import '../models/itinerary.dart';

class ItineraryEditScreen extends StatefulWidget {
  final ItineraryItem? existingItem;

  const ItineraryEditScreen({super.key, this.existingItem});

  @override
  State<ItineraryEditScreen> createState() => _ItineraryEditScreenState();
}

class _ItineraryEditScreenState extends State<ItineraryEditScreen> {
  late TextEditingController _dateController;
  late TextEditingController _dayNameController;
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  final List<Map<String, String>> _activities = [];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.existingItem?.date ?? '',
    );
    _dayNameController = TextEditingController(
      text: widget.existingItem?.dayName ?? '',
    );
    _locationController = TextEditingController(
      text: widget.existingItem?.location ?? '',
    );
    _timeController = TextEditingController();
    _descriptionController = TextEditingController();
    _detailsController = TextEditingController();

    if (widget.existingItem != null) {
      for (final a in widget.existingItem!.activities) {
        _activities.add({'time': a.time, 'description': a.description, 'details': a.details ?? ''});
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dayNameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _addActivity() {
    if (_descriptionController.text.isEmpty) return;
    setState(() {
      _activities.add({
        'time': _timeController.text,
        'description': _descriptionController.text,
        'details': _detailsController.text,
      });
      _timeController.clear();
      _descriptionController.clear();
      _detailsController.clear();
    });
  }

  void _removeActivity(int index) {
    setState(() => _activities.removeAt(index));
  }

  Future<void> _save() async {
    if (_dateController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
      );
      return;
    }

    final result = {
      'date': _dateController.text,
      'dayName': _dayNameController.text,
      'location': _locationController.text,
      'activities': _activities,
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le jour' : 'Ajouter un jour'),
        backgroundColor: const Color(0xFFE30A17),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations du jour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        hintText: 'Ex: 15 JUILLET 2026',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du jour',
                        hintText: 'Ex: SAMEDI',
                        prefixIcon: Icon(Icons.today),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu/Itinéraire *',
                        hintText: 'Ex: ISTANBUL -> ANTALYA',
                        prefixIcon: Icon(Icons.place),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ajouter une activité', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              hintText: 'Heure',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        hintText: 'Détails (optionnel)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addActivity,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter activité'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE30A17),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_activities.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activités (${_activities.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...List.generate(_activities.length, (i) {
                        final act = _activities[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  act['time']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFFE30A17),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      act['description']!,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (act['details']!.isNotEmpty)
                                      Text(
                                        act['details']!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _removeActivity(i),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30A17),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                isEditing ? 'Enregistrer les modifications' : 'Ajouter ce jour',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}