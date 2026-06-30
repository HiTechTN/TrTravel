import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';

class WeatherService extends ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const apiKey = 'YOUR_API_KEY';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city,turkey&appid=$apiKey&units=metric&lang=fr',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _weatherData = jsonDecode(response.body) as Map<String, dynamic>;
        LocalStorage.setJson('weather_${city.toLowerCase()}', _weatherData!);
      } else {
        _weatherData = LocalStorage.getJson('weather_${city.toLowerCase()}');
        if (_weatherData == null) throw Exception('Données hors ligne non disponibles');
      }
    } catch (e) {
      LogService.warning('Weather', 'API failed, using cached: $e');
      _weatherData = LocalStorage.getJson('weather_${city.toLowerCase()}');
      if (_weatherData == null) {
        _error = 'Impossible de charger la météo';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  String getTemperature(String city) {
    if (_weatherData != null) {
      final temp = _weatherData!['main']?['temp'];
      if (temp != null) return '${(temp as num).round()}°C';
    }
    // Fallback static data
    const temps = {'Istanbul': 28, 'Antalya': 32, 'Cappadoce': 25};
    return '${temps[city] ?? 25}°C';
  }

  String getCondition(String city) {
    if (_weatherData != null) {
      final desc = _weatherData!['weather']?[0]?['description'];
      if (desc != null) return desc as String;
    }
    const conditions = {'Istanbul': 'Ensoleillé', 'Antalya': 'Ensoleillé', 'Cappadoce': 'Dégagé'};
    return conditions[city] ?? 'Ensoleillé';
  }

  String getIcon(String city) {
    if (_weatherData != null) {
      final icon = _weatherData!['weather']?[0]?['icon'];
      if (icon != null) return icon as String;
    }
    return '01d';
  }
}
