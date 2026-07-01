import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';

class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2A44) : AppColors.shimmer;
    final shimmer = isDark ? const Color(0xFF3A3A54) : Colors.grey.shade100;
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.sm);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, shimmer, base],
          ),
        ),
      ),
    );
  }
}

class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const AppShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 76,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, __) => Row(
        children: [
          AppShimmer(width: 44, height: 44, borderRadius: BorderRadius.circular(AppRadius.md)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: 200, height: 14),
                const SizedBox(height: 8),
                AppShimmer(width: 140, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
