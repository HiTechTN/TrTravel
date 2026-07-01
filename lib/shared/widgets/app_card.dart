import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadows;
  final bool interactive;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.color,
    this.gradient,
    this.borderRadius,
    this.shadows,
    this.interactive = false,
  });

  factory AppCard.outlined({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    return AppCard(
      onTap: onTap,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      child: child,
    );
  }

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.lg);

    Widget card = Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: widget.color ?? (widget.gradient != null ? null : Theme.of(context).cardTheme.color),
        gradient: widget.gradient,
        boxShadow: widget.shadows ?? AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: radius is BorderRadius ? radius : BorderRadius.circular(AppRadius.lg),
                onTap: widget.onTap,
                child: Padding(
                  padding: widget.padding ?? AppSpacing.card,
                  child: widget.child,
                ),
              ),
            )
          : Padding(
              padding: widget.padding ?? AppSpacing.card,
              child: widget.child,
            ),
    );

    if (widget.onTap != null && widget.interactive) {
      card = GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap!();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: card,
        ),
      );
    }

    return card;
  }
}
