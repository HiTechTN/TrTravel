import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/collaboration/models/collaboration_models.dart';
import 'package:trtravel/features/collaboration/services/collaboration_service.dart';
import 'package:trtravel/features/collaboration/widgets/chat_bubble.dart';
import 'package:trtravel/core/services/auth_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final TravelGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final service = context.read<CollaborationService>();
    service.listenToGroupMessages(widget.group.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    context.read<CollaborationService>().stopListeningToMessages();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<CollaborationService>().sendMessage(widget.group.id, content);
    _messageController.clear();
  }

  void _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: const Text('Voulez-vous vraiment quitter ce groupe ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitter', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<CollaborationService>().leaveGroup(widget.group.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous avez quitté le groupe'), behavior: SnackBarBehavior.floating),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final currentUserId = authService.userId;

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: widget.group.name,
            subtitle: '${widget.group.memberCount} membres | Code: ${widget.group.inviteCode}',
            icon: Icons.group_rounded,
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'leave') _leaveGroup();
                if (value == 'copy_code') {
                  Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié !'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'copy_code', child: ListTile(leading: Icon(Icons.copy), title: Text('Copier le code'))),
                const PopupMenuItem(value: 'leave', child: ListTile(leading: Icon(Icons.exit_to_app, color: AppColors.error), title: Text('Quitter le groupe'))),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Discussion', icon: Icon(Icons.chat_rounded)),
              Tab(text: 'Membres', icon: Icon(Icons.people_rounded)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(currentUserId),
                _buildMembersTab(currentUserId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(String? currentUserId) {
    return Column(
      children: [
        Expanded(
          child: Consumer<CollaborationService>(
            builder: (_, service, __) {
              final messages = service.messages;
              if (messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_rounded, size: 48, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text('Aucun message', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: messages.length,
                reverse: true,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isMine = msg.userId == currentUserId;
                  return ChatBubble(message: msg, isMine: isMine);
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Votre message...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab(String? currentUserId) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Code d\'invitation', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          widget.group.inviteCode,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copié !'), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Membres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...widget.group.members.map((member) => ListTile(
          leading: member.photoUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(member.photoUrl!))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(member.roleLabel, style: const TextStyle(fontSize: 12)),
          trailing: member.userId == currentUserId
              ? const Chip(label: Text('Vous', style: TextStyle(fontSize: 11)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)
              : null,
        )),
      ],
    );
  }
}
