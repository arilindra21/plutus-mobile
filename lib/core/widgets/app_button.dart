import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/theme.dart';

/// iOS-style button variants
enum AppButtonVariant {
  /// Primary filled button (blue background)
  primary,

  /// Secondary outlined button
  secondary,

  /// Text-only button (no background)
  text,

  /// Destructive/danger button (red)
  destructive,

  /// Ghost button (very subtle)
  ghost,
}

/// Button sizes
enum AppButtonSize {
  /// Large button (50px height)
  large,

  /// Medium button (44px height)
  medium,

  /// Small button (36px height)
  small,

  /// Compact button (32px height)
  compact,
}

/// iOS-style button with multiple variants
/// Supports primary, secondary, text, destructive, and ghost styles
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Visual variant of the button
  final AppButtonVariant variant;

  /// Size variant of the button
  final AppButtonSize size;

  /// Optional icon to display
  final IconData? icon;

  /// Position of the icon (leading or trailing)
  final IconPosition iconPosition;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Whether the button should take full width
  final bool isFullWidth;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Custom background color (overrides variant)
  final Color? backgroundColor;

  /// Custom foreground color (overrides variant)
  final Color? foregroundColor;

  /// Factory constructor for primary button
  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.large,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      size: size,
    );
  }

  /// Factory constructor for secondary button
  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.large,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      size: size,
    );
  }

  /// Factory constructor for text button
  factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.medium,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.text,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      size: size,
      isFullWidth: false,
    );
  }

  /// Factory constructor for destructive button
  factory AppButton.destructive({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.large,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.destructive,
      icon: icon,
      isLoading: isLoading,
      isDisabled: isDisabled,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isDisabled || isLoading ? null : onPressed;
    final colors = _getColors(context);
    final buttonSize = _getSize();

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CupertinoActivityIndicator(
              color: colors.foreground,
              radius: 9,
            ),
          ),
        ] else ...[
          if (icon != null && iconPosition == IconPosition.leading) ...[
            Icon(icon, size: buttonSize.iconSize, color: colors.foreground),
            AppSpacing.hSm,
          ],
          Text(
            label,
            style: buttonSize.textStyle.copyWith(color: colors.foreground),
          ),
          if (icon != null && iconPosition == IconPosition.trailing) ...[
            AppSpacing.hSm,
            Icon(icon, size: buttonSize.iconSize, color: colors.foreground),
          ],
        ],
      ],
    );

    final effectiveBorderRadius = borderRadius ?? AppRadius.buttonRadius;

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: buttonSize.height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.background,
              foregroundColor: colors.foreground,
              disabledBackgroundColor: colors.background.withOpacity(0.5),
              disabledForegroundColor: colors.foreground.withOpacity(0.5),
              elevation: 0,
              padding: buttonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
            ),
            child: buttonContent,
          ),
        );

      case AppButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: buttonSize.height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.foreground,
              side: BorderSide(
                color: isDisabled ? colors.foreground.withOpacity(0.3) : colors.foreground,
                width: 1.5,
              ),
              padding: buttonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
            ),
            child: buttonContent,
          ),
        );

      case AppButtonVariant.text:
      case AppButtonVariant.ghost:
        return SizedBox(
          height: buttonSize.height,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              foregroundColor: colors.foreground,
              padding: buttonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
              backgroundColor:
                  variant == AppButtonVariant.ghost ? AppColors.fillTertiary : null,
            ),
            child: buttonContent,
          ),
        );
    }
  }

  _ButtonColors _getColors(BuildContext context) {
    if (backgroundColor != null || foregroundColor != null) {
      return _ButtonColors(
        background: backgroundColor ?? AppColors.primary,
        foreground: foregroundColor ?? Colors.white,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return const _ButtonColors(
          background: AppColors.primary,
          foreground: Colors.white,
        );
      case AppButtonVariant.secondary:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
        );
      case AppButtonVariant.text:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
        );
      case AppButtonVariant.destructive:
        return const _ButtonColors(
          background: AppColors.error,
          foreground: Colors.white,
        );
      case AppButtonVariant.ghost:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textSecondary,
        );
    }
  }

  _ButtonSize _getSize() {
    switch (size) {
      case AppButtonSize.large:
        return _ButtonSize(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.buttonLarge,
          iconSize: 20,
        );
      case AppButtonSize.medium:
        return _ButtonSize(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: AppTextStyles.buttonMedium,
          iconSize: 18,
        );
      case AppButtonSize.small:
        return _ButtonSize(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonSmall,
          iconSize: 16,
        );
      case AppButtonSize.compact:
        return _ButtonSize(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          textStyle: AppTextStyles.buttonSmall,
          iconSize: 14,
        );
    }
  }
}

/// Icon button (iOS style)
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: AppRadius.allMd,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: color ?? AppColors.primary,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Position of icon in button
enum IconPosition { leading, trailing }

class _ButtonColors {
  const _ButtonColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}

class _ButtonSize {
  const _ButtonSize({
    required this.height,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
  });
  final double height;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
}
