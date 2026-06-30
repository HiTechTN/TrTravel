import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../services/assistant_service.dart';
import '../models/assistant_models.dart';
import '../widgets/itinerary_sharing.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Assistant Voyage',
            subtitle: 'Votre guide personnel intelligent',
            icon: Icons.auto_awesome_rounded,
          ),
          Expanded(
            child: Consumer<AssistantService>(
              builder: (_, service, __) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCitySelector(service),
                    const SizedBox(height: 16),
                    _buildDurationSlider(service),
                    const SizedBox(height: 16),
                    _buildInterests(service),
                    const SizedBox(height: 16),
                    _buildQuestionInput(service),
                    if (service.answer != null) ...[
                      const SizedBox(height: 16),
                      _buildAnswer(service),
                    ],
                    const SizedBox(height: 16),
                    _buildGeneratePlan(context, service),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector(AssistantService service) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📍 Ville', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AssistantService.cities.map((city) {
                final selected = service.selectedCity == city;
                return ChoiceChip(
                  label: Text(city),
                  selected: selected,
                  onSelected: (_) => service.setCity(city),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : null),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSlider(AssistantService service) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Durée : ${service.tripDuration} jour${service.tripDuration > 1 ? 's' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: service.tripDuration.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              activeColor: AppColors.primary,
              onChanged: (v) => service.setDuration(v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterests(AssistantService service) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 Centres d\'intérêt', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TravelInterest.all.map((interest) {
                final selected = service.selectedInterests.contains(interest.id);
                return FilterChip(
                  avatar: Text(interest.emoji, style: const TextStyle(fontSize: 16)),
                  label: Text(interest.name, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => service.toggleInterest(interest.id),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(AssistantService service) {
    final ctrl = TextEditingController();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💬 Posez votre question', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Où manger ? Que visiter ? Budget ?',
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        service.askQuestion(v.trim());
                        ctrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: service.isLoading ? null : () {
                    if (ctrl.text.trim().isNotEmpty) {
                      service.askQuestion(ctrl.text.trim());
                      ctrl.clear();
                    }
                  },
                  icon: service.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                'Où manger ?', 'Que visiter ?', 'Budget ?', 'Transport ?', 'Hôtels ?', 'Activités ?'
              ].map((q) => ActionChip(
                label: Text(q, style: const TextStyle(fontSize: 11)),
                onPressed: () => service.askQuestion(q),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswer(AssistantService service) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            colors: [AppColors.secondary.withValues(alpha: 0.05), AppColors.primary.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('Assistant TrTravel', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text(service.answer!, style: const TextStyle(fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratePlan(BuildContext context, AssistantService service) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final plan = service.generatePlan();
          _showPlan(context, plan);
        },
        icon: const Icon(Icons.map_rounded),
        label: Text('Générer mon itinéraire (${service.tripDuration} jours)'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showPlan(BuildContext context, TripPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider, borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(plan.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  ShareButton(plan: plan),
                ],
              ),
              Text('📍 ${plan.city} • ${plan.duration} jours', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text('💰 Budget estimé: ${plan.estimatedBudget}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              ...plan.days.map((day) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${day.dayNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(day.theme, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                          Text(day.estimatedCost, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...day.activities.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.food.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant, size: 16, color: AppColors.food),
                            const SizedBox(width: 8),
                            Expanded(child: Text(day.mealSuggestion, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
