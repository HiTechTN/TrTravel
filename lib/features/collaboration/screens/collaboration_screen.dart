import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/collaboration/services/collaboration_service.dart';
import 'package:trtravel/features/collaboration/screens/create_group_screen.dart';
import 'package:trtravel/features/collaboration/screens/group_detail_screen.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen> {
  final _inviteController = TextEditingController();

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  void _joinGroup() async {
    final code = _inviteController.text.trim().toUpperCase();
    if (code.isEmpty) {
      context.showSnackBar('Entrez un code d\'invitation', isError: true);
      return;
    }

    final service = context.read<CollaborationService>();
    final success = await service.joinGroup(code);
    if (mounted) {
      if (success) {
        context.showSnackBar('Vous avez rejoint le groupe !');
        _inviteController.clear();
      } else {
        context.showSnackBar('Code invalide', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ModernScaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Collaboration',
            subtitle: 'Voyagez ensemble',
            icon: Icons.groups_rounded,
          ),
          Expanded(
            child: Consumer<CollaborationService>(
              builder: (_, service, __) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GlassEffect(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rejoindre un groupe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inviteController,
                                  decoration: const InputDecoration(
                                    hintText: 'Code à 6 caractères',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  onSubmitted: (_) => _joinGroup(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _joinGroup,
                                child: const Text('Rejoindre'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mes groupes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => context.push(const CreateGroupScreen()),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Créer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (service.groups.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.group_off_rounded, size: 48, color: AppColors.textHint),
                              SizedBox(height: 12),
                              Text('Aucun groupe', style: TextStyle(color: AppColors.textSecondary)),
                              Text('Créez ou rejoignez un groupe pour collaborer', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...service.groups.map((group) => AnimatedCard(
                        onTap: () => context.push(GroupDetailScreen(group: group)),
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.group_rounded, color: AppColors.primary),
                          ),
                          title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${group.memberCount} membre${group.memberCount > 1 ? 's' : ''}${group.linkedTripId != null ? ' • Itinéraire lié' : ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                        ),
                      )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
