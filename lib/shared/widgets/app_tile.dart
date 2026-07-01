import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/app_card.dart';

class AppTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double iconSize;

  const AppTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.iconBackground,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBackground ?? iconColor.withValues(alpha: 0.1);

    return AppCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: padding ?? AppSpacing.listItem,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
            ),
        ],
      ),
    );
  }
}

class AppTileSimple extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppTileSimple({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: padding ?? AppSpacing.listItem,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
            ),
        ],
      ),
    );
  }
}
