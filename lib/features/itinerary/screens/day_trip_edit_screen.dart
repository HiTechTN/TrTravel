import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/features/itinerary/models/day_trip.dart';
import 'package:trtravel/features/itinerary/services/itinerary_service.dart';

class DayTripEditScreen extends StatefulWidget {
  final String tripId;
  final String dayTripId;

  const DayTripEditScreen({
    super.key,
    required this.tripId,
    required this.dayTripId,
  });

  @override
  State<DayTripEditScreen> createState() => _DayTripEditScreenState();
}

class _DayTripEditScreenState extends State<DayTripEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late List<_EntryController> _entryControllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final service = context.read<ItineraryService>();
    final trip = service.getTrip(widget.tripId);
    final day = trip?.days.firstWhere((d) => d.id == widget.dayTripId);

    _titleController = TextEditingController(text: day?.title ?? '');
    _dateController = TextEditingController(text: day?.date ?? '');
    _locationController = TextEditingController(text: day?.location ?? '');

    _entryControllers = (day?.entries ?? []).map((e) => _EntryController(
      timeController: TextEditingController(text: e.time),
      activityController: TextEditingController(text: e.activity),
      entryId: e.id,
    )).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    for (final ec in _entryControllers) {
      ec.timeController.dispose();
      ec.activityController.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entryControllers.add(_EntryController(
        timeController: TextEditingController(),
        activityController: TextEditingController(),
        entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entryControllers[index].timeController.dispose();
      _entryControllers[index].activityController.dispose();
      _entryControllers.removeAt(index);
    });
  }

  void _save() {
    final service = context.read<ItineraryService>();
    final trip = service.getTrip(widget.tripId);
    if (trip == null) return;

    final updatedDay = DayTrip(
      id: widget.dayTripId,
      dayNumber: trip.days.firstWhere((d) => d.id == widget.dayTripId).dayNumber,
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      location: _locationController.text.trim(),
      entries: _entryControllers
          .where((ec) => ec.activityController.text.trim().isNotEmpty)
          .map((ec) => ScheduleEntry(
                id: ec.entryId,
                time: ec.timeController.text.trim(),
                activity: ec.activityController.text.trim(),
              ))
          .toList(),
    );

    service.updateDayTrip(widget.tripId, updatedDay);
    context.showSnackBar('Journée mise à jour');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final day = context
        .read<ItineraryService>()
        .getTrip(widget.tripId)
        ?.days
        .firstWhere((d) => d.id == widget.dayTripId);

    final dayColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.gold,
      AppColors.success,
      AppColors.mosque,
    ];
    final color = dayColors[(day?.dayNumber ?? 1) % dayColors.length];

    return Scaffold(
      appBar: AppBar(
        title: Text('Jour ${day?.dayNumber ?? ''}'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: _inputDecoration('Titre', 'Ex: Visite d\'Istanbul'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateController,
                  decoration: _inputDecoration('Date', 'Ex: Lundi 13 Juillet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: _inputDecoration('Lieu', 'Ex: Istanbul'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Programme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._entryControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final ec = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: ec.timeController,
                      decoration: _inputDecoration('Heure', '09H00'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ec.activityController,
                      decoration: _inputDecoration('Activité', 'Petit déjeuner'),
                      maxLines: null,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _removeEntry(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            );
          }),
          if (_entryControllers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aucune activité. Appuyez sur "Ajouter" pour commencer.',
                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }
}

class _EntryController {
  final TextEditingController timeController;
  final TextEditingController activityController;
  final String entryId;

  _EntryController({
    required this.timeController,
    required this.activityController,
    required this.entryId,
  });
}
