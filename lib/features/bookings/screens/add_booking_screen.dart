import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../services/booking_service.dart';
import '../models/booking_models.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  BookingType _selectedType = BookingType.hotel;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _currency = 'TRY';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _confirmCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter un titre'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: dateTime,
      location: _locationCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      currency: _currency,
      confirmationCode: _confirmCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    context.read<BookingService>().addBooking(booking);
    context.read<BookingService>().createDefaultReminders(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation ajoutée !'), behavior: SnackBarBehavior.floating),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Nouvelle réservation',
            subtitle: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            icon: Icons.add_circle_rounded,
            actions: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: _save,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type de réservation', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: BookingType.values.map((type) => ChoiceChip(
                      avatar: Text(type.emoji),
                      label: Text(type.label),
                      selected: _selectedType == type,
                      onSelected: (_) => setState(() => _selectedType = type),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Titre', hintText: 'Nom de l\'hôtel, activité...'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnelle)',
                      hintText: 'Détails supplémentaires',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lieu',
                      hintText: 'Adresse ou lieu',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix',
                            hintText: '0',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_currency),
                          initialValue: _currency,
                          decoration: const InputDecoration(labelText: 'Devise'),
                          items: ['TRY', 'EUR', 'USD', 'GBP', 'TND'].map((c) =>
                            DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _currency = v ?? 'TRY'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Code de confirmation (optionnel)',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optionnelles)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Heure',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: Text(l.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
