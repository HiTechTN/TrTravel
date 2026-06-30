import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/shimmer_loading.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import '../services/currency_service.dart';
import '../models/currency_rate.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final service = context.read<CurrencyService>();
    _amountCtrl = TextEditingController(text: _formatAmount(service.amount));
    WidgetsBinding.instance.addPostFrameCallback((_) => service.updateRates());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Convertisseur',
            subtitle: 'Taux de change en temps réel',
            icon: Icons.monetization_on_rounded,
          ),
          Expanded(
            child: Consumer<CurrencyService>(
              builder: (_, service, __) {
                if (service.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerList(itemCount: 4),
                  );
                }
                if (!_amountCtrl.text.isNotEmpty ||
                    double.tryParse(_amountCtrl.text) != service.amount) {
                  _amountCtrl.text = _formatAmount(service.amount);
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildCurrencySelector(service),
                      const SizedBox(height: 16),
                      _buildAmountInput(service),
                      const SizedBox(height: 16),
                      _buildResultCard(service),
                      const SizedBox(height: 16),
                      _buildQuickAmounts(service),
                      const SizedBox(height: 16),
                      _buildAllRates(service),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(CurrencyService service) {
    return GlassEffect(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _CurrencyDropdown(service: service, isFrom: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  onPressed: () => service.swapCurrencies(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              Expanded(child: _CurrencyDropdown(service: service, isFrom: false)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1 ${service.fromCurrency} = ${CurrencyData.convert(1, service.fromCurrency, service.toCurrency)} ${service.toCurrency}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(CurrencyService service) {
    return GlassEffect(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Montant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '${service.getFromSymbol()} ',
              prefixStyle: const TextStyle(fontSize: 18),
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) service.setAmount(parsed);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(CurrencyService service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${service.amount.toStringAsFixed(0)} ${service.getFromSymbol()} ${service.fromCurrency}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${service.result} ${service.getToSymbol()} ${service.toCurrency}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          if (service.lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour: ${service.lastUpdated!.substring(0, 10)}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(CurrencyService service) {
    return GlassEffect(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Montants rapides', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: service.quickAmounts.map((qa) {
              final isSelected = service.amount.toStringAsFixed(0) == qa['amount'];
              return ActionChip(
                label: Text(qa['label']!),
                onPressed: () {
                  final amt = double.parse(qa['amount']!);
                  service.setAmount(amt);
                  _amountCtrl.text = _formatAmount(amt);
                },
                color: WidgetStatePropertyAll(isSelected ? AppColors.primary : null),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRates(CurrencyService service) {
    return GlassEffect(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tous les taux', style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => service.updateRates(),
                icon: service.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Actualiser'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...service.currencies.map((c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(c.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.code, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(c.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${CurrencyData.convert(1, service.fromCurrency, c.code)} ${c.code}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('1 € = ${c.rateToEur.toStringAsFixed(2)} ${c.code}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final CurrencyService service;
  final bool isFrom;

  const _CurrencyDropdown({required this.service, required this.isFrom});

  @override
  Widget build(BuildContext context) {
    final value = isFrom ? service.fromCurrency : service.toCurrency;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
      items: service.currencies.map((c) {
        return DropdownMenuItem(
          value: c.code,
          child: Text('${c.flag} ${c.code}', style: const TextStyle(fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) {
          if (isFrom) {
            service.setFromCurrency(v);
          } else {
            service.setToCurrency(v);
          }
        }
      },
    );
  }
}
