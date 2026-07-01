import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/features/assistant/services/assistant_service.dart';
import 'package:trtravel/features/assistant/widgets/chat_bubble.dart';
import 'package:trtravel/features/assistant/widgets/quick_replies.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(AssistantService service, String text) {
    if (text.trim().isEmpty) return;
    service.askQuestion(text.trim());
    _textCtrl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ModernScaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.assistantTitle,
            subtitle: l.assistantSubtitle,
            icon: Icons.auto_awesome_rounded,
            trailing: Consumer<AssistantService>(
              builder: (_, service, __) {
                if (service.messages.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.clearConversation),
                        content: Text(l.clearConversationConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              service.clearConversation();
                              Navigator.pop(ctx);
                            },
                            child: Text(l.clear, style: const TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<AssistantService>(
              builder: (_, service, __) {
                if (service.messages.isEmpty) {
                  return _buildEmptyState(service);
                }
                return _buildConversation(service);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AssistantService service) {
    final l = AppLocalizations.of(context);
    final suggestions = [
      SuggestionItem(icon: Icons.restaurant_rounded, label: l.whereToEat, colors: const [Color(0xFFF97316), Color(0xFFFB923C)]),
      SuggestionItem(icon: Icons.map_rounded, label: l.whatToVisit, colors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
      SuggestionItem(icon: Icons.wb_sunny_rounded, label: l.weather, colors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
      SuggestionItem(icon: Icons.directions_bus_rounded, label: l.transport, colors: const [Color(0xFF06B6D4), Color(0xFF22D3EE)]),
      SuggestionItem(icon: Icons.account_balance_wallet_rounded, label: l.budget, colors: const [Color(0xFF10B981), Color(0xFF34D399)]),
      SuggestionItem(icon: Icons.translate_rounded, label: l.translation, colors: const [Color(0xFFEC4899), Color(0xFFF472B6)]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            l.assistantGreeting,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.assistantPrompt,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _sendMessage(service, item.label),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: item.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: Colors.white, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversation(AssistantService service) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(12),
      itemCount: service.messages.length + (service.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == service.messages.length && service.isLoading) {
          return _buildTypingIndicator();
        }
        final msg = service.messages[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatBubble(message: msg),
            if (!msg.isUser &&
                msg.response != null &&
                msg.response!.suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: QuickReplies(
                  suggestions: msg.response!.suggestions,
                  onTap: (s) {
                    _sendMessage(service, s);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(300),
                const SizedBox(width: 4),
                _dot(600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Consumer<AssistantService>(
      builder: (_, service, __) {
        return Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).askQuestion,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (v) => _sendMessage(service, v),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: IconButton.filled(
                  onPressed: service.isLoading
                      ? null
                      : () => _sendMessage(service, _textCtrl.text),
                  icon: service.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SuggestionItem {
  final IconData icon;
  final String label;
  final List<Color> colors;

  const SuggestionItem({
    required this.icon,
    required this.label,
    required this.colors,
  });
}
