import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/itinerary.dart';
import '../services/itinerary_service.dart';

class ItineraryScreen extends StatefulWidget {
  final ItineraryItem itinerary;

  const ItineraryScreen({super.key, required this.itinerary});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  late ItineraryItem _current;

  @override
  void initState() {
    super.initState();
    _current = widget.itinerary;
  }

  void _showActivityDialog({Activity? existing, int? index}) {
    final timeCtrl = TextEditingController(text: existing?.time ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final detailsCtrl = TextEditingController(text: existing?.details ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Modifier l\'activité' : 'Nouvelle activité',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Heure',
                  hintText: 'Ex: 09:00',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Ex: Visite de la Mosquée',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Détails (optionnel)',
                  hintText: 'Informations complémentaires',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lieu (optionnel)',
                  hintText: 'Ex: Sultanahmet',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (descCtrl.text.trim().isEmpty) return;
                  final activity = Activity(
                    time: timeCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    details: detailsCtrl.text.trim().isEmpty ? null : detailsCtrl.text.trim(),
                    location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  if (isEdit) {
                    _updateActivity(index!, activity);
                  } else {
                    _addActivity(activity);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE30A17),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
                child: Text(
                  isEdit ? 'Enregistrer' : 'Ajouter',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addActivity(Activity activity) async {
    final service = context.read<ItineraryService>();
    await service.addActivityToDay(_current, activity);
    final updated = ItineraryItem(
      date: _current.date,
      dayName: _current.dayName,
      location: _current.location,
      activities: [..._current.activities, activity],
    );
    setState(() => _current = updated);
  }

  Future<void> _updateActivity(int index, Activity activity) async {
    final service = context.read<ItineraryService>();
    await service.updateActivityInDay(_current, index, activity);
    final newActivities = List<Activity>.from(_current.activities);
    newActivities[index] = activity;
    setState(() {
      _current = ItineraryItem(
        date: _current.date,
        dayName: _current.dayName,
        location: _current.location,
        activities: newActivities,
      );
    });
  }

  Future<void> _deleteActivity(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette activité?'),
        content: Text('Voulez-vous supprimer "${_current.activities[index].description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final service = context.read<ItineraryService>();
      await service.deleteActivityFromDay(_current, index);
      final newActivities = List<Activity>.from(_current.activities)..removeAt(index);
      setState(() {
        _current = ItineraryItem(
          date: _current.date,
          dayName: _current.dayName,
          location: _current.location,
          activities: newActivities,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_current.location),
        backgroundColor: const Color(0xFFE30A17),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _current.dayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _current.date,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const Divider(height: 32),
          if (_current.activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune activité\nAppuyez sur + pour ajouter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_current.activities.length, (i) {
              final activity = _current.activities[i];
              return Dismissible(
                key: Key('${_current.date}_$i'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  await _deleteActivity(i);
                  return false;
                },
                child: InkWell(
                  onTap: () => _showActivityDialog(existing: activity, index: i),
                  onLongPress: () => _showActivityMenu(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity.time,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFFE30A17),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              if (activity.details != null && activity.details!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    activity.details!,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ),
                              if (activity.location != null && activity.location!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '📍 ${activity.location}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showActivityDialog(existing: activity, index: i);
                            } else if (value == 'delete') {
                              _deleteActivity(i);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActivityDialog(),
        backgroundColor: const Color(0xFFE30A17),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showActivityMenu(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(ctx);
                _showActivityDialog(existing: _current.activities[index], index: index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteActivity(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
