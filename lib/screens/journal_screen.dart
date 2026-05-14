import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import 'add_journal_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  Future<List<JournalEntry>>? _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture =
        Provider.of<JournalService>(context, listen: false).loadEntries();
  }

  void _refreshEntries() {
    setState(() {
      _entriesFuture =
          Provider.of<JournalService>(context, listen: false).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de voyage'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune entrée de journal pour le moment'),
            );
          } else {
            final entries = snapshot.data!;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        entry.formattedDate.substring(0, 2),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(entry.title),
                    subtitle: Text(
                      '${entry.formattedDate} ${entry.location != null ? ' - ${entry.location}' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JournalDetailScreen(
                            entry: entry,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => const AddJournalScreen(),
                ),
              )
              .then((_) => _refreshEntries());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.formattedDate,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              entry.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (entry.location != null && entry.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '📍 ${entry.location}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            if (entry.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: entry.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                Colors.blueAccent.withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => AddJournalScreen(
                    initialEntry: entry,
                  ),
                ),
              )
              .then((_) {
            // Refresh handled by parent's _refreshEntries
          });
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
