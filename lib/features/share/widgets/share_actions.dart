import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';

class ShareActions extends StatelessWidget {
  final String shareLink;
  final String shareCode;
  final VoidCallback onShareSystem;
  final VoidCallback onShareQR;

  const ShareActions({
    super.key,
    required this.shareLink,
    required this.shareCode,
    required this.onShareSystem,
    required this.onShareQR,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAction(
          context,
          icon: Icons.link_rounded,
          label: 'Copier le lien',
          subtitle: 'Partager via un lien',
          onTap: () {
            Clipboard.setData(ClipboardData(text: shareLink));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lien copié !'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildAction(
          context,
          icon: Icons.qr_code_rounded,
          label: 'Code QR',
          subtitle: 'Afficher le code QR',
          onTap: onShareQR,
        ),
        const SizedBox(height: 8),
        _buildAction(
          context,
          icon: Icons.share_rounded,
          label: 'Partager',
          subtitle: 'Via les applications',
          onTap: onShareSystem,
        ),
        const SizedBox(height: 8),
        _buildAction(
          context,
          icon: Icons.copy_rounded,
          label: 'Code de partage',
          subtitle: 'Code: $shareCode',
          onTap: () {
            Clipboard.setData(ClipboardData(text: shareCode));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code copié !'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}
