import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_update_service.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUpdateService>(
      builder: (context, updateService, child) {
        if (!updateService.shouldShowUpdateDialog()) {
          return const SizedBox.shrink();
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.system_update, color: Color(0xFFE30A17)),
              ),
              const SizedBox(width: 12),
              const Text('Mise à jour disponible!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${updateService.latestVersion} est disponible',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (updateService.releaseNotes != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    child: Text(
                      updateService.releaseNotes!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Version actuelle: ${updateService.currentVersion}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateService.dismissUpdate();
                Navigator.of(context).pop();
              },
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                updateService.dismissUpdate();
                Navigator.of(context).pop();
                // In production: trigger actual download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Téléchargement de la mise à jour...'),
                    backgroundColor: Color(0xFF43A047),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE30A17),
                foregroundColor: Colors.white,
              ),
              child: const Text('Mettre à jour'),
            ),
          ],
        );
      },
    );
  }
}

class UpdateChecker extends StatefulWidget {
  final Widget child;
  
  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppUpdateService>().checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateService = context.watch<AppUpdateService>();
    
    return Stack(
      children: [
        widget.child,
        if (updateService.shouldShowUpdateDialog())
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent interaction
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: UpdateDialog(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}