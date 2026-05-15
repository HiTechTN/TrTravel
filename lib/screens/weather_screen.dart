import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedCity = 'Istanbul';
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String? _error;

  static const _cities = {
    'Istanbul': {'lat': 41.0082, 'lon': 28.9784},
    'Antalya': {'lat': 36.8841, 'lon': 30.7056},
    'Ankara': {'lat': 39.9334, 'lon': 32.8597},
    'Izmir': {'lat': 38.4192, 'lon': 27.1287},
    'Cappadoce': {'lat': 38.6585, 'lon': 34.8285},
    'Bursa': {'lat': 40.1829, 'lon': 29.0669},
    'Pamukkale': {'lat': 37.9172, 'lon': 29.1210},
    'Trabzon': {'lat': 41.0027, 'lon': 39.7168},
    'Bodrum': {'lat': 37.0344, 'lon': 27.4303},
    'Edirne': {'lat': 41.6771, 'lon': 26.5557},
  };

  final _weatherEmojis = {
    0: '\u2600\uFE0F', 1: '\uD83C\uDF24\uFE0F', 2: '\u26C5',
    3: '\u2601\uFE0F', 45: '\uD83C\uDF2B\uFE0F', 48: '\uD83C\uDF2B\uFE0F',
    51: '\uD83C\uDF26\uFE0F', 53: '\uD83C\uDF26\uFE0F', 55: '\uD83C\uDF26\uFE0F',
    56: '\uD83C\uDF26\uFE0F', 57: '\uD83C\uDF26\uFE0F',
    61: '\uD83C\uDF27\uFE0F', 63: '\uD83C\uDF27\uFE0F', 65: '\uD83C\uDF27\uFE0F',
    66: '\uD83C\uDF27\uFE0F', 67: '\uD83C\uDF27\uFE0F',
    71: '\u2744\uFE0F', 73: '\u2744\uFE0F', 75: '\u2744\uFE0F',
    77: '\u2744\uFE0F', 80: '\uD83C\uDF27\uFE0F', 81: '\uD83C\uDF27\uFE0F',
    82: '\uD83C\uDF27\uFE0F', 85: '\u2744\uFE0F', 86: '\u2744\uFE0F',
    95: '\u26A1', 96: '\u26A1', 99: '\u26A1',
  };

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() { _loading = true; _error = null; });
    final c = _cities[_selectedCity]!;
    final url = 'https://api.open-meteo.com/v1/forecast'
        '?latitude=${c['lat']}&longitude=${c['lon']}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset,uv_index_max,precipitation_sum'
        '&timezone=auto&forecast_days=7';

    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { _weatherData = json.decode(res.body); _loading = false; });
      } else {
        setState(() { _error = 'Erreur serveur (${res.statusCode})'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Impossible de charger la m\u00E9t\u00E9o'; _loading = false; });
    }
  }

  String _weatherText(int code) {
    const m = {
      0: 'D\u00E9gag\u00E9', 1: 'Peu nuageux', 2: 'Partiellement nuageux',
      3: 'Nuageux', 45: 'Brouillard', 48: 'Brouillard givrant',
      51: 'Bruine l\u00E9g\u00E8re', 53: 'Bruine mod\u00E9r\u00E9e', 55: 'Bruine dense',
      56: 'Bruine vergla\u00E7ante', 57: 'Bruine vergla\u00E7ante dense',
      61: 'Pluie l\u00E9g\u00E8re', 63: 'Pluie mod\u00E9r\u00E9e', 65: 'Pluie forte',
      66: 'Pluie vergla\u00E7ante', 67: 'Pluie vergla\u00E7ante forte',
      71: 'Neige l\u00E9g\u00E8re', 73: 'Neige mod\u00E9r\u00E9e', 75: 'Neige forte',
      77: 'Grains de neige', 80: 'Averses l\u00E9g\u00E8res', 81: 'Averses mod\u00E9r\u00E9es',
      82: 'Averses violentes', 85: 'Averses de neige l\u00E9g\u00E8res', 86: 'Averses de neige fortes',
      95: 'Orage', 96: 'Orage avec gr\u00EAle', 99: 'Orage violent avec gr\u00EAle',
    };
    return m[code] ?? 'Inconnu';
  }

  String _windDirection(double deg) {
    if (deg < 22.5) return 'N'; if (deg < 67.5) return 'NE';
    if (deg < 112.5) return 'E'; if (deg < 157.5) return 'SE';
    if (deg < 202.5) return 'S'; if (deg < 247.5) return 'SO';
    if (deg < 292.5) return 'O'; if (deg < 337.5) return 'NO';
    return 'N';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
                        const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'M\u00E9t\u00E9o',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
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
                      : _weatherData != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCurrentWeather(),
                                const SizedBox(height: 20),
                                _buildDailyForecast(),
                              ],
                            )
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
          dropdownColor: const Color(0xFF003B66),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: _cities.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) { setState(() => _selectedCity = v!); _fetchWeather(); },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.refresh),
            label: const Text('R\u00E9essayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final c = _weatherData!['current'];
    final code = c['weather_code'] as int;
    final temp = c['temperature_2m'] as num;
    final feels = c['apparent_temperature'] as num;
    final humidity = c['relative_humidity_2m'] as int;
    final wind = c['wind_speed_10m'] as num;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF003B66), Color(0xFF005B99)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedCity, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${temp.toInt()}\u00B0C', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w200)),
                  Text('Ressenti ${feels.toInt()}\u00B0C', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              Text(_weatherEmojis[code] ?? '\u2601\uFE0F', style: const TextStyle(fontSize: 64)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weatherDetail(Icons.water_drop, '$humidity%', 'Humidit\u00E9'),
              _weatherDetail(Icons.air, '${wind.toInt()} km/h', 'Vent'),
              _weatherDetail(Icons.visibility, _weatherText(code), ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildDailyForecast() {
    final d = _weatherData!['daily'];
    final dates = (d['time'] as List).cast<String>();
    final maxT = (d['temperature_2m_max'] as List).cast<num>();
    final minT = (d['temperature_2m_min'] as List).cast<num>();
    final codes = (d['weather_code'] as List).cast<int>();
    final sunrise = (d['sunrise'] as List).cast<String>();
    final sunset = (d['sunset'] as List).cast<String>();
    final uv = (d['uv_index_max'] as List).cast<num>();
    final precip = (d['precipitation_sum'] as List).cast<num>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.date_range, size: 18, color: Color(0xFF003B66)),
            const SizedBox(width: 8),
            const Text('Pr\u00E9visions 7 jours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF003B66))),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(dates.length, (i) {
          final dt = DateTime.parse(dates[i]);
          final dayName = i == 0 ? "Aujourd'hui" : i == 1 ? 'Demain' : DateFormat('EEEE', 'fr').format(dt);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    dayName[0].toUpperCase() + dayName.substring(1),
                    style: TextStyle(fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500, fontSize: 14, color: i == 0 ? const Color(0xFF003B66) : Colors.grey[800]),
                  ),
                ),
                Text(_weatherEmojis[codes[i]] ?? '\u2601\uFE0F', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_weatherText(codes[i]), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ),
                Text('${minT[i].toInt()}\u00B0', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFFFF6B35)]),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${maxT[i].toInt()}\u00B0', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('D\u00E9tails suppl\u00E9mentaires',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF795548))),
              const SizedBox(height: 8),
              ...List.generate(dates.length, (i) {
                final dt = DateTime.parse(dates[i]);
                final dayName = i == 0 ? "Aujourd'hui" : DateFormat('EEEE', 'fr').format(dt);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(width: 80, child: Text(dayName[0].toUpperCase() + dayName.substring(1), style: const TextStyle(fontSize: 12))),
                      const Icon(Icons.wb_sunny, size: 14, color: Colors.orange),
                      Text(' ${sunrise[i].substring(11, 16)}  ', style: const TextStyle(fontSize: 12)),
                      const Icon(Icons.nights_stay, size: 14, color: Colors.indigo),
                      Text(' ${sunset[i].substring(11, 16)}  ', style: const TextStyle(fontSize: 12)),
                      if (precip[i] > 0)
                        Text('\uD83C\uDF27\uFE0F ${precip[i]}mm', style: const TextStyle(fontSize: 12))
                      else
                        Text('UV ${uv[i].toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
