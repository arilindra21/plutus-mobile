import 'package:flutter/material.dart';
import 'app_colors.dart';

/// iOS-style shadow system
/// Subtle, diffuse shadows following Apple Human Interface Guidelines
class AppShadows {
  AppShadows._();

  // ============================================
  // SHADOW COLORS
  // ============================================

  static const Color _shadowColor = Color(0x0A000000);
  static const Color _shadowColorMedium = Color(0x14000000);
  static const Color _shadowColorDark = Color(0x1F000000);
  static const Color _shadowColorLight = Color(0x05000000);

  // ============================================
  // BASIC SHADOWS
  // ============================================

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra small shadow - subtle hint
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Small shadow - cards at rest
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow - elevated cards
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Large shadow - floating elements
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Extra large shadow - modals, dropdowns
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// XXL shadow - full-screen modals
  static const List<BoxShadow> xl2 = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 40,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // SEMANTIC SHADOWS
  // ============================================

  /// Card shadow - iOS style subtle shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Card hover shadow - slightly elevated
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Card pressed shadow - reduced elevation
  static const List<BoxShadow> cardPressed = [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Navigation bar shadow
  static const List<BoxShadow> navBar = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Tab bar shadow (top shadow)
  static const List<BoxShadow> tabBar = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  /// Bottom sheet shadow
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 40,
      offset: Offset(0, -12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  /// Modal/Dialog shadow
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 60,
      offset: Offset(0, 20),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Dropdown shadow
  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Button shadow (pressed state)
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// FAB (Floating Action Button) shadow
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Input focus shadow (blue glow)
  static List<BoxShadow> inputFocus = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 8,
      offset: Offset.zero,
      spreadRadius: 0,
    ),
  ];

  /// Error input shadow (red glow)
  static List<BoxShadow> inputError = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.2),
      blurRadius: 8,
      offset: Offset.zero,
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // COLORED SHADOWS
  // ============================================

  /// Primary color shadow
  static List<BoxShadow> primaryShadow({double opacity = 0.3}) => [
        BoxShadow(
          color: AppColors.primary.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Success color shadow
  static List<BoxShadow> successShadow({double opacity = 0.3}) => [
        BoxShadow(
          color: AppColors.success.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// Error color shadow
  static List<BoxShadow> errorShadow({double opacity = 0.3}) => [
        BoxShadow(
          color: AppColors.error.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // DARK MODE SHADOWS
  // ============================================

  /// Card shadow for dark mode (more subtle)
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Modal shadow for dark mode
  static const List<BoxShadow> modalDark = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 60,
      offset: Offset(0, 20),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get shadow based on elevation level (0-5)
  static List<BoxShadow> elevation(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return xs;
      case 2:
        return sm;
      case 3:
        return md;
      case 4:
        return lg;
      case 5:
        return xl;
      default:
        return xl2;
    }
  }

  /// Create custom shadow
  static List<BoxShadow> custom({
    Color color = const Color(0x14000000),
    double blurRadius = 8,
    Offset offset = const Offset(0, 2),
    double spreadRadius = 0,
  }) =>
      [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          offset: offset,
          spreadRadius: spreadRadius,
        ),
      ];

  /// Adaptive shadow (light/dark mode)
  static List<BoxShadow> adaptive(BuildContext context, {int elevation = 2}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return cardDark;
    }
    return AppShadows.elevation(elevation);
  }
}
