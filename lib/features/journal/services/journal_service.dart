import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/features/journal/models/journal_entry.dart';

class JournalService extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  JournalService() {
    _load();
  }

  void _load() {
    _isLoading = true;
    notifyListeners();

    final jsonList = LocalStorage.getJsonList('journal_entries');
    if (jsonList != null) {
      _entries = jsonList.map((j) => JournalEntry.fromJson(j)).toList()..sort((a, b) => b.date.compareTo(a.date));
    }

    _isLoading = false;
    notifyListeners();
  }

  void _save() {
    final jsonList = _entries.map((e) => e.toJson()).toList();
    LocalStorage.setJsonList('journal_entries', jsonList);
  }

  void addEntry(JournalEntry entry) {
    _entries.insert(0, entry);
    _save();
    notifyListeners();
  }

  void updateEntry(JournalEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entry.updatedAt = DateTime.now();
      _entries[index] = entry;
      _save();
      notifyListeners();
    }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  JournalEntry? getEntry(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<JournalEntry> search(String query) {
    final q = query.toLowerCase();
    return _entries.where((e) =>
      e.title.toLowerCase().contains(q) ||
      e.content.toLowerCase().contains(q) ||
      e.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  List<JournalEntry> filterByTag(String tag) {
    return _entries.where((e) => e.tags.contains(tag)).toList();
  }
}
