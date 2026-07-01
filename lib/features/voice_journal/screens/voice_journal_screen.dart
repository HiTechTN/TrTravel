import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import '../services/voice_journal_service.dart';
import '../models/voice_journal_models.dart';
import '../widgets/voice_recorder.dart';
import '../widgets/voice_note_tile.dart';

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  State<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Journal Vocal',
            subtitle: 'Enregistrez vos souvenirs',
            icon: Icons.mic_rounded,
          ),
          Consumer<VoiceJournalService>(
            builder: (_, service, __) {
              final notes = _searchQuery.isEmpty
                  ? service.notes
                  : service.search(_searchQuery);

              return Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    if (service.isRecording)
                      VoiceRecorder(
                        duration: service.recordingDuration,
                        onStop: () async {
                          await service.stopRecording();
                        },
                        onCancel: () => service.cancelRecording(),
                      ),
                    Expanded(
                      child: notes.isEmpty
                          ? AppEmpty(
                              icon: Icons.mic_none_rounded,
                              title: 'Aucun enregistrement',
                              subtitle: 'Appuyez sur le microphone pour enregistrer',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: notes.length,
                              itemBuilder: (_, i) => VoiceNoteTile(
                                note: notes[i],
                                onTap: () => _showNoteDetails(context, notes[i], service),
                                onDelete: () => _confirmDelete(context, notes[i], service),
                                onPlay: () => service.playbackNote(notes[i].filePath),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Consumer<VoiceJournalService>(
        builder: (_, service, __) {
          if (service.isRecording) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => service.startRecording(),
            child: const Icon(Icons.mic),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  void _showNoteDetails(BuildContext context, VoiceNote note, VoiceJournalService service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.divider, borderRadius: BorderRadius.circular(2),
            ))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.audiotrack, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.formattedDuration,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${note.date.day}/${note.date.month}/${note.date.year}',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_filled, size: 40, color: AppColors.primary),
                  onPressed: () => service.playbackNote(note.filePath),
                ),
              ],
            ),
            if (note.isTranscribed && note.transcript != null) ...[
              const SizedBox(height: 16),
              const Text('Transcription', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(note.transcript!, style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
              ),
            ],
            if (note.location != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(note.location!, style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoiceNote note, VoiceJournalService service) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.delete),
        content: const Text('Supprimer cet enregistrement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              service.deleteNote(note.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }
}
