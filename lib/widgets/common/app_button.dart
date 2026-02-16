import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

/// Reusable App Button Widget
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(buttonStyle.textColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: buttonStyle.textColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: buttonStyle.textColor,
                  fontSize: fontSize ?? AppTypography.fontSizeBase,
                ),
              ),
            ],
          );

    final button = Container(
      width: fullWidth ? double.infinity : null,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
      decoration: BoxDecoration(
        color: buttonStyle.backgroundColor,
        borderRadius: AppRadius.borderRadiusLg,
        border: buttonStyle.border,
      ),
      child: buttonChild,
    );

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        child: button,
      ),
    );
  }

  _ButtonStyle _getButtonStyle() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonStyle(
          backgroundColor: AppColors.primary,
          textColor: AppColors.primaryContrast,
          border: null,
        );
      case AppButtonVariant.secondary:
        return _ButtonStyle(
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          border: Border.all(color: AppColors.primary, width: 1),
        );
      case AppButtonVariant.danger:
        return _ButtonStyle(
          backgroundColor: AppColors.danger,
          textColor: AppColors.dangerContrast,
          border: null,
        );
      case AppButtonVariant.ghost:
        return _ButtonStyle(
          backgroundColor: Colors.transparent,
          textColor: AppColors.textSecondary,
          border: null,
        );
    }
  }
}

class _ButtonStyle {
  final Color backgroundColor;
  final Color textColor;
  final Border? border;

  _ButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    this.border,
  });
}
