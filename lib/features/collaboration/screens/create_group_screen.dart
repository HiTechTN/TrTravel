import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/collaboration/services/collaboration_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Veuillez entrer un nom de groupe', isError: true);
      return;
    }

    setState(() => _isCreating = true);

    final service = context.read<CollaborationService>();
    final group = await service.createGroup(
      name: name,
      description: _descController.text.trim(),
    );

    setState(() => _isCreating = false);

    if (group != null && mounted) {
      context.showSnackBar('Groupe "$name" créé !');
      context.pop();
    } else if (mounted) {
      context.showSnackBar('Erreur lors de la création', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Nouveau groupe',
            subtitle: 'Créez un groupe de voyage',
            icon: Icons.group_add_rounded,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du groupe',
                      hintText: 'Ex: Voyage à Istanbul',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnelle)',
                      hintText: 'Description du voyage...',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isCreating ? null : _createGroup,
                    icon: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.group_add_rounded),
                    label: Text(_isCreating ? 'Création...' : 'Créer le groupe'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
