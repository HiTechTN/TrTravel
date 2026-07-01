import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/app_scaffold.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import 'package:trtravel/shared/widgets/app_empty.dart';
import '../data/wiki_database.dart';
import '../models/wiki_models.dart';
import 'wiki_detail_screen.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen>
    with SingleTickerProviderStateMixin {
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
    return AppScaffold(
      body: Column(
        children: [
          const AppHeader(
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CityChip(label: 'Toutes', selected: _selectedCity == 'all',
                    onTap: () => setState(() => _selectedCity = 'all')),
                const SizedBox(width: 8),
                _CityChip(label: 'Istanbul', selected: _selectedCity == 'istanbul',
                    onTap: () => setState(() => _selectedCity = 'istanbul')),
                const SizedBox(width: 8),
                _CityChip(label: 'Antalya', selected: _selectedCity == 'antalya',
                    onTap: () => setState(() => _selectedCity = 'antalya')),
                const SizedBox(width: 8),
                _CityChip(label: 'Cappadoce', selected: _selectedCity == 'cappadoce',
                    onTap: () => setState(() => _selectedCity = 'cappadoce')),
                const SizedBox(width: 8),
                _CityChip(label: 'Izmir', selected: _selectedCity == 'izmir',
                    onTap: () => setState(() => _selectedCity = 'izmir')),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: categories.map((cat) {
              final items = _selectedCity == 'all'
                  ? cat.items
                  : cat.items.where((a) => a.city.toLowerCase() == _selectedCity).toList();
              if (items.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(cat.icon, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(cat.localizedName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                      ),
                      ...items.map((item) => AppCard(
                        padding: EdgeInsets.zero,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => WikiDetailScreen(item: item)),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, color: AppColors.primary, size: 20),
                          ),
                          title: Text(item.localizedTitle,
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(item.tags.take(3).join(' • '),
                              style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    final allItems = WikiDatabase.categories.expand((cat) => cat.items).toList();
    final results = _searchQuery.isEmpty
        ? allItems
        : allItems.where((a) =>
            a.localizedTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.localizedDescription.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un article...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? AppEmpty(
                  icon: Icons.search_off_rounded,
                  title: 'Aucun résultat',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Essayez d\'autres termes'
                      : 'Tapez pour chercher')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: results.map((item) => AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => WikiDetailScreen(item: item)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, color: AppColors.primary, size: 20),
                      ),
                      title: Text(item.localizedTitle,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(item.city, style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary),
                    ),
                  )).toList(),
                ),
        ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label,
          style: TextStyle(fontSize: 13, color: selected ? Colors.white : null)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      visualDensity: VisualDensity.compact,
    );
  }
}
