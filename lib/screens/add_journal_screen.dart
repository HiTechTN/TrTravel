import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? initialEntry;

  const AddJournalScreen({super.key, this.initialEntry});

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
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _locationController = TextEditingController(text: entry?.location ?? '');
    _tagsController = TextEditingController(
        text: entry?.tags.isNotEmpty == true ? entry!.tags.join(', ') : '');
    _selectedDate = entry?.date ?? DateTime.now();
    _photoPaths = List<String>.from(entry?.photos ?? []);
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
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    await File(image.path).copy(savedPath);

    setState(() => _photoPaths.add(savedPath));
  }

  Future<void> _removePhoto(int index) async {
    setState(() => _photoPaths.removeAt(index));
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = JournalEntry(
        id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        photos: _photoPaths,
        tags: _tagsController.text.trim().isEmpty
            ? []
            : _tagsController.text.trim().split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      );

      final journalService = Provider.of<JournalService>(context, listen: false);
      final saveOp = widget.initialEntry != null
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
        title: Text(widget.initialEntry == null ? 'Nouvelle entr\u00E9e' : 'Modifier l\'entr\u00E9e'),
        backgroundColor: const Color(0xFF003B66),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Color(0xFF003B66)),
                title: Text('Date: ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un titre';
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
                  if (value == null || value.isEmpty) return 'Veuillez entrer du contenu';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lieu (optionnel)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (s\u00E9par\u00E9s par des virgules)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.photo_library, size: 20, color: Color(0xFF003B66)),
                  const SizedBox(width: 8),
                  const Text('Photos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A1A2E))),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo, size: 18),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              if (_photoPaths.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, size: 40, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Aucune photo', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoPaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_photoPaths[i]),
                            width: 120, height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(i),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
