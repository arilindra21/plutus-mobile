import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// iOS-style card variants
enum AppCardVariant {
  /// Standard elevated card with shadow
  elevated,

  /// Flat card with no shadow
  flat,

  /// Outlined card with border
  outlined,

  /// Grouped card for list sections (iOS grouped table style)
  grouped,
}

/// iOS-style card widget
/// Clean white background, subtle shadow, rounded corners
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.borderColor,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Card content
  final Widget child;

  /// Visual variant of the card
  final AppCardVariant variant;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Custom background color
  final Color? backgroundColor;

  /// Tap callback
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Custom elevation (shadow intensity)
  final int? elevation;

  /// Border color for outlined variant
  final Color? borderColor;

  /// Clip behavior
  final Clip clipBehavior;

  /// Factory for elevated card
  factory AppCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: padding,
      margin: margin,
      onTap: onTap,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Factory for flat card
  factory AppCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return AppCard(
      variant: AppCardVariant.flat,
      padding: padding,
      margin: margin,
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Factory for outlined card
  factory AppCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? borderColor,
  }) {
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: padding,
      margin: margin,
      onTap: onTap,
      borderColor: borderColor,
      child: child,
    );
  }

  /// Factory for grouped card (iOS grouped table style)
  factory AppCard.grouped({
    required Widget child,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.grouped,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? AppRadius.cardRadius;

    Color bgColor;
    List<BoxShadow> shadows;
    Border? border;

    switch (variant) {
      case AppCardVariant.elevated:
        bgColor = backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surface);
        shadows = isDark ? AppShadows.cardDark : AppShadows.card;
        border = null;
        break;

      case AppCardVariant.flat:
        bgColor = backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surface);
        shadows = AppShadows.none;
        border = null;
        break;

      case AppCardVariant.outlined:
        bgColor = backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surface);
        shadows = AppShadows.none;
        border = Border.all(
          color: borderColor ??
              (isDark ? AppColors.separatorDark : AppColors.separator),
          width: 1,
        );
        break;

      case AppCardVariant.grouped:
        bgColor = backgroundColor ??
            (isDark ? AppColors.surfaceSecondaryDark : AppColors.surface);
        shadows = AppShadows.none;
        border = null;
        break;
    }

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows,
        border: border,
      ),
      clipBehavior: clipBehavior,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// iOS-style section card for grouped content
/// Used for settings screens, forms, etc.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin,
    this.showDividers = true,
  });

  /// Section header text
  final String? header;

  /// Section footer text
  final String? footer;

  /// List of child widgets (typically AppListTile)
  final List<Widget> children;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Show dividers between children
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: margin ?? AppSpacing.horizontalMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Text(
                header!.toUpperCase(),
                style: AppTextStyles.caption1.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: AppRadius.cardRadius,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (showDividers && i < children.length - 1)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: 16,
                      color: isDark
                          ? AppColors.separatorDark
                          : AppColors.separator,
                    ),
                ],
              ],
            ),
          ),
          if (footer != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: Text(
                footer!,
                style: AppTextStyles.caption1.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple info card with icon and content
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackgroundColor ??
                  AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.allMd,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.footnote.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
              size: 20,
            ),
        ],
      ),
    );
  }
}
