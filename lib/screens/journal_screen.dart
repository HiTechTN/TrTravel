import 'dart:io';
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
    _entriesFuture = Provider.of<JournalService>(context, listen: false).loadEntries();
  }

  void _refreshEntries() {
    setState(() {
      _entriesFuture = Provider.of<JournalService>(context, listen: false).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: const Color(0xFF003B66),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF003B66), Color(0xFF005B99)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.book, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Journal de voyage',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddJournalScreen())).then((_) => _refreshEntries());
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Colors.white, size: 18),
                                    SizedBox(width: 4),
                                    Text('Nouveau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<List<JournalEntry>>(
                future: _entriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucune entr\u00E9e de journal', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Cr\u00E9ez votre premier souvenir !', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      ],
                    );
                  }
                  final entries = snapshot.data!;
                  return Column(
                    children: entries.map((entry) => _buildEntryCard(entry)).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: entry))).then((_) => _refreshEntries());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B66).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(entry.formattedDate.substring(0, 2), style: const TextStyle(color: Color(0xFF003B66), fontWeight: FontWeight.w800, fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.formattedDate}${entry.location != null ? ' \u2022 ${entry.location}' : ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    if (entry.photos.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B66).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${entry.photos.length}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.content.length > 120 ? '${entry.content.substring(0, 120)}...' : entry.content,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                ),
                if (entry.photos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(entry.photos[i]), width: 60, height: 60, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: entry.tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B66).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFF003B66))),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: entry.photos.isNotEmpty ? 260 : 120,
            pinned: true,
            backgroundColor: const Color(0xFF003B66),
            flexibleSpace: FlexibleSpaceBar(
              background: entry.photos.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(entry.photos.first), fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF003B66), Color(0xFF005B99)],
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.formattedDate, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(entry.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                  if (entry.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFFE30A17)),
                        const SizedBox(width: 4),
                        Text(entry.location!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ],
                  if (entry.photos.length > 1) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.photos.length - 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(entry.photos[i + 1]), width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(entry.content, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.7)),
                  if (entry.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8, runSpacing: 4,
                      children: entry.tags.map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFF003B66).withValues(alpha: 0.08),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddJournalScreen(initialEntry: entry)));
        },
        backgroundColor: const Color(0xFF003B66),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Modifier'),
      ),
    );
  }
}
