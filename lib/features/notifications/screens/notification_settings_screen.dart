import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/notifications/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _placeController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _placeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _createGeofenceReminder() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final place = _placeController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (title.isEmpty || body.isEmpty || place.isEmpty || lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final service = context.read<NotificationService>();
    service.createGeofenceReminder(
      id: 'geo_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      placeName: place,
      latitude: lat,
      longitude: lng,
    );

    _clearFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rappel géolocalisé créé !'), behavior: SnackBarBehavior.floating),
    );
  }

  void _createTimeReminder() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le titre et le message'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    final service = context.read<NotificationService>();
    service.createTimeReminder(
      id: 'time_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      scheduledAt: scheduledAt,
    );

    _clearFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rappel temporel créé !'), behavior: SnackBarBehavior.floating),
    );
  }

  void _clearFields() {
    _titleController.clear();
    _bodyController.clear();
    _placeController.clear();
    _latController.clear();
    _lngController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.settings,
            subtitle: 'Gérer les notifications',
            icon: Icons.settings_rounded,
          ),
          Expanded(
            child: Consumer<NotificationService>(
              builder: (_, service, __) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Créer un rappel géolocalisé',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(labelText: 'Message'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeController,
                      decoration: const InputDecoration(labelText: 'Nom du lieu'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latController,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _lngController,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _createGeofenceReminder,
                      icon: const Icon(Icons.location_on_rounded),
                      label: const Text('Ajouter rappel géolocalisé'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Créer un rappel temporel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _createTimeReminder,
                      icon: const Icon(Icons.access_alarm_rounded),
                      label: const Text('Choisir date et heure'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Rappels actifs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (service.reminders.isEmpty)
                      const Text('Aucun rappel actif', style: TextStyle(color: AppColors.textSecondary))
                    else
                      ...service.reminders.map((r) => ListTile(
                        title: Text(r.title),
                        subtitle: Text(r.isGeofence ? 'Géolocalisé: ${r.placeName}' : 'Temporel'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => service.removeReminder(r.id),
                        ),
                      )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
