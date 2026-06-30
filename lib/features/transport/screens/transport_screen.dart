import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../data/transport_data.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Transport',
            subtitle: 'Se déplacer en Turquie',
            icon: Icons.directions_bus_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: TransportData.all.map((city) => _buildCitySection(city)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySection(TransportCity city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.location_city, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(city.city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...city.options.map((option) => _buildOptionCard(option)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOptionCard(TransportOption option) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Text(option.icon, style: const TextStyle(fontSize: 32)),
        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${option.price} • ${option.hours}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                _infoChip(Icons.access_time, 'Horaires', option.hours),
                _infoChip(Icons.trending_up, 'Fréquence', option.frequency),
                _infoChip(Icons.monetization_on, 'Prix', option.price),
                if (option.tips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('💡 Conseils :', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...option.tips.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
