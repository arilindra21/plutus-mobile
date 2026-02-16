import 'package:flutter/material.dart';

/// iOS-style color palette following Apple Human Interface Guidelines
/// Supports both light and dark mode
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS (iOS Blue)
  // ============================================

  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0051D4);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  // Success (Green)
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFF30D158);
  static const Color successDark = Color(0xFF248A3D);

  // Warning (Orange/Yellow)
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFCC00);
  static const Color warningDark = Color(0xFFC93400);

  // Error/Destructive (Red)
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFF6961);
  static const Color errorDark = Color(0xFFD70015);

  // Info (Teal)
  static const Color info = Color(0xFF5AC8FA);
  static const Color infoLight = Color(0xFF70D7FF);
  static const Color infoDark = Color(0xFF0A84FF);

  // ============================================
  // ACCENT COLORS (iOS System Colors)
  // ============================================

  static const Color teal = Color(0xFF30B0C7);
  static const Color indigo = Color(0xFF5856D6);
  static const Color purple = Color(0xFFAF52DE);
  static const Color pink = Color(0xFFFF2D55);
  static const Color orange = Color(0xFFFF9500);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color mint = Color(0xFF00C7BE);
  static const Color cyan = Color(0xFF32ADE6);

  // ============================================
  // NEUTRAL COLORS - LIGHT MODE
  // ============================================

  /// Background colors for light mode
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF2F2F7);
  static const Color backgroundTertiary = Color(0xFFE5E5EA);
  static const Color backgroundGrouped = Color(0xFFF2F2F7);
  static const Color backgroundGroupedSecondary = Color(0xFFFFFFFF);

  /// Surface colors for cards and elevated elements
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF9F9F9);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Separator/Divider colors
  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorOpaque = Color(0xFFE5E5EA);

  /// Fill colors for inputs and controls
  static const Color fillPrimary = Color(0x1F787880);
  static const Color fillSecondary = Color(0x29787880);
  static const Color fillTertiary = Color(0x1F767680);
  static const Color fillQuaternary = Color(0x14747480);

  // ============================================
  // TEXT COLORS - LIGHT MODE
  // ============================================

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textQuaternary = Color(0xFFC7C7CC);
  static const Color textPlaceholder = Color(0xFFC7C7CC);
  static const Color textDisabled = Color(0xFFAEAEB2);

  // ============================================
  // NEUTRAL COLORS - DARK MODE
  // ============================================

  /// Background colors for dark mode
  static const Color backgroundPrimaryDark = Color(0xFF000000);
  static const Color backgroundSecondaryDark = Color(0xFF1C1C1E);
  static const Color backgroundTertiaryDark = Color(0xFF2C2C2E);
  static const Color backgroundGroupedDark = Color(0xFF000000);
  static const Color backgroundGroupedSecondaryDark = Color(0xFF1C1C1E);

  /// Surface colors for dark mode
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceSecondaryDark = Color(0xFF2C2C2E);
  static const Color surfaceElevatedDark = Color(0xFF2C2C2E);

  /// Separator colors for dark mode
  static const Color separatorDark = Color(0xFF38383A);
  static const Color separatorOpaqueDark = Color(0xFF3D3D41);

  /// Fill colors for dark mode
  static const Color fillPrimaryDark = Color(0x5C787880);
  static const Color fillSecondaryDark = Color(0x52787880);
  static const Color fillTertiaryDark = Color(0x3D767680);
  static const Color fillQuaternaryDark = Color(0x2E747480);

  // ============================================
  // TEXT COLORS - DARK MODE
  // ============================================

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFF8E8E93);
  static const Color textQuaternaryDark = Color(0xFF636366);
  static const Color textPlaceholderDark = Color(0xFF636366);
  static const Color textDisabledDark = Color(0xFF48484A);

  // ============================================
  // GRAY SCALE (iOS Standard Grays)
  // ============================================

  static const Color gray = Color(0xFF8E8E93);
  static const Color gray2 = Color(0xFFAEAEB2);
  static const Color gray3 = Color(0xFFC7C7CC);
  static const Color gray4 = Color(0xFFD1D1D6);
  static const Color gray5 = Color(0xFFE5E5EA);
  static const Color gray6 = Color(0xFFF2F2F7);

  // Dark mode grays
  static const Color grayDark = Color(0xFF8E8E93);
  static const Color gray2Dark = Color(0xFF636366);
  static const Color gray3Dark = Color(0xFF48484A);
  static const Color gray4Dark = Color(0xFF3A3A3C);
  static const Color gray5Dark = Color(0xFF2C2C2E);
  static const Color gray6Dark = Color(0xFF1C1C1E);

  // ============================================
  // OVERLAY & TRANSPARENCY
  // ============================================

  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x33000000);
  static const Color overlayDark = Color(0x99000000);
  static const Color scrim = Color(0x52000000);

  // ============================================
  // SPECIFIC UI ELEMENTS
  // ============================================

  static const Color navBarBackground = Color(0xF0F9F9F9);
  static const Color navBarBackgroundDark = Color(0xF01D1D1D);
  static const Color tabBarBackground = Color(0xF0F9F9F9);
  static const Color tabBarBackgroundDark = Color(0xF01D1D1D);

  // ============================================
  // STATUS COLORS (for expense app)
  // ============================================

  static const Color statusApproved = success;
  static const Color statusPending = warning;
  static const Color statusRejected = error;
  static const Color statusDraft = gray;
  static const Color statusProcessing = primary;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get color based on brightness
  static Color adaptive(BuildContext context, Color light, Color dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// Get background color based on theme
  static Color background(BuildContext context) {
    return adaptive(context, backgroundSecondary, backgroundSecondaryDark);
  }

  /// Get surface color based on theme
  static Color surfaceColor(BuildContext context) {
    return adaptive(context, surface, surfaceDark);
  }

  /// Get text primary color based on theme
  static Color text(BuildContext context) {
    return adaptive(context, textPrimary, textPrimaryDark);
  }

  /// Get text secondary color based on theme
  static Color textSecondaryColor(BuildContext context) {
    return adaptive(context, textSecondary, textSecondaryDark);
  }

  /// Get separator color based on theme
  static Color separatorColor(BuildContext context) {
    return adaptive(context, separator, separatorDark);
  }

  /// Get fill color based on theme
  static Color fill(BuildContext context) {
    return adaptive(context, fillSecondary, fillSecondaryDark);
  }
}

/// Extension for easy color opacity
extension ColorOpacity on Color {
  Color get opacity90 => withOpacity(0.9);
  Color get opacity80 => withOpacity(0.8);
  Color get opacity70 => withOpacity(0.7);
  Color get opacity60 => withOpacity(0.6);
  Color get opacity50 => withOpacity(0.5);
  Color get opacity40 => withOpacity(0.4);
  Color get opacity30 => withOpacity(0.3);
  Color get opacity20 => withOpacity(0.2);
  Color get opacity10 => withOpacity(0.1);
  Color get opacity5 => withOpacity(0.05);
}
