import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_durations.dart';

class AnimatedNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AnimatedNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AnimatedNavBarItem> items;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(widget.items.length, (_) {
      return AnimationController(
        vsync: this,
        duration: AppDurations.fast,
      );
    });
    _bounceAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    widget.onTap(index);
    _bounceControllers[index].forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primary;
    final inactiveColor = widget.inactiveColor ?? AppColors.textHint;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              final isActive = index == widget.currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _bounceAnimations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _bounceAnimations[index].value,
                        child: AnimatedContainer(
                          duration: AppDurations.normal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? activeColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive
                                    ? widget.items[index].activeIcon
                                    : widget.items[index].icon,
                                color:
                                    isActive ? activeColor : inactiveColor,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.items[index].label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color:
                                      isActive ? activeColor : inactiveColor,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: activeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
