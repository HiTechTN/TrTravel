import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';

class AddJournalScreen extends StatefulWidget {
  const AddJournalScreen({super.key});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _tags = <String>[];
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _locationCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagCtrl.clear();
    }
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

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      context.showSnackBar('Veuillez ajouter un titre');
      return;
    }

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      tags: List.of(_tags),
    );

    context.read<JournalService>().addEntry(entry);
    context.showSnackBar('Entrée ajoutée !');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Nouvelle entrée',
            subtitle: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            icon: Icons.edit_rounded,
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
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        hintText: 'Qu\'avez-vous fait aujourd\'hui ?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentCtrl,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Récit',
                        hintText: 'Racontez votre journée...',
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lieu (optionnel)',
                        hintText: 'Où étiez-vous ?',
                        prefixIcon: Icon(Icons.location_on),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _pickDate,
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tags (optionnel)',
                              hintText: 'Ajouter un tag',
                              prefixIcon: Icon(Icons.label),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _tags.map((t) => Chip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        )).toList(),
                      ),
                    ),
                  ],
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

extension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
