import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/voice_journal/models/voice_journal_models.dart';

class VoiceJournalService extends ChangeNotifier {
  List<VoiceNote> _notes = [];
  bool _isLoading = false;
  bool _isRecording = false;
  int _recordingDuration = 0;

  List<VoiceNote> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  int get recordingDuration => _recordingDuration;

  VoiceJournalService() {
    _load();
  }

  void _load() {
    _isLoading = true;
    notifyListeners();

    final jsonList = LocalStorage.getJsonList('voice_notes');
    if (jsonList != null) {
      _notes = jsonList.map((j) => VoiceNote.fromJson(j)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    _isLoading = false;
    notifyListeners();
  }

  void _save() {
    LocalStorage.setJsonList('voice_notes',
      _notes.map((n) => n.toJson()).toList());
  }

  Future<void> startRecording() async {
    _isRecording = true;
    _recordingDuration = 0;
    notifyListeners();
  }

  Future<VoiceNote?> stopRecording() async {
    if (!_isRecording) return null;

    _isRecording = false;
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/voice_notes');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = '${audioDir.path}/note_$id.m4a';
      final file = File(filePath);
      await file.writeAsString('');

      final note = VoiceNote(
        id: id,
        filePath: filePath,
        durationSeconds: _recordingDuration,
        date: DateTime.now(),
      );

      _notes.insert(0, note);
      _save();
      notifyListeners();
      return note;
    } catch (e) {
      LogService.error('VoiceJournal', 'Failed to save recording: $e');
      return null;
    }
  }

  void cancelRecording() {
    _isRecording = false;
    _recordingDuration = 0;
    notifyListeners();
  }

  void updateRecordingDuration(int seconds) {
    _recordingDuration = seconds;
    notifyListeners();
  }

  Future<void> transcribeNote(String id, String transcript) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        transcript: transcript,
        isTranscribed: true,
      );
      _save();
      notifyListeners();
    }
  }

  void linkToJournalEntry(String noteId, String journalEntryId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(journalEntryId: journalEntryId);
      _save();
      notifyListeners();
    }
  }

  void setNoteLocation(String noteId, String location) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(location: location);
      _save();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      try {
        final file = File(_notes[index].filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        LogService.warning('VoiceJournal', 'Failed to delete audio file: $e');
      }
      _notes.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  VoiceNote? getNote(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<VoiceNote> getNotesLinkedToEntry(String journalEntryId) {
    return _notes.where((n) => n.journalEntryId == journalEntryId).toList();
  }

  List<VoiceNote> search(String query) {
    final q = query.toLowerCase();
    return _notes.where((n) {
      if (n.transcript != null && n.transcript!.toLowerCase().contains(q)) return true;
      if (n.location != null && n.location!.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  Future<void> playbackNote(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        LogService.info('VoiceJournal', 'Playing audio: $filePath');
      }
    } catch (e) {
      LogService.error('VoiceJournal', 'Playback failed: $e');
    }
  }

  void updateNoteDuration(String id, int durationSeconds) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(durationSeconds: durationSeconds);
      _save();
      notifyListeners();
    }
  }

  void clearAll() {
    _notes.clear();
    _save();
    notifyListeners();
  }
}
