import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/design_tokens.dart';

/// Button style variants
enum ButtonStyle {
  primary,
  secondary,
  danger,
  ghost,
  success,
}

/// Button design system variant
enum ButtonVariant {
  fintech,
  paper,
  common,
}

/// Get primary color from design tokens
extension ButtonStyleExtension on ButtonStyle {
  Color get color {
    switch (this) {
      case ButtonStyle.primary:
        return FintechColors.primary;
      case ButtonStyle.secondary:
        return FintechColors.primary.withValues(alpha: 0.8);
      case ButtonStyle.danger:
        return AppColors.statusRejected;
      case ButtonStyle.ghost:
        return Colors.transparent;
      case ButtonStyle.success:
        return AppColors.statusApproved;
    }
  }
}

/// Unified button system with support for multiple design systems
///
/// This widget consolidates AppButton, FintechButton, and PaperButton
/// into a single, configurable component.
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final bool isLoading;
  final bool fullWidth;
  final ButtonVariant variant;
  final double? height;
  final double? iconSize;
  final bool isSmall;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = ButtonStyle.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.variant = ButtonVariant.fintech,
    this.height,
    this.iconSize,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final effectiveHeight = height ?? (isSmall ? 40.0 : 52.0);

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: effectiveHeight,
        width: fullWidth ? double.infinity : null,
        decoration: _buildDecoration(),
        child: Center(
          child: isLoading ? _buildLoadingIndicator() : _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (style) {
      case ButtonStyle.primary:
        return _buildPrimaryDecoration();
      case ButtonStyle.secondary:
        return _buildSecondaryDecoration();
      case ButtonStyle.danger:
        return _buildDangerDecoration();
      case ButtonStyle.ghost:
        return _buildGhostDecoration();
      case ButtonStyle.success:
        return _buildSuccessDecoration();
    }
  }

  BoxDecoration _buildPrimaryDecoration() {
    switch (variant) {
      case ButtonVariant.fintech:
        return BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: FintechColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonVariant.paper:
        return BoxDecoration(
          color: FintechColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.button,
        );
      case ButtonVariant.common:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary),
        );
    }
  }

  BoxDecoration _buildSecondaryDecoration() {
    return BoxDecoration(
      color: FintechColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
  }

  BoxDecoration _buildDangerDecoration() {
    return BoxDecoration(
      color: AppColors.statusRejected.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
  }

  BoxDecoration _buildGhostDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
  }

  BoxDecoration _buildSuccessDecoration() {
    return BoxDecoration(
      color: AppColors.statusApproved.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    final textColor = _getTextColor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon!,
            size: iconSize ?? 20,
            color: textColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 14 : 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Color _getTextColor() {
    switch (style) {
      case ButtonStyle.primary:
      case ButtonStyle.secondary:
      case ButtonStyle.danger:
      case ButtonStyle.success:
        return variant == ButtonVariant.paper || variant == ButtonVariant.common
            ? Colors.white
            : Colors.white;
      case ButtonStyle.ghost:
        return AppColors.textPrimary;
    }
  }
}

/// Icon-only button for secondary actions
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isEnabled
                ? (backgroundColor ?? AppColors.surfaceVariant)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size * 0.4,
            color: isEnabled
                ? (iconColor ?? AppColors.textMuted)
                : AppColors.border,
          ),
        ),
      ),
    );
  }
}
