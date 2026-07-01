import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/shared/widgets/empty_state.dart';
import '../data/wiki_database.dart';
import 'wiki_detail_screen.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCity = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Guide de Voyage',
            subtitle: 'Tout savoir sur la Turquie',
            icon: Icons.menu_book_rounded,
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Catégories', icon: Icon(Icons.category_rounded)),
              Tab(text: 'Recherche', icon: Icon(Icons.search_rounded)),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categories = WikiDatabase.categories;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _CityChip(label: 'Toutes', selected: _selectedCity == 'all', onTap: () => setState(() => _selectedCity = 'all')),
              const SizedBox(width: 8),
              _CityChip(label: 'Istanbul', selected: _selectedCity == 'istanbul', onTap: () => setState(() => _selectedCity = 'istanbul')),
              const SizedBox(width: 8),
              _CityChip(label: 'Antalya', selected: _selectedCity == 'antalya', onTap: () => setState(() => _selectedCity = 'antalya')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final cat = categories[index];
              final items = _selectedCity == 'all'
                  ? cat.items
                  : cat.items.where((i) => i.city == _selectedCity || i.city == 'general').toList();
              if (items.isEmpty) return const SizedBox.shrink();
              return GlassEffect(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(cat.icon, color: AppColors.primary),
                  ),
                  title: Text(cat.localizedName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${items.length} articles'),
                  children: items.map((item) => AnimatedCard(
                    padding: EdgeInsets.zero,
                    onTap: () => context.push(WikiDetailScreen(item: item)),
                    child: ListTile(
                      leading: Icon(item.icon, color: AppColors.textSecondary, size: 20),
                      title: Text(item.localizedTitle, style: const TextStyle(fontSize: 14)),
                      subtitle: item.price != null ? Text(item.price!, style: const TextStyle(fontSize: 12, color: AppColors.primary)) : null,
                      trailing: const Icon(Icons.chevron_right, size: 20),
                    ),
                  )).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher: mosquée, restaurant, transport...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: _searchQuery.isEmpty
              ? const EmptyState(
                  icon: Icons.search_rounded,
                  title: 'Recherchez dans le guide',
                  subtitle: 'Tapez un mot-clé pour trouver des informations',
                )
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final results = WikiDatabase.search(_searchQuery);
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        subtitle: 'Essayez un autre mot-clé',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final item = results[i];
        return AnimatedCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 8),
          onTap: () => context.push(WikiDetailScreen(item: item)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(item.icon, color: AppColors.primary, size: 20),
            ),
            title: Text(item.localizedTitle),
            subtitle: Text(item.localizedDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

extension on BuildContext {
  void push(Widget page) => Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));
}
