import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/design_tokens.dart';

/// Fintech-style Card with subtle shadow
class FintechCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const FintechCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
        boxShadow: boxShadow ?? AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(16),
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
        ),
      ),
    );

    return card;
  }
}

/// Category icon with colored circular background
class CategoryIconCircle extends StatelessWidget {
  final String? icon;
  final String? categoryCode;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;

  const CategoryIconCircle({
    super.key,
    this.icon,
    this.categoryCode,
    this.size = 44,
    this.iconColor,
    this.backgroundColor,
  });

  // Get color based on category code
  static Map<String, Color> _getCategoryColors(String? code) {
    final Map<String, Map<String, Color>> categoryMap = {
      'food': {'icon': FintechColors.categoryOrange, 'bg': FintechColors.categoryOrangeBg},
      'meals': {'icon': FintechColors.categoryOrange, 'bg': FintechColors.categoryOrangeBg},
      'transport': {'icon': FintechColors.categoryBlue, 'bg': FintechColors.categoryBlueBg},
      'travel': {'icon': FintechColors.categoryCyan, 'bg': FintechColors.categoryCyanBg},
      'accommodation': {'icon': FintechColors.categoryIndigo, 'bg': FintechColors.categoryIndigoBg},
      'office': {'icon': FintechColors.categoryTeal, 'bg': FintechColors.categoryTealBg},
      'supplies': {'icon': FintechColors.categoryTeal, 'bg': FintechColors.categoryTealBg},
      'equipment': {'icon': FintechColors.categoryPurple, 'bg': FintechColors.categoryPurpleBg},
      'entertainment': {'icon': FintechColors.categoryPink, 'bg': FintechColors.categoryPinkBg},
      'client': {'icon': FintechColors.categoryGreen, 'bg': FintechColors.categoryGreenBg},
      'marketing': {'icon': FintechColors.categoryRed, 'bg': FintechColors.categoryRedBg},
      'utilities': {'icon': FintechColors.categoryYellow, 'bg': FintechColors.categoryYellowBg},
      'software': {'icon': FintechColors.categoryIndigo, 'bg': FintechColors.categoryIndigoBg},
      'training': {'icon': FintechColors.categoryGreen, 'bg': FintechColors.categoryGreenBg},
      'other': {'icon': FintechColors.secondary, 'bg': const Color(0xFFF1F5F9)},
    };

    final key = code?.toLowerCase() ?? 'other';
    return {
      'icon': categoryMap[key]?['icon'] ?? FintechColors.secondary,
      'bg': categoryMap[key]?['bg'] ?? const Color(0xFFF1F5F9),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColors(categoryCode);
    final bgColor = backgroundColor ?? colors['bg']!;
    final fgColor = iconColor ?? colors['icon']!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null && icon!.isNotEmpty
            ? Text(
                icon!,
                style: TextStyle(fontSize: size * 0.45),
              )
            : Icon(
                CupertinoIcons.doc_text_fill,
                color: fgColor,
                size: size * 0.45,
              ),
      ),
    );
  }
}

/// Section header with title and optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FintechColors.categoryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formatted amount text with currency
class AmountText extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showSign;
  final bool colorize;

  const AmountText({
    super.key,
    required this.amount,
    this.currency = 'IDR',
    this.style,
    this.showSign = false,
    this.colorize = false,
  });

  String _formatAmount(double value) {
    final absValue = value.abs();
    if (currency == 'IDR') {
      final formatted = absValue.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return 'Rp $formatted';
    }
    return '$currency ${absValue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    Color? textColor;
    String prefix = '';

    if (colorize) {
      textColor = isNegative ? FintechColors.categoryRed : FintechColors.categoryGreen;
    }

    if (showSign && amount != 0) {
      prefix = isNegative ? '-' : '+';
    }

    final defaultStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textColor ?? AppColors.textPrimary,
    );

    return Text(
      '$prefix${_formatAmount(amount)}',
      style: style?.copyWith(color: textColor) ?? defaultStyle,
    );
  }
}

/// Pill-shaped status badge
class StatusPill extends StatelessWidget {
  final int status;
  final String? customLabel;
  final double fontSize;

  const StatusPill({
    super.key,
    required this.status,
    this.customLabel,
    this.fontSize = 11,
  });

  Map<String, dynamic> _getStatusConfig(int status) {
    switch (status) {
      case 0:
        return {
          'label': 'Draft',
          'color': AppColors.statusDraft,
          'bgColor': const Color(0xFFF1F5F9),
        };
      case 1:
        return {
          'label': 'Pending',
          'color': AppColors.statusPending,
          'bgColor': FintechColors.categoryYellowBg,
        };
      case 2:
        return {
          'label': 'Submitted',
          'color': FintechColors.categoryBlue,
          'bgColor': FintechColors.categoryBlueBg,
        };
      case 3:
        return {
          'label': 'Pending Approval',
          'color': AppColors.statusPending,
          'bgColor': FintechColors.categoryYellowBg,
        };
      case 4:
        return {
          'label': 'Approved',
          'color': AppColors.statusApproved,
          'bgColor': FintechColors.categoryGreenBg,
        };
      case 5:
        return {
          'label': 'Completed',
          'color': AppColors.statusApproved,
          'bgColor': FintechColors.categoryGreenBg,
        };
      case 6:
        return {
          'label': 'Rejected',
          'color': AppColors.statusRejected,
          'bgColor': FintechColors.categoryRedBg,
        };
      case 7:
        return {
          'label': 'Returned',
          'color': AppColors.statusReturned,
          'bgColor': FintechColors.categoryOrangeBg,
        };
      default:
        return {
          'label': 'Unknown',
          'color': AppColors.statusDraft,
          'bgColor': const Color(0xFFF1F5F9),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    final Color statusColor = config['color'];
    final Color bgColor = config['bgColor'];
    final String label = customLabel ?? config['label'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }
}

/// Expense list tile with fintech styling
class ExpenseListTile extends StatelessWidget {
  final String? icon;
  final String? categoryCode;
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final int status;
  final VoidCallback? onTap;
  final bool showChevron;

  const ExpenseListTile({
    super.key,
    this.icon,
    this.categoryCode,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.currency = 'IDR',
    required this.status,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Category Icon
              CategoryIconCircle(
                icon: icon,
                categoryCode: categoryCode,
                size: 44,
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(
                    amount: amount,
                    currency: currency,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusPill(status: status),
                ],
              ),

              if (showChevron) ...[
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? FintechColors.categoryBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor ?? FintechColors.categoryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Gradient header container (for AppBars)
class GradientHeader extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GradientHeader({
    super.key,
    required this.child,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: child,
    );
  }
}

/// Primary action button with fintech styling
class FintechButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FintechButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? FintechColors.primary;
    final fgColor = foregroundColor ?? Colors.white;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Alert banner for notifications
class AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const AlertBanner({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: iconColor,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick action card
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FintechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
