import 'package:flutter/material.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/widgets.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      appBar: AppBar(
        title: Text(l.guide),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GuideCard(
            icon: Icons.rocket_launch_rounded,
            title: l.guideGettingStarted,
            subtitle: l.guideGettingStartedDesc,
            detail: l.guideDetailGettingStarted,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.auto_awesome_rounded,
            title: l.guideFeatures,
            subtitle: l.guideFeaturesDesc,
            detail: l.guideDetailFeatures,
            color: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.cloud_off_rounded,
            title: l.guideOffline,
            subtitle: l.guideOfflineDesc,
            detail: l.guideDetailOffline,
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.lightbulb_rounded,
            title: l.guideTips,
            subtitle: l.guideTipsDesc,
            detail: l.guideDetailTips,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.sync_rounded,
            title: l.guideAccount,
            subtitle: l.guideAccountDesc,
            detail: l.guideDetailAccount,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _GuideCard(
            icon: Icons.warning_rounded,
            title: l.guideEmergency,
            subtitle: l.guideEmergencyDesc,
            detail: l.guideDetailEmergency,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final Color color;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.color,
  });

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(widget.icon, color: widget.color),
            ),
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(widget.subtitle, style: const TextStyle(fontSize: 13)),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.detail, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
