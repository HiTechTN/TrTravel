import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_durations.dart';

enum PageTransition { slide, fade, scale }

class ModernScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final PageTransition transition;
  final bool resizeToAvoidBottomInset;

  const ModernScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.transition = PageTransition.fade,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  State<ModernScaffold> createState() => _ModernScaffoldState();
}

class _ModernScaffoldState extends State<ModernScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.pageTransition,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTransition(Widget child) {
    switch (widget.transition) {
      case PageTransition.slide:
        return SlideTransition(position: _slideAnimation, child: child);
      case PageTransition.scale:
        return ScaleTransition(scale: _scaleAnimation, child: child);
      case PageTransition.fade:
        return FadeTransition(opacity: _fadeAnimation, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? AppColors.background,
      appBar: widget.appBar as PreferredSizeWidget?,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: AnimatedSwitcher(
        duration: AppDurations.normal,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey(widget.body.hashCode),
          child: _buildTransition(widget.body),
        ),
      ),
    );
  }
}
