import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/app_scaffold.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import '../data/weather_data.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: l.weather,
            subtitle: 'Prévisions pour la Turquie',
            icon: Icons.wb_sunny_rounded,
            gradientColors: AppColors.sunsetGradient,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                ...WeatherData.cities.values.map((city) => _buildCityWeather(city)),
                const SizedBox(height: 16),
                _buildSeasonInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityWeather(CityWeather weather) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weather.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather.city, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(weather.condition, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              Text('${weather.currentTemp.toStringAsFixed(0)}°',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _weatherDetail(Icons.water_drop_rounded, '${weather.humidity}%'),
              const SizedBox(width: 24),
              _weatherDetail(Icons.air_rounded, '${weather.windSpeed} km/h'),
              const SizedBox(width: 24),
              _weatherDetail(Icons.calendar_month_rounded, weather.season),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Prévisions 7 jours', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.forecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final day = weather.forecast[i];
                return Container(
                  width: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.day, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(day.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text('${day.tempMax.toStringAsFixed(0)}°',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${day.tempMin.toStringAsFixed(0)}°',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSeasonInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info),
              SizedBox(width: 8),
              Text('Climat de la Turquie', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...WeatherData.seasons.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.3))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
