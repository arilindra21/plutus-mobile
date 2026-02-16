import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/theme.dart';

/// iOS-style loading indicators
/// Cupertino spinner + skeleton shimmer
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.message,
  });

  /// Size of the loading indicator
  final AppLoadingSize size;

  /// Custom color
  final Color? color;

  /// Optional loading message
  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    final radius = switch (size) {
      AppLoadingSize.small => 8.0,
      AppLoadingSize.medium => 12.0,
      AppLoadingSize.large => 16.0,
    };

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoActivityIndicator(
            radius: radius,
            color: effectiveColor,
          ),
          AppSpacing.vSm,
          Text(
            message!,
            style: AppTextStyles.footnote.copyWith(
              color: effectiveColor,
            ),
          ),
        ],
      );
    }

    return CupertinoActivityIndicator(
      radius: radius,
      color: effectiveColor,
    );
  }
}

/// Loading sizes
enum AppLoadingSize {
  small,
  medium,
  large,
}

/// Full screen loading overlay
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  final String? message;
  final Color? backgroundColor;

  /// Show loading overlay
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (context) => AppLoadingOverlay(message: message),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark
                    ? AppColors.surfaceSecondaryDark
                    : AppColors.surface),
            borderRadius: AppRadius.modalRadius,
            boxShadow: AppShadows.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoading(size: AppLoadingSize.large),
              if (message != null) ...[
                AppSpacing.vMd,
                Text(
                  message!,
                  style: AppTextStyles.body.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline loading state (replaces content)
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message,
    this.padding,
  });

  final String? message;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? AppSpacing.allXl,
        child: AppLoading(message: message),
      ),
    );
  }
}

/// Shimmer skeleton loading effect
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  /// Skeleton shape widget
  final Widget child;

  /// Whether to show shimmer animation
  final bool isLoading;

  /// Base color of skeleton
  final Color? baseColor;

  /// Highlight color for shimmer
  final Color? highlightColor;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = widget.baseColor ??
        (isDark ? AppColors.fillSecondaryDark : AppColors.fillSecondary);

    final highlightColor = widget.highlightColor ??
        (isDark ? AppColors.fillTertiaryDark : AppColors.fillTertiary);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5 + _animation.value / 4,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton box shape
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.fillSecondaryDark : AppColors.fillSecondary,
        borderRadius: borderRadius ?? AppRadius.allSm,
      ),
    );
  }
}

/// Skeleton circle shape
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.fillSecondaryDark : AppColors.fillSecondary,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton line (text placeholder)
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: AppRadius.allXs,
    );
  }
}

/// Skeleton card (list item placeholder)
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
    this.padding,
  });

  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (showAvatar) ...[
              const SkeletonCircle(size: 44),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 120, height: 16),
                  if (showSubtitle) ...[
                    const SizedBox(height: 8),
                    const SkeletonLine(height: 12),
                  ],
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 12),
              const SkeletonBox(width: 60, height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton list (multiple card placeholders)
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showDividers = true,
    this.padding,
  });

  final int itemCount;
  final bool showAvatar;
  final bool showSubtitle;
  final bool showDividers;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(
        itemCount,
        (index) => Column(
          children: [
            SkeletonCard(
              showAvatar: showAvatar,
              showSubtitle: showSubtitle,
              padding: padding,
            ),
            if (showDividers && index < itemCount - 1)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: showAvatar ? 72 : 16,
                color: isDark ? AppColors.separatorDark : AppColors.separator,
              ),
          ],
        ),
      ),
    );
  }
}
