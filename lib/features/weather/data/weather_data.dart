class CityWeather {
  final String city;
  final String season;
  final double currentTemp;
  final String condition;
  final String emoji;
  final int humidity;
  final double windSpeed;
  final List<DailyForecast> forecast;

  const CityWeather({
    required this.city,
    required this.season,
    required this.currentTemp,
    required this.condition,
    required this.emoji,
    this.humidity = 60,
    this.windSpeed = 10,
    this.forecast = const [],
  });
}

class DailyForecast {
  final String day;
  final String emoji;
  final String condition;
  final double tempMin;
  final double tempMax;

  const DailyForecast({
    required this.day,
    required this.emoji,
    required this.condition,
    required this.tempMin,
    required this.tempMax,
  });
}

class WeatherData {
  static final Map<String, CityWeather> cities = {
    'Istanbul': CityWeather(
      city: 'Istanbul',
      season: 'Été',
      currentTemp: 28,
      condition: 'Ensoleillé',
      emoji: '☀️',
      humidity: 65,
      windSpeed: 12,
      forecast: [
        DailyForecast(day: 'Lun', emoji: '☀️', condition: 'Ensoleillé', tempMin: 22, tempMax: 30),
        DailyForecast(day: 'Mar', emoji: '⛅', condition: 'Partiellement nuageux', tempMin: 21, tempMax: 28),
        DailyForecast(day: 'Mer', emoji: '🌤️', condition: 'Dégagé', tempMin: 23, tempMax: 29),
        DailyForecast(day: 'Jeu', emoji: '☀️', condition: 'Ensoleillé', tempMin: 24, tempMax: 31),
        DailyForecast(day: 'Ven', emoji: '🌧️', condition: 'Pluie légère', tempMin: 20, tempMax: 26),
        DailyForecast(day: 'Sam', emoji: '⛅', condition: 'Nuageux', tempMin: 21, tempMax: 27),
        DailyForecast(day: 'Dim', emoji: '☀️', condition: 'Ensoleillé', tempMin: 22, tempMax: 30),
      ],
    ),
    'Antalya': CityWeather(
      city: 'Antalya',
      season: 'Été',
      currentTemp: 32,
      condition: 'Ensoleillé',
      emoji: '☀️',
      humidity: 55,
      windSpeed: 8,
      forecast: [
        DailyForecast(day: 'Lun', emoji: '☀️', condition: 'Ensoleillé', tempMin: 26, tempMax: 34),
        DailyForecast(day: 'Mar', emoji: '☀️', condition: 'Ensoleillé', tempMin: 27, tempMax: 35),
        DailyForecast(day: 'Mer', emoji: '☀️', condition: 'Ensoleillé', tempMin: 26, tempMax: 33),
        DailyForecast(day: 'Jeu', emoji: '🌤️', condition: 'Dégagé', tempMin: 25, tempMax: 32),
        DailyForecast(day: 'Ven', emoji: '☀️', condition: 'Ensoleillé', tempMin: 27, tempMax: 34),
        DailyForecast(day: 'Sam', emoji: '☀️', condition: 'Ensoleillé', tempMin: 26, tempMax: 35),
        DailyForecast(day: 'Dim', emoji: '⛅', condition: 'Nuageux', tempMin: 25, tempMax: 31),
      ],
    ),
    'Cappadoce': CityWeather(
      city: 'Cappadoce',
      season: 'Été',
      currentTemp: 25,
      condition: 'Ensoleillé',
      emoji: '☀️',
      humidity: 40,
      windSpeed: 15,
      forecast: [
        DailyForecast(day: 'Lun', emoji: '☀️', condition: 'Ensoleillé', tempMin: 14, tempMax: 26),
        DailyForecast(day: 'Mar', emoji: '☀️', condition: 'Ensoleillé', tempMin: 15, tempMax: 27),
        DailyForecast(day: 'Mer', emoji: '🌤️', condition: 'Dégagé', tempMin: 13, tempMax: 25),
        DailyForecast(day: 'Jeu', emoji: '☀️', condition: 'Ensoleillé', tempMin: 14, tempMax: 26),
        DailyForecast(day: 'Ven', emoji: '⛅', condition: 'Partiellement nuageux', tempMin: 12, tempMax: 24),
        DailyForecast(day: 'Sam', emoji: '☀️', condition: 'Ensoleillé', tempMin: 14, tempMax: 26),
        DailyForecast(day: 'Dim', emoji: '☀️', condition: 'Ensoleillé', tempMin: 13, tempMax: 25),
      ],
    ),
  };

  static final List<String> seasons = [
    'Printemps (Mars-Mai): 15-25°C, idéal pour visiter',
    'Été (Juin-Août): 25-35°C, chaud et ensoleillé',
    'Automne (Sep-Nov): 15-28°C, agréable',
    'Hiver (Déc-Fév): 5-15°C, possible pluie/neige',
  ];
}
