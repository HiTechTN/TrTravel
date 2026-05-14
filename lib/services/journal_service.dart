import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class JournalService extends ChangeNotifier {
  static const String _journalEntriesKey = 'journal_entries';

  Future<List<JournalEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings = prefs.getStringList(_journalEntriesKey);
    if (jsonStrings == null || jsonStrings.isEmpty) {
      return [];
    }
    return jsonStrings
        .map((jsonString) => JournalEntry.fromJson(json.decode(jsonString)))
        .toList();
  }

  Future<void> saveEntry(JournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings = prefs.getStringList(_journalEntriesKey);
    final List<String> updatedJsonStrings = (jsonStrings ?? [])..add(json.encode(entry.toJson()));
    await prefs.setStringList(_journalEntriesKey, updatedJsonStrings);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings = prefs.getStringList(_journalEntriesKey);
    if (jsonStrings == null) return;
    final List<String> updatedJsonStrings = jsonStrings
        .where((jsonString) {
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          return jsonMap['id'] != id;
        })
        .toList();
    await prefs.setStringList(_journalEntriesKey, updatedJsonStrings);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await deleteEntry(entry.id);
    await saveEntry(entry);
  }
}