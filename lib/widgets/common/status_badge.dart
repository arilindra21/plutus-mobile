import 'package:flutter/material.dart';
import '../../constants/status_config.dart';
import '../../core/design_tokens.dart';

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final int status;
  final double fontSize;
  final EdgeInsets? padding;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = AppTypography.fontSizeXs,
    this.padding,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = getStatusConfig(status);
    final effectiveFontSize = small ? AppTypography.fontSizeXs - 2 : fontSize;

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: small ? AppSpacing.xs : AppSpacing.sm,
            vertical: small ? 2 : AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(
          color: config.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: effectiveFontSize,
          fontWeight: AppTypography.fontWeightMedium,
          color: config.textColor,
        ),
      ),
    );
  }
}
