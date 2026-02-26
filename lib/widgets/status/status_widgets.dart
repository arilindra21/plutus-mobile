import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/design_tokens.dart';

/// Status style variants
enum StatusStyle {
  pill,
  badge,
  tag,
  dot,
}

/// Status configuration mapping
class StatusConfig {
  final String label;
  final Color color;
  final Color backgroundColor;

  StatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });
}

/// Unified status component with configurable styles
///
/// This consolidates StatusBadge and StatusPill into a single,
/// more flexible component.
class StatusBadge extends StatelessWidget {
  final int status;
  final String? customLabel;
  final StatusStyle style;
  final double fontSize;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.style = StatusStyle.pill,
    this.fontSize = 11,
    this.isCompact = false,
  });

  static final Map<int, StatusConfig> _statusConfigs = {
    0: StatusConfig(
      label: 'Draft',
      color: AppColors.statusDraft,
      backgroundColor: const Color(0xFFF1F5F9),
    ),
    1: StatusConfig(
      label: 'Pending',
      color: AppColors.statusPending,
      backgroundColor: FintechColors.categoryYellowBg,
    ),
    2: StatusConfig(
      label: 'Submitted',
      color: FintechColors.categoryBlue,
      backgroundColor: FintechColors.categoryBlueBg,
    ),
    3: StatusConfig(
      label: 'Pending Approval',
      color: AppColors.statusPending,
      backgroundColor: FintechColors.categoryYellowBg,
    ),
    4: StatusConfig(
      label: 'Approved',
      color: AppColors.statusApproved,
      backgroundColor: FintechColors.categoryGreenBg,
    ),
    5: StatusConfig(
      label: 'Completed',
      color: AppColors.statusApproved,
      backgroundColor: FintechColors.categoryGreenBg,
    ),
    6: StatusConfig(
      label: 'Rejected',
      color: AppColors.statusRejected,
      backgroundColor: FintechColors.categoryRedBg,
    ),
    7: StatusConfig(
      label: 'Returned',
      color: AppColors.statusReturned,
      backgroundColor: FintechColors.categoryOrangeBg,
    ),
  };

  StatusConfig get _config {
    return _statusConfigs[status] ??
        StatusConfig(
          label: 'Unknown',
          color: AppColors.statusDraft,
          backgroundColor: const Color(0xFFF1F5F9),
        );
  }

  String get _label => customLabel ?? _config.label;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case StatusStyle.pill:
        return _buildPill();
      case StatusStyle.badge:
        return _buildBadge();
      case StatusStyle.tag:
        return _buildTag();
      case StatusStyle.dot:
        return _buildDot();
    }
  }

  Widget _buildPill() {
    if (isCompact) {
      return _buildCompactPill();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _config.color,
        ),
      ),
    );
  }

  Widget _buildCompactPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _config.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: _config.color,
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _config.color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _config.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w500,
          color: _config.color,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _config.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
