import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/theme.dart';

/// iOS-style list tile widget
/// Grouped table row style with optional chevron
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconBackgroundColor,
    this.trailing,
    this.trailingText,
    this.showChevron = true,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
  });

  /// Primary text
  final String title;

  /// Secondary text
  final String? subtitle;

  /// Leading widget
  final Widget? leading;

  /// Leading icon (creates iOS-style colored icon box)
  final IconData? leadingIcon;

  /// Color for leading icon
  final Color? leadingIconColor;

  /// Background color for leading icon box
  final Color? leadingIconBackgroundColor;

  /// Trailing widget
  final Widget? trailing;

  /// Trailing text (shown before chevron)
  final String? trailingText;

  /// Show chevron arrow
  final bool showChevron;

  /// Tap callback
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Custom content padding
  final EdgeInsetsGeometry? contentPadding;

  /// Dense mode for compact lists
  final bool dense;

  /// Whether the tile is enabled
  final bool enabled;

  /// Whether the tile is selected
  final bool selected;

  /// Factory for navigation tile (with chevron)
  factory AppListTile.navigation({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Color? leadingIconColor,
    Color? leadingIconBackgroundColor,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      leadingIcon: leadingIcon,
      leadingIconColor: leadingIconColor,
      leadingIconBackgroundColor: leadingIconBackgroundColor,
      trailingText: trailingText,
      showChevron: true,
      onTap: onTap,
    );
  }

  /// Factory for toggle tile (with switch)
  factory AppListTile.toggle({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Color? leadingIconColor,
    Color? leadingIconBackgroundColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      leadingIcon: leadingIcon,
      leadingIconColor: leadingIconColor,
      leadingIconBackgroundColor: leadingIconBackgroundColor,
      showChevron: false,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.success,
      ),
    );
  }

  /// Factory for checkbox tile
  factory AppListTile.checkbox({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      showChevron: false,
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: () => onChanged(!value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveTextColor = enabled
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary);

    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    final chevronColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    final selectedColor = AppColors.primary.withOpacity(0.08);

    // Build leading widget
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (leadingIcon != null) {
      final iconColor = leadingIconColor ?? Colors.white;
      final iconBgColor = leadingIconBackgroundColor ?? AppColors.primary;

      leadingWidget = Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          leadingIcon,
          size: 17,
          color: iconColor,
        ),
      );
    }

    // Build trailing widget
    Widget? trailingWidget;
    if (trailing != null) {
      trailingWidget = trailing;
    } else {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText!,
              style: AppTextStyles.body.copyWith(
                color: subtitleColor,
              ),
            ),
          if (showChevron && onTap != null) ...[
            if (trailingText != null) const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: chevronColor,
            ),
          ],
        ],
      );
    }

    final effectivePadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: dense ? 10 : 12,
        );

    Widget content = Container(
      color: selected ? selectedColor : Colors.transparent,
      padding: effectivePadding,
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: effectiveTextColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.footnote.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// iOS-style destructive list tile (for delete actions)
class AppDestructiveListTile extends StatelessWidget {
  const AppDestructiveListTile({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    this.centered = true,
  });

  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style header for grouped lists
class AppListHeader extends StatelessWidget {
  const AppListHeader({
    super.key,
    required this.title,
    this.action,
    this.padding,
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding ??
          const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption1.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// iOS-style footer for grouped lists
class AppListFooter extends StatelessWidget {
  const AppListFooter({
    super.key,
    required this.text,
    this.padding,
  });

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 16, right: 16, top: 6),
      child: Text(
        text,
        style: AppTextStyles.caption1.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
