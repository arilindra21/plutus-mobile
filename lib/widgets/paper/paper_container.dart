import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Paper Container Component
///
/// A simple container with Paper design system styling.
class PaperContainer extends StatelessWidget {
  const PaperContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? PaperColor.white,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.sm),
        border: showBorder
            ? Border.all(color: borderColor ?? PaperArtboardColor.borderLight)
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(15.0),
      child: child,
    );
  }
}

/// Paper Card Component
///
/// A card with elevation and shadow styling.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.elevation = 1,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? PaperArtboardColor.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
        border: Border.all(color: PaperArtboardColor.border),
        boxShadow: elevation > 0 ? AppShadows.sm : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(PaperSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Paper Section Header
///
/// A styled section header with optional action.
class PaperSectionHeader extends StatelessWidget {
  const PaperSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: PaperSpacing.lg,
        vertical: PaperSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PaperText.headingLarge.primary,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: PaperText.bodySmall.secondary,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Paper Divider
///
/// A styled horizontal divider.
class PaperDivider extends StatelessWidget {
  const PaperDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 1,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: color ?? PaperArtboardColor.divider,
    );
  }
}

/// Paper Empty State
///
/// Displays when content is empty.
class PaperEmptyState extends StatelessWidget {
  const PaperEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  final String message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PaperSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 64,
                color: PaperIconColor.lowerEmphasis,
              ),
            const SizedBox(height: PaperSpacing.lg),
            Text(
              message,
              style: PaperText.bodyRegular.secondary,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: PaperSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
