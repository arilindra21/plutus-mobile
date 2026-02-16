import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// iOS-style bottom sheet with drag handle
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.onClose,
    this.padding,
    this.maxHeight,
    this.backgroundColor,
  });

  /// Content of the bottom sheet
  final Widget child;

  /// Optional title
  final String? title;

  /// Show drag handle indicator
  final bool showDragHandle;

  /// Show close button
  final bool showCloseButton;

  /// Close callback
  final VoidCallback? onClose;

  /// Content padding
  final EdgeInsetsGeometry? padding;

  /// Maximum height (fraction of screen)
  final double? maxHeight;

  /// Background color
  final Color? backgroundColor;

  /// Show modal bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        maxHeight: maxHeight,
        padding: padding,
        backgroundColor: backgroundColor ??
            (isDark ? AppColors.surfaceSecondaryDark : AppColors.surface),
        onClose: () => Navigator.pop(context),
        child: child,
      ),
    );
  }

  /// Show action sheet (iOS style)
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AppBottomSheetAction> actions,
    AppBottomSheetAction? cancelAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Action group
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSecondaryDark
                      : AppColors.surface,
                  borderRadius: AppRadius.modalRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null || message != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Column(
                          children: [
                            if (title != null)
                              Text(
                                title,
                                style: AppTextStyles.footnote.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (title != null && message != null)
                              const SizedBox(height: 4),
                            if (message != null)
                              Text(
                                message,
                                style: AppTextStyles.caption1.copyWith(
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    if (title != null || message != null)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: isDark
                            ? AppColors.separatorDark
                            : AppColors.separator,
                      ),
                    ...actions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final action = entry.value;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (index > 0)
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: isDark
                                  ? AppColors.separatorDark
                                  : AppColors.separator,
                            ),
                          _ActionButton(action: action),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Cancel button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSecondaryDark
                      : AppColors.surface,
                  borderRadius: AppRadius.modalRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: _ActionButton(
                  action: cancelAction ??
                      AppBottomSheetAction(
                        title: 'Cancel',
                        onTap: () => Navigator.pop(context),
                        isBold: true,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor = backgroundColor ??
        (isDark ? AppColors.surfaceSecondaryDark : AppColors.surface);

    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * effectiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (showDragHandle)
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray4Dark : AppColors.gray4,
                borderRadius: AppRadius.allFull,
              ),
            ),

          // Header with title and close button
          if (title != null || showCloseButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (showCloseButton)
                    GestureDetector(
                      onTap: onClose ?? () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.fillTertiaryDark
                              : AppColors.fillTertiary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 30),
                  Expanded(
                    child: title != null
                        ? Text(
                            title!,
                            style: AppTextStyles.headline.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),

          // Content
          Flexible(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action for action sheet
class AppBottomSheetAction {
  const AppBottomSheetAction({
    required this.title,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
    this.isBold = false,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDestructive;
  final bool isBold;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final AppBottomSheetAction action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color textColor;
    if (action.isDestructive) {
      textColor = AppColors.error;
    } else {
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: 20,
                color: textColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              action.title,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontWeight: action.isBold ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style confirmation dialog
class AppConfirmDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return AppBottomSheet.showActionSheet<bool>(
      context: context,
      title: title,
      message: message,
      actions: [
        AppBottomSheetAction(
          title: confirmText,
          isDestructive: isDestructive,
          onTap: () {},
        ),
      ],
      cancelAction: AppBottomSheetAction(
        title: cancelText,
        onTap: () {},
        isBold: true,
      ),
    );
  }
}
