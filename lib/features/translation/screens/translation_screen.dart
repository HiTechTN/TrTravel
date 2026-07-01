import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../services/translation_service.dart';
import '../models/translation_phrase.dart';
import 'camera_translation_screen.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputCtrl = TextEditingController();
  FlutterTts? _tts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts?.setLanguage('tr-TR');
    await _tts?.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputCtrl.dispose();
    _tts?.stop();
    super.dispose();
  }

  Future<void> _speak(String text, String lang) async {
    try {
      await _tts?.setLanguage(lang);
      await _tts?.speak(text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ModernScaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.translatorTitle,
            subtitle: l.translatorSubtitle,
            icon: Icons.translate_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraTranslationScreen())),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(l.cameraTranslation),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l.translate, icon: const Icon(Icons.text_fields)),
              Tab(text: l.usefulPhrases, icon: const Icon(Icons.forum)),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Consumer<TranslationService>(
                  builder: (ctx, service, __) => _buildTranslationTab(service, ctx),
                ),
                _buildPhrasesTab(l),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationTab(TranslationService service, BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassEffect(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TranslationLanguage>(
                    value: service.from,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: TranslationLanguage.values.map((lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang.label, style: const TextStyle(fontWeight: FontWeight.w500)));
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) service.setFrom(lang);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => service.swapLanguages(),
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                ),
                Expanded(
                  child: DropdownButtonFormField<TranslationLanguage>(
                    value: service.to,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: TranslationLanguage.values.map((lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang.label, style: const TextStyle(fontWeight: FontWeight.w500)));
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) service.setTo(lang);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l.inputHint,
              alignLabelWithHint: true,
              suffixIcon: _inputCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () { _inputCtrl.clear(); service.clear(); },
                    )
                  : null,
            ),
            onChanged: service.setInput,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: service.isLoading ? null : () => service.translate(),
              icon: service.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.translate),
              label: Text(service.isLoading ? l.translating : l.translate),
            ),
          ),
          if (service.error != null) ...[
            const SizedBox(height: 8),
            GlassEffect(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(service.error!, style: const TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ],
          if (service.translatedText.isNotEmpty) ...[
            const SizedBox(height: 12),
            GlassEffect(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(service.to.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        onPressed: () => _speak(service.translatedText, service.to.locale),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => context.showSnackBar(l.copiedToClipboard),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(service.translatedText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhrasesTab(AppLocalizations l) {
    final book = TranslationPhraseBook.all;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: book.length,
      itemBuilder: (context, index) {
        final category = book[index];
        return GlassEffect(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Text(category.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l.phrasesCount(category.phrases.length)),
            children: category.phrases.map((phrase) {
              return AnimatedCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  final service = context.read<TranslationService>();
                  _inputCtrl.text = phrase.french;
                  service.setInput(phrase.french);
                  service.setFrom(TranslationLanguage.french);
                  service.setTo(TranslationLanguage.turkish);
                  _tabController.animateTo(0);
                  service.translate();
                },
                child: ListTile(
                  dense: true,
                title: Text(phrase.french, style: const TextStyle(fontSize: 13)),
                subtitle: Text(phrase.turkish, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.volume_up, size: 18), onPressed: () => _speak(phrase.turkish, 'tr-TR')),
                    IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => context.showSnackBar(l.copied)),
                  ],
                ),
              ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
