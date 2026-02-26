import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/cupertino.dart' as cupertino;
import '../../core/design_tokens.dart';
import '../buttons/buttons.dart';

/// Loading indicator type
enum LoadingType {
  circular,
  linear,
  shimmer,
}

/// Reusable screen header with gradient
///
/// Provides consistent header styling across all screens.
class ScreenHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget? leading;
  final bool useGradient;
  final Color? backgroundColor;

  const ScreenHeader({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.leading,
    this.useGradient = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final backLeading = leading ??
        (showBackButton
            ? GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    cupertino.CupertinoIcons.back,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
            : null);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: useGradient && backgroundColor == null
          ? const BoxDecoration(
              gradient: AppColors.headerGradient,
            )
          : BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
            ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBackButton || leading != null)
              backLeading!,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: 16),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized loading indicator
///
/// Provides multiple loading styles for different contexts.
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    final effectiveColor = color ?? FintechColors.primary;

    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: effectiveColor,
          ),
        );
      case LoadingType.linear:
        return SizedBox(
          width: size * 2,
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.surfaceVariant,
            color: effectiveColor,
          ),
        );
      case LoadingType.shimmer:
        return _ShimmerPlaceholder(size: size);
    }
  }
}

/// Shimmer loading placeholder
class _ShimmerPlaceholder extends StatelessWidget {
  final double size;

  const _ShimmerPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: _ShimmerBox(
        width: double.infinity,
        height: size,
      ),
    );
  }
}

/// Shimmer box animation
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({
    required this.width,
    required this.height,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            AppColors.surfaceVariant,
            AppColors.surfaceVariant.withValues(alpha: 0.3),
            AppColors.surfaceVariant,
          ],
        ),
      ),
      child: _ShimmerContent(
        animation: _animation,
      ),
    );
  }
}

/// Shimmer content animation
class _ShimmerContent extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerContent({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Standardized empty state
///
/// Provides consistent empty state UI across the app.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? FintechColors.categoryBlue;
    final effectiveBgColor = iconBackgroundColor ?? FintechColors.categoryBlueBg;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: effectiveBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: effectiveIconColor,
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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null) ...[
            const SizedBox(height: 24),
            AppButton(
              label: actionLabel ?? 'Action',
              onPressed: onAction,
              style: ButtonStyle.primary,
              variant: ButtonVariant.fintech,
            ),
          ],
        ],
      ),
    );
  }
}

/// Pull-to-refresh wrapper
///
/// Provides consistent refresh indicator styling.
class AppRefreshIndicator extends StatelessWidget {
  final RefreshCallback onRefresh;
  final String? refreshText;
  final Color? color;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    this.refreshText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? FintechColors.primary,
      child: Text(
        refreshText ?? 'Pull to refresh',
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
