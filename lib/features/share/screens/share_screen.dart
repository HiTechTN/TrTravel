import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/share/services/share_service.dart';
import 'package:trtravel/features/share/widgets/qr_code_widget.dart';
import 'package:trtravel/features/share/widgets/share_actions.dart';

class ShareScreen extends StatefulWidget {
  final String tripId;
  final String tripTitle;
  final String tripDescription;
  final Map<String, dynamic> itineraryData;

  const ShareScreen({
    super.key,
    required this.tripId,
    required this.tripTitle,
    this.tripDescription = '',
    required this.itineraryData,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String? _shareLink;
  String? _shareCode;
  bool _isSharing = false;
  bool _showQR = false;

  Future<void> _generateShareLink() async {
    setState(() => _isSharing = true);

    final shareService = context.read<ShareService>();
    final link = await shareService.shareItinerary(
      tripId: widget.tripId,
      title: widget.tripTitle,
      description: widget.tripDescription,
      itineraryData: widget.itineraryData,
    );

    if (link != null) {
      setState(() {
        _shareLink = link;
        _shareCode = shareService.generateQRCodeData(link);
      });
    }

    setState(() => _isSharing = false);
  }

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Partager',
            subtitle: 'Partagez votre itinéraire',
            icon: Icons.share_rounded,
          ),
          Expanded(
            child: _isSharing
                ? const Center(child: CircularProgressIndicator())
                : _shareLink == null
                    ? const Center(child: Text('Erreur de partage'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_showQR) ...[
                            Center(
                              child: QRCodeWidget(
                                data: _shareCode ?? _shareLink!,
                                size: 220,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scannez ce code pour importer l\'itinéraire',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton.icon(
                                onPressed: () => setState(() => _showQR = false),
                                icon: const Icon(Icons.close),
                                label: const Text('Fermer le QR'),
                              ),
                            ),
                          ],
                          ShareActions(
                            shareLink: _shareLink!,
                            shareCode: _shareCode ?? '',
                            onShareSystem: () async {
                              final text = 'Découvrez mon itinéraire sur TrTravel !\n$_shareLink';
                              context.read<ShareService>().shareViaSystem(text);
                            },
                            onShareQR: () => setState(() => _showQR = !_showQR),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
