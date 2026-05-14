import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? initialEntry;

  const AddJournalScreen({
    super.key,
    this.initialEntry,
  });

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _locationController =
        TextEditingController(text: entry?.location ?? '');
    _tagsController = TextEditingController(
        text: entry?.tags.isNotEmpty == true ? entry!.tags.join(', ') : '');
    _selectedDate = entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = JournalEntry(
        id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        tags: _tagsController.text.trim().isEmpty
            ? []
            : _tagsController.text
                .trim()
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
      );

      final journalService =
          Provider.of<JournalService>(context, listen: false);
      final Future<void> saveOp = widget.initialEntry != null
          ? journalService.updateEntry(entry)
          : journalService.saveEntry(entry);
      saveOp.then((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialEntry == null ? 'Nouvelle entrée' : 'Modifier l entrée'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Date: ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer du contenu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (séparés par des virgules, optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}