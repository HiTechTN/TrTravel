import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static final _emergencyNumbers = [
    ('Ambulance', '112', Icons.local_hospital, Colors.red),
    ('Police', '155', Icons.local_police, const Color(0xFF003B66)),
    ('Pompiers', '110', Icons.fire_truck, Colors.orange),
    ('Gendarmerie', '156', Icons.shield, const Color(0xFF1B5E20)),
    ('Police Touristique', '153', Icons.flight, const Color(0xFF00838F)),
    ('Gaz Naturel', '187', Icons.local_gas_station, Colors.amber.shade800),
    ('Urgence M\u00E9dicale', '112', Icons.medical_services, Colors.red),
  ];

  static const _hospitals = [
    ('Memorial \u015Ei\u015Fli', 'Istanbul - \u015Ei\u015Fli', '+902123140000'),
    ('Ac\u0131badem Altunizade', 'Istanbul - \u00DCsk\u00FCdar', '+902166444444'),
    ('Medipol Mega', 'Istanbul - Ba\u011Fc\u0131lar', '+902124604000'),
    ('American Hospital', 'Istanbul - Ni\u015Fanta\u015F\u0131', '+902123114000'),
    ('MLP Care Antalya', 'Antalya - Muratpa\u015Fa', '+902423221212'),
    ('Medical Park Antalya', 'Antalya - Kepez', '+902423141414'),
  ];

  static const _embassies = [
    ('France', 'Istanbul', '+902123344444'),
    ('France', 'Ankara', '+903124554545'),
    ('Belgique', 'Ankara', '+903124684040'),
    ('Canada', 'Ankara', '+903124095200'),
    ('Suisse', 'Ankara', '+903124676070'),
    ('USA', 'Ankara', '+903124550000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.red.shade800,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.red.shade800, Colors.red.shade600],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.emergency, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Urgences', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyNumbers(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(Icons.local_hospital, 'H\u00F4pitaux recommand\u00E9s'),
                  const SizedBox(height: 12),
                  ..._hospitals.map((h) => _buildContactTile(context, h.$1, h.$2, h.$3, Icons.local_hospital, Colors.red.shade100)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(Icons.account_balance, 'Ambassades & Consulats'),
                  const SizedBox(height: 12),
                  ..._embassies.map((e) => _buildContactTile(context, e.$1, e.$2, e.$3, Icons.account_balance, Colors.blue.shade100)),
                  const SizedBox(height: 24),
                  _buildTipsCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.red.shade700),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildEmergencyNumbers(BuildContext context) {
    return Column(
      children: _emergencyNumbers.map((e) {
        final name = e.$1;
        final number = e.$2;
        final icon = e.$3;
        final color = e.$4;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _callNumber(number),
              onLongPress: () {
                HapticFeedback.heavyImpact();
                Clipboard.setData(ClipboardData(text: number));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$number copi\u00E9')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('Appui court pour appeler | Appui long pour copier',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(number, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 4),
                          const Icon(Icons.phone, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactTile(BuildContext context, String name, String location, String phone, IconData icon, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _callNumber(phone.replaceAll(RegExp(r'[^0-9+]'), '')),
          onLongPress: () {
            HapticFeedback.heavyImpact();
            Clipboard.setData(ClipboardData(text: phone));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$phone copi\u00E9')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: bgColor == Colors.red.shade100 ? Colors.red.shade700 : Colors.blue.shade700, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Icon(Icons.phone, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 4),
                Text(phone, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
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
              Icon(Icons.tips_and_updates, size: 18, color: Color(0xFF795548)),
              SizedBox(width: 8),
              Text('Conseils de s\u00E9curit\u00E9', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF795548), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\u2022 En cas d\'urgence, composez le 112 (ambulance/pompiers)\n'
            '\u2022 Police touristique : 153 (anglais/fran\u00E7ais possible)\n'
            '\u2022 Conservez une copie de votre passeport sur vous\n'
            '\u2022 Souscrivez une assurance voyage avant le d\u00E9part\n'
            '\u2022 Les h\u00F4pitaux priv\u00E9s (Ac\u0131badem, Memorial) offrent des services en anglais\n'
            '\u2022 Pharmacies de garde : cherchez \u00AB N\u00F6bet\u00E7i Eczane \u00BB',
            style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
