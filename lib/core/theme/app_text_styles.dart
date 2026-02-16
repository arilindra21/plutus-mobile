import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// iOS-style typography system using Inter font (similar to SF Pro)
/// Follows Apple Human Interface Guidelines typography scale
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // FONT FAMILY
  // ============================================

  /// Primary font family - Inter (closest to SF Pro Display)
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  /// Alternative: Plus Jakarta Sans for a more modern feel
  static String get fontFamilyAlt => GoogleFonts.plusJakartaSans().fontFamily!;

  // ============================================
  // FONT WEIGHTS
  // ============================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============================================
  // LARGE TITLE (iOS Navigation Large Title)
  // ============================================

  /// Large Title - 34pt Bold
  /// Used for main screen titles with large title display
  static TextStyle get largeTitle => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: bold,
        letterSpacing: 0.37,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get largeTitleDark => largeTitle.copyWith(
        color: AppColors.textPrimaryDark,
      );

  // ============================================
  // TITLE STYLES (iOS Navigation)
  // ============================================

  /// Title 1 - 28pt Bold
  static TextStyle get title1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: bold,
        letterSpacing: 0.36,
        height: 1.21,
        color: AppColors.textPrimary,
      );

  /// Title 2 - 22pt Bold
  static TextStyle get title2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: bold,
        letterSpacing: 0.35,
        height: 1.27,
        color: AppColors.textPrimary,
      );

  /// Title 3 - 20pt Semibold
  static TextStyle get title3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: semibold,
        letterSpacing: 0.38,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  // ============================================
  // HEADLINE & SUBHEADLINE
  // ============================================

  /// Headline - 17pt Semibold
  /// Used for emphasized body text or list headers
  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: semibold,
        letterSpacing: -0.41,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Subheadline - 15pt Regular
  /// Used for secondary information
  static TextStyle get subheadline => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: regular,
        letterSpacing: -0.24,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  /// Subheadline Emphasized - 15pt Semibold
  static TextStyle get subheadlineEmphasized => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: semibold,
        letterSpacing: -0.24,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ============================================
  // BODY STYLES
  // ============================================

  /// Body - 17pt Regular
  /// Primary reading size
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: regular,
        letterSpacing: -0.41,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Body Emphasized - 17pt Semibold
  static TextStyle get bodyEmphasized => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: semibold,
        letterSpacing: -0.41,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Body Large - 19pt Regular
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 19,
        fontWeight: regular,
        letterSpacing: -0.43,
        height: 1.26,
        color: AppColors.textPrimary,
      );

  // ============================================
  // CALLOUT
  // ============================================

  /// Callout - 16pt Regular
  static TextStyle get callout => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: -0.32,
        height: 1.31,
        color: AppColors.textPrimary,
      );

  /// Callout Emphasized - 16pt Semibold
  static TextStyle get calloutEmphasized => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: semibold,
        letterSpacing: -0.32,
        height: 1.31,
        color: AppColors.textPrimary,
      );

  // ============================================
  // FOOTNOTE
  // ============================================

  /// Footnote - 13pt Regular
  /// Used for supplementary information
  static TextStyle get footnote => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: regular,
        letterSpacing: -0.08,
        height: 1.38,
        color: AppColors.textSecondary,
      );

  /// Footnote Emphasized - 13pt Semibold
  static TextStyle get footnoteEmphasized => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: semibold,
        letterSpacing: -0.08,
        height: 1.38,
        color: AppColors.textPrimary,
      );

  // ============================================
  // CAPTION
  // ============================================

  /// Caption 1 - 12pt Regular
  /// Used for timestamps, labels
  static TextStyle get caption1 => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textTertiary,
      );

  /// Caption 1 Emphasized - 12pt Medium
  static TextStyle get caption1Emphasized => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  /// Caption 2 - 11pt Regular
  static TextStyle get caption2 => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: regular,
        letterSpacing: 0.07,
        height: 1.27,
        color: AppColors.textTertiary,
      );

  /// Caption 2 Emphasized - 11pt Semibold
  static TextStyle get caption2Emphasized => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: semibold,
        letterSpacing: 0.07,
        height: 1.27,
        color: AppColors.textSecondary,
      );

  // ============================================
  // BUTTON STYLES
  // ============================================

  /// Button Large - 17pt Semibold
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: semibold,
        letterSpacing: -0.41,
        height: 1.29,
      );

  /// Button Medium - 15pt Semibold
  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: semibold,
        letterSpacing: -0.24,
        height: 1.33,
      );

  /// Button Small - 13pt Semibold
  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: semibold,
        letterSpacing: -0.08,
        height: 1.38,
      );

  // ============================================
  // LABEL STYLES
  // ============================================

  /// Label - 14pt Medium
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: -0.15,
        height: 1.29,
        color: AppColors.textSecondary,
      );

  /// Label Small - 12pt Medium
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textTertiary,
      );

  // ============================================
  // NUMERIC / TABULAR STYLES
  // ============================================

  /// Numeric Large - 34pt Bold (for displaying amounts)
  static TextStyle get numericLarge => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: bold,
        letterSpacing: 0.37,
        height: 1.2,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Numeric Medium - 24pt Semibold
  static TextStyle get numericMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: semibold,
        letterSpacing: 0.35,
        height: 1.25,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Numeric Regular - 17pt Medium
  static TextStyle get numericRegular => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: medium,
        letterSpacing: -0.41,
        height: 1.29,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style adapted to theme brightness
  static TextStyle adaptive(BuildContext context, TextStyle style) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return style.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );
  }
}

/// Extension methods for TextStyle modifications
extension TextStyleExtensions on TextStyle {
  // Color modifiers
  TextStyle get primary => copyWith(color: AppColors.textPrimary);
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
  TextStyle get tertiary => copyWith(color: AppColors.textTertiary);
  TextStyle get white => copyWith(color: Colors.white);
  TextStyle get blue => copyWith(color: AppColors.primary);
  TextStyle get success => copyWith(color: AppColors.success);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get warning => copyWith(color: AppColors.warning);

  // Weight modifiers
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  // Size modifiers
  TextStyle size(double size) => copyWith(fontSize: size);

  // Custom color
  TextStyle withAppColor(Color color) => copyWith(color: color);

  // Dark mode variant
  TextStyle get dark => copyWith(color: AppColors.textPrimaryDark);
}
