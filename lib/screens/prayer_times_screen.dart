import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String _selectedCity = 'Istanbul';
  Map<String, dynamic>? _prayerData;
  bool _loading = true;
  String? _error;
  int _selectedDateOffset = 0;

  static const _cities = {
    'Istanbul': 'Istanbul',
    'Antalya': 'Antalya',
    'Ankara': 'Ankara',
    'Izmir': 'Izmir',
    'Bursa': 'Bursa',
    'Trabzon': 'Trabzon',
    'Konya': 'Konya',
    'Gaziantep': 'Gaziantep',
    'Edirne': 'Edirne',
    'Bodrum': 'Bodrum',
  };

  static const _prayerNames = [
    ('Fajr', '\uD83C\uDF19', 'Aube'),
    ('Sunrise', '\uD83C\uDF04\uFE0F', 'Lever du soleil'),
    ('Dhuhr', '\u2600\uFE0F', 'Midi'),
    ('Asr', '\uD83D\uDD25', 'Apr\u00E8s-midi'),
    ('Maghrib', '\uD83C\uDF07', 'Coucher du soleil'),
    ('Isha', '\uD83C\uDF03', 'Nuit'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() { _loading = true; _error = null; });
    try {
      final now = DateTime.now().add(Duration(days: _selectedDateOffset));
      final dateStr = DateFormat('dd-MM-yyyy').format(now);
      final url = 'https://api.aladhan.com/v1/timingsByCity'
          '?city=$_selectedCity&country=Turkey&method=13&date=$dateStr';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { _prayerData = json.decode(res.body); _loading = false; });
      } else {
        setState(() { _error = 'Erreur serveur (${res.statusCode})'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Impossible de charger les horaires'; _loading = false; });
    }
  }

  String? _getTiming(String key) {
    try {
      return _prayerData!['data']['timings'][key] as String?;
    } catch (_) {
      return null;
    }
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  DateTime? _parseTime(String time) {
    try {
      final now = DateTime.now().add(Duration(days: _selectedDateOffset));
      final parts = time.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  Duration _timeUntil(DateTime? target) {
    if (target == null) return Duration.zero;
    return target.difference(DateTime.now());
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Pass\u00E9';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return 'Dans $h h $m min';
    return 'Dans $m min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.mosque, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Horaires de pri\u00E8re',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ),
                        _buildCitySelector(),
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _prayerData != null
                          ? _buildContent()
                          : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          dropdownColor: const Color(0xFF1B5E20),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: _cities.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) { setState(() => _selectedCity = v!); _fetchPrayerTimes(); },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchPrayerTimes,
            icon: const Icon(Icons.refresh),
            label: const Text('R\u00E9essayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final hijri = _prayerData!['data']['date']['hijri'];
    final gregorian = _prayerData!['data']['date']['gregorian'];
    final hijriDate = '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}';
    final gregDate = '${gregorian['weekday']['fr']} ${gregorian['date']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateNav(hijriDate, gregDate),
        const SizedBox(height: 16),
        _buildPrayerCards(),
        const SizedBox(height: 16),
        _buildNextPrayer(),
        const SizedBox(height: 16),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildDateNav(String hijri, String greg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () { setState(() => _selectedDateOffset--); _fetchPrayerTimes(); },
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1B5E20)),
                      const SizedBox(width: 6),
                      Text(greg, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('\uD83C\uDFC3 $hijri', style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20))),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _selectedDateOffset < 6
                    ? () { setState(() => _selectedDateOffset++); _fetchPrayerTimes(); }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCards() {
    final now = DateTime.now();

    return Column(
      children: _prayerNames.map((p) {
        final key = p.$1;
        final time = _getTiming(key);
        if (time == null) return const SizedBox();
        final formatted = _formatTime(time);
        final parsed = _parseTime(time);
        final isPast = parsed != null && parsed.isBefore(now);
        final isNext = !isPast && (parsed == null || parsed.isAfter(now));

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isNext ? const Color(0xFF1B5E20).withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isNext ? Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.3)) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Text(p.$2, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isPast ? Colors.grey[500] : Colors.grey[800])),
                    Text(p.$3, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Text(formatted, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isPast ? Colors.grey[400] : const Color(0xFF1B5E20))),
              if (isNext) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_formatDuration(_timeUntil(parsed)), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextPrayer() {
    final now = DateTime.now();
    String? nextName;
    String? nextTime;

    for (final p in _prayerNames) {
      final t = _getTiming(p.$1);
      if (t == null) continue;
      final parsed = _parseTime(t);
      if (parsed != null && parsed.isAfter(now)) {
        nextName = p.$1;
        nextTime = _formatTime(t);
        break;
      }
    }

    if (nextName == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prochaine pri\u00E8re', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('$nextName \u00E0 $nextTime', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFF795548)),
              SizedBox(width: 8),
              Text('M\u00E9thode de calcul', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF795548), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'M\u00E9thode utilis\u00E9e : Diyanet (Direction des Affaires Religieuses de Turquie)\n'
            'Les horaires peuvent varier l\u00E9g\u00E8rement selon la mosqu\u00E9e. V\u00E9rifiez sur place.',
            style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
