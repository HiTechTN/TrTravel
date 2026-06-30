import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../models/emergency_data.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Urgences',
            subtitle: 'Numéros importants',
            icon: Icons.emergency_rounded,
            gradientColors: [AppColors.error, const Color(0xFF991B1B)],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUrgentNumbers(),
                const SizedBox(height: 16),
                _buildSection('📞 Ambassades & Consulats', EmergencyInfo.embassyPhones),
                const SizedBox(height: 16),
                _buildSection('🏥 Hôpitaux', EmergencyInfo.hospitals),
                const SizedBox(height: 16),
                _buildSection('💊 Pharmacies', EmergencyInfo.pharmacies),
                const SizedBox(height: 16),
                _buildTips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentNumbers() {
    return Column(
      children: [
        Row(
          children: EmergencyInfo.nationalNumbers.take(3).map((c) => Expanded(
            child: _buildUrgentCard(c),
          )).toList(),
        ),
        const SizedBox(height: 8),
        ...EmergencyInfo.nationalNumbers.skip(3).map((c) => _buildContactTile(c)),
      ],
    );
  }

  Widget _buildUrgentCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => _call(contact.number),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(contact.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(contact.number,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.error)),
              const SizedBox(height: 4),
              Text(contact.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<EmergencyContact> contacts) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            ...contacts.map((c) => _buildContactTile(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(EmergencyContact contact) {
    return ListTile(
      leading: Text(contact.emoji, style: const TextStyle(fontSize: 28)),
      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(contact.description, style: const TextStyle(fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(contact.number, style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22),
        ],
      ),
      onTap: () => _call(contact.number),
    );
  }

  Widget _buildTips() {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.warning.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Conseils de sécurité', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            const _Tip(text: 'Gardez une copie numérique de vos papiers d\'identité'),
            _Tip(text: 'Notez l\'adresse de votre ambassade avant le départ'),
            _Tip(text: 'Souscrivez une assurance voyage avec rapatriement'),
            _Tip(text: 'Ayez toujours du liquide (TL) pour les urgences'),
            _Tip(text: 'Téléchargez les cartes hors-ligne avant le départ'),
          ],
        ),
      ),
    );
  }

  void _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }
}
