import 'package:flutter/material.dart';

/// Fintech Design System
///
/// Modern fintech-style design tokens for expense management app.
/// Navy blue primary, cyan accent, clean and professional.

// =============================================================================
// FINTECH COLORS - Core Color Palette
// =============================================================================

class FintechColors {
  FintechColors._();

  // Primary Brand Colors (Navy Blue)
  static const Color primary = Color(0xFF0A2540);       // Dark Navy
  static const Color primaryLight = Color(0xFF1A3A5C);  // Medium Navy
  static const Color primaryMedium = Color(0xFF2D5478); // Lighter Navy

  // Accent Colors (Cyan/Teal)
  static const Color accent = Color(0xFF00D4AA);        // Vibrant Cyan/Teal
  static const Color accentLight = Color(0xFF5EEAD4);   // Light Cyan
  static const Color accentDark = Color(0xFF00B894);    // Dark Teal

  // Secondary Colors
  static const Color secondary = Color(0xFF6B7C93);     // Slate Gray
  static const Color secondaryLight = Color(0xFF8E9AAF);

  // Category Icon Background Colors (Soft/Pastel)
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categoryBlueBg = Color(0xFFDBEAFE);
  static const Color categoryGreen = Color(0xFF10B981);
  static const Color categoryGreenBg = Color(0xFFD1FAE5);
  static const Color categoryRed = Color(0xFFEF4444);
  static const Color categoryRedBg = Color(0xFFFEE2E2);
  static const Color categoryOrange = Color(0xFFF97316);
  static const Color categoryOrangeBg = Color(0xFFFFEDD5);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryPurpleBg = Color(0xFFEDE9FE);
  static const Color categoryPink = Color(0xFFEC4899);
  static const Color categoryPinkBg = Color(0xFFFCE7F3);
  static const Color categoryYellow = Color(0xFFF59E0B);
  static const Color categoryYellowBg = Color(0xFFFEF3C7);
  static const Color categoryCyan = Color(0xFF06B6D4);
  static const Color categoryCyanBg = Color(0xFFCFFAFE);
  static const Color categoryIndigo = Color(0xFF6366F1);
  static const Color categoryIndigoBg = Color(0xFFE0E7FF);
  static const Color categoryTeal = Color(0xFF14B8A6);
  static const Color categoryTealBg = Color(0xFFCCFBF1);
}

// =============================================================================
// PAPER COLORS - Legacy Compatibility (mapped to Fintech)
// =============================================================================

class PaperColor {
  PaperColor._();

  // Primary Brand Colors (Navy Blue)
  static const Color primary = FintechColors.primary;
  static const Color secondary = FintechColors.secondary;
  static const Color tertiary = Color(0xFFC2CDD5);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color blue = FintechColors.categoryBlue;
  static const Color blueDarken = Color(0xFF2563EB);
  static const Color blueLower = FintechColors.categoryBlueBg;
  static const Color semanticBlue = FintechColors.categoryBlue;

  static const Color green = FintechColors.categoryGreen;
  static const Color greenDarken = Color(0xFF059669);
  static const Color greenLower = FintechColors.categoryGreenBg;
  static const Color semanticGreen = FintechColors.categoryGreen;

  static const Color greenLight = Color(0xFF34D399);
  static const Color greenLightDarken = Color(0xFF10B981);
  static const Color greenLightLower = Color(0xFFD1FAE5);

  static const Color red = FintechColors.categoryRed;
  static const Color redDarken = Color(0xFFDC2626);
  static const Color redLower = FintechColors.categoryRedBg;

  static const Color yellow = FintechColors.categoryYellow;
  static const Color peach = Color(0xFFD06060);
  static const Color orange = FintechColors.categoryOrange;
  static const Color lowerEmphasis = Color(0xFF8695A1);
  static const Color disabled = Color(0xFFD0D9DF);

  // Blue Shades
  static const Color blue50 = FintechColors.categoryBlue;
  static const Color blue40 = Color(0xFF60A5FA);
  static const Color blue30 = Color(0xFF93C5FD);
  static const Color blue20 = Color(0xFFBFDBFE);
  static const Color blue15 = Color(0xFFDBEAFE);
  static const Color blue10 = Color(0xFFEFF6FF);

  // Green Shades
  static const Color green50 = FintechColors.categoryGreen;
  static const Color green40 = Color(0xFF34D399);
  static const Color green30 = Color(0xFF6EE7B7);
  static const Color green20 = Color(0xFFA7F3D0);
  static const Color green10 = Color(0xFFD1FAE5);

  // Dark Grey Shades
  static const Color darkGrey50 = Color(0xFF374151);
  static const Color darkGrey40 = Color(0xFF4B5563);
  static const Color darkGrey30 = Color(0xFF6B7280);
  static const Color darkGrey20 = Color(0xFF9CA3AF);
  static const Color darkGrey10 = Color(0xFFF3F4F6);

  // Dark Blue Shades (Navy)
  static const Color darkBlue50 = FintechColors.primary;
  static const Color darkBlue45 = Color(0xFF1A3A5C);
  static const Color darkBlue40 = Color(0xFF2D5478);
  static const Color darkBlue35 = Color(0xFF4A6D8C);
  static const Color darkBlue30 = Color(0xFF6B8AA6);
  static const Color darkBlue20 = Color(0xFFB0C4D8);
  static const Color darkBlue10 = Color(0xFFE8EEF4);

  // Grey Shades
  static const Color grey50 = Color(0xFF9CA3AF);
  static const Color grey40 = Color(0xFFD1D5DB);
  static const Color grey30 = Color(0xFFE5E7EB);
  static const Color grey20 = Color(0xFFF3F4F6);
  static const Color grey10 = Color(0xFFF9FAFB);

  // Red Shades
  static const Color red50 = FintechColors.categoryRed;
  static const Color red40 = Color(0xFFF87171);
  static const Color red30 = Color(0xFFFCA5A5);
  static const Color red20 = Color(0xFFFECACA);
  static const Color red15 = Color(0xFFFEE2E2);
  static const Color red10 = Color(0xFFFEF2F2);

  // Yellow Shades
  static const Color yellow50 = FintechColors.categoryYellow;
  static const Color yellow40 = Color(0xFFFBBF24);
  static const Color yellow30 = Color(0xFFFCD34D);
  static const Color yellow20 = Color(0xFFFDE68A);
  static const Color yellow10 = Color(0xFFFEF3C7);

  // Orange Shades
  static const Color orange50 = FintechColors.categoryOrange;
  static const Color orange40 = Color(0xFFFB923C);
  static const Color orange30 = Color(0xFFFDBA74);
  static const Color orange20 = Color(0xFFFED7AA);
  static const Color orange10 = Color(0xFFFFEDD5);

  // Dark Red Shades
  static const Color darkRed50 = Color(0xFFDC2626);
  static const Color darkRed40 = Color(0xFFF87171);
  static const Color darkRed30 = Color(0xFFFCA5A5);
  static const Color darkRed20 = Color(0xFFFECACA);
  static const Color darkRed10 = Color(0xFFFEF2F2);

  // Ink Colors (Neutral/Text tones)
  static const Color ink100 = FintechColors.primary;
  static const Color ink80 = Color(0xFF1E3A5F);
  static const Color ink60 = Color(0xFF4A6D8C);
  static const Color ink40 = Color(0xFF8BA3B9);
  static const Color ink20 = Color(0xFFBACBD9);
  static const Color ink10 = Color(0xFFE8EEF4);
  static const Color ink5 = Color(0xFFF5F7FA);
}

// =============================================================================
// PAPER ARTBOARD COLORS - Surface & Layout Colors
// =============================================================================

class PaperArtboardColor {
  PaperArtboardColor._();

  static const Color surfaceDefault = Color(0xFFF8FAFC);  // Very light gray-blue
  static const Color surfaceVariant = Color(0xFFFFFFFF);
  static const Color surfaceDisabled = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color secondary = PaperColor.secondary;
  static const Color blue = PaperColor.blue;
  static const Color green = PaperColor.green;
  static const Color greenLight = PaperColor.greenLight;
  static const Color red = PaperColor.red;
  static const Color yellow = PaperColor.yellow;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF94A3B8);
}

// =============================================================================
// PAPER TEXT COLORS
// =============================================================================

class PaperTextColor {
  PaperTextColor._();

  static const Color primary = Color(0xFF0F172A);      // Very dark blue-gray
  static const Color secondary = Color(0xFF475569);     // Medium gray
  static const Color tertiary = Color(0xFF94A3B8);      // Light gray
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = FintechColors.categoryBlue;
  static const Color green = FintechColors.categoryGreen;
  static const Color greenLight = Color(0xFF34D399);
  static const Color red = FintechColors.categoryRed;
  static const Color yellow = FintechColors.categoryYellow;
  static const Color peach = Color(0xFFD06060);
  static const Color orange = FintechColors.categoryOrange;
}

// =============================================================================
// PAPER ICON COLORS
// =============================================================================

class PaperIconColor {
  PaperIconColor._();

  static const Color primary = FintechColors.primary;
  static const Color lowerEmphasis = Color(0xFF94A3B8);
  static const Color disabled = Color(0xFFCBD5E1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = FintechColors.categoryBlue;
  static const Color green = FintechColors.categoryGreen;
  static const Color greenLight = Color(0xFF34D399);
  static const Color red = FintechColors.categoryRed;
  static const Color yellow = FintechColors.categoryYellow;
  static const Color peach = Color(0xFFD06060);
  static const Color orange = FintechColors.categoryOrange;
}

// =============================================================================
// APP COLORS - Application Color Palette
// =============================================================================

class AppColors {
  AppColors._();

  // Primary Brand Colors (Navy Blue Fintech Style)
  static const Color primary = FintechColors.primary;
  static const Color primaryLight = FintechColors.primaryLight;
  static const Color primaryDark = Color(0xFF061B2E);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  // Accent Colors (Cyan/Teal)
  static const Color accent = FintechColors.accent;
  static const Color accentLight = FintechColors.accentLight;

  // Danger / Error Colors
  static const Color danger = FintechColors.categoryRed;
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color dangerContrast = Color(0xFFFFFFFF);

  // Success Colors
  static const Color success = FintechColors.categoryGreen;
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);
  static const Color successContrast = Color(0xFFFFFFFF);

  // Warning Colors
  static const Color warning = FintechColors.categoryYellow;
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningContrast = FintechColors.primary;

  // Info Colors
  static const Color info = FintechColors.categoryBlue;
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoContrast = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = FintechColors.categoryBlue;

  // Background Colors
  static const Color bgDefault = Color(0xFFFFFFFF);
  static const Color bgPaper = Color(0xFFF8FAFC);
  static const Color bgSubtle = Color(0xFFF1F5F9);
  static const Color bgDark = FintechColors.primary;
  static const Color bgOverlay = Color(0x80000000);

  // Border Colors
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = FintechColors.categoryBlue;
  static const Color borderError = FintechColors.categoryRed;

  // Status Colors (for expense app)
  static const Color statusApproved = FintechColors.categoryGreen;
  static const Color statusPending = FintechColors.categoryYellow;
  static const Color statusRejected = FintechColors.categoryRed;
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusProcessing = FintechColors.categoryBlue;
  static const Color statusReturned = FintechColors.categoryOrange;

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);

  // Border
  static const Color border = Color(0xFFE2E8F0);

  // Chart Colors
  static const Color chartBlue = FintechColors.categoryBlue;
  static const Color chartGreen = FintechColors.categoryGreen;
  static const Color chartRed = FintechColors.categoryRed;
  static const Color chartOrange = FintechColors.categoryOrange;
  static const Color chartPurple = FintechColors.categoryPurple;
  static const Color chartTeal = FintechColors.categoryCyan;
  static const Color chartPink = FintechColors.categoryPink;
  static const Color chartIndigo = FintechColors.categoryIndigo;

  // Gradient Colors
  static const Color gradientStart = FintechColors.primary;
  static const Color gradientMiddle = FintechColors.primaryLight;
  static const Color gradientEnd = Color(0xFF2D5478);  // FintechColors.primaryMedium

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2540), Color(0xFF1A3A5C), Color(0xFF2D5478)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2540), Color(0xFF1A3A5C), Color(0xFF2D5478)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FintechColors.accent, FintechColors.accentLight],
  );

  // Legacy compatibility
  static const LinearGradient walletGradient = cardGradient;
}

// =============================================================================
// PAPER TYPOGRAPHY - DS 2.0
// =============================================================================

/// Paper Typography (DS 2.0)
class PaperText {
  PaperText._();

  // HEADLINE - Largest text on screen
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // HEADING - Section titles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headingRegular = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headingXSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // BODY - Standard copy text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyXSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // PARAGRAPH - Long-form text
  static const TextStyle paragraphLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle paragraphRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle paragraphSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle paragraphXSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // CAPTION
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // AMOUNT - For displaying monetary values
  static const TextStyle amountLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const TextStyle amountRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}

/// Paper Text Style Extensions
extension PaperTextExt on TextStyle {
  TextStyle get primary => copyWith(color: PaperTextColor.primary);
  TextStyle get secondary => copyWith(color: PaperTextColor.secondary);
  TextStyle get tertiary => copyWith(color: PaperTextColor.tertiary);
  TextStyle get white => copyWith(color: PaperTextColor.white);
  TextStyle get blue => copyWith(color: PaperTextColor.blue);
  TextStyle get green => copyWith(color: PaperTextColor.green);
  TextStyle get red => copyWith(color: PaperTextColor.red);
  TextStyle get yellow => copyWith(color: PaperTextColor.yellow);
  TextStyle get peach => copyWith(color: PaperTextColor.peach);
  TextStyle get orange => copyWith(color: PaperTextColor.orange);
}

// =============================================================================
// APP TYPOGRAPHY - Legacy compatibility layer
// =============================================================================

class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Font Sizes (matching Paper)
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 28.0;
  static const double fontSize4xl = 32.0;

  // Font Weights
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Line Heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Text Styles
  static TextStyle get headingLarge => PaperText.headlineLarge.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => PaperText.headlineMedium.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => PaperText.headlineSmall.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => PaperText.bodyLarge.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => PaperText.bodyRegular.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => PaperText.bodySmall.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => PaperText.caption.copyWith(
        fontFamily: fontFamily,
        color: AppColors.textMuted,
      );

  static TextStyle get button => PaperText.headingRegular.copyWith(
        fontFamily: fontFamily,
      );

  static TextStyle get label => PaperText.bodySmall.copyWith(
        fontFamily: fontFamily,
        fontWeight: fontWeightMedium,
        color: AppColors.textSecondary,
      );
}

// =============================================================================
// PAPER SPACING - DS 2.0
// =============================================================================

class PaperSpacing {
  PaperSpacing._();

  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 28.0;
  static const double xl4 = 32.0;
  static const double xl5 = 36.0;
  static const double xl6 = 40.0;
}

// =============================================================================
// APP SPACING - Legacy compatibility layer
// =============================================================================

class AppSpacing {
  AppSpacing._();

  static const double none = 0.0;
  static const double xs = PaperSpacing.xs;
  static const double sm = PaperSpacing.sm;
  static const double md = PaperSpacing.md;
  static const double lg = PaperSpacing.lg;
  static const double xl = PaperSpacing.xl;
  static const double xxl = PaperSpacing.xl2;
  static const double xxxl = PaperSpacing.xl4;
  static const double xxxxl = PaperSpacing.xl6;
  static const double xxxxxl = 48.0;
  static const double xxxxxxl = 64.0;
}

// =============================================================================
// BORDER RADIUS
// =============================================================================

class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double xxxl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get borderRadiusXs => BorderRadius.circular(xs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(full);
}

// =============================================================================
// DURATIONS - Animation Timings
// =============================================================================

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 700);
}

// =============================================================================
// SHADOWS - Fintech Style (Subtle and Clean)
// =============================================================================

class AppShadows {
  AppShadows._();

  static const Color _shadowColor = Color(0xFF0A2540);

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get xs => [
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: _shadowColor.withValues(alpha: 0.04),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 3,
          color: _shadowColor.withValues(alpha: 0.06),
        ),
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: _shadowColor.withValues(alpha: 0.04),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -1,
          color: _shadowColor.withValues(alpha: 0.08),
        ),
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -1,
          color: _shadowColor.withValues(alpha: 0.04),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          offset: const Offset(0, 10),
          blurRadius: 15,
          spreadRadius: -3,
          color: _shadowColor.withValues(alpha: 0.1),
        ),
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -2,
          color: _shadowColor.withValues(alpha: 0.05),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          offset: const Offset(0, 20),
          blurRadius: 25,
          spreadRadius: -5,
          color: _shadowColor.withValues(alpha: 0.12),
        ),
        BoxShadow(
          offset: const Offset(0, 10),
          blurRadius: 10,
          spreadRadius: -5,
          color: _shadowColor.withValues(alpha: 0.04),
        ),
      ];

  // Card shadow - very subtle
  static List<BoxShadow> get card => [
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 3,
          color: _shadowColor.withValues(alpha: 0.05),
        ),
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: _shadowColor.withValues(alpha: 0.03),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: _shadowColor.withValues(alpha: 0.08),
        ),
      ];

  // Gradient card shadow - for accent cards
  static List<BoxShadow> get gradientCard => [
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: -4,
          color: _shadowColor.withValues(alpha: 0.15),
        ),
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: -2,
          color: _shadowColor.withValues(alpha: 0.08),
        ),
      ];

  static List<BoxShadow> get modal => [
        BoxShadow(
          offset: const Offset(0, 25),
          blurRadius: 50,
          spreadRadius: -12,
          color: _shadowColor.withValues(alpha: 0.25),
        ),
      ];

  static List<BoxShadow> get navTop => [
        BoxShadow(
          offset: const Offset(0, -1),
          blurRadius: 3,
          color: _shadowColor.withValues(alpha: 0.05),
        ),
      ];

  static List<BoxShadow> get navBottom => [
        BoxShadow(
          offset: const Offset(0, -4),
          blurRadius: 12,
          color: _shadowColor.withValues(alpha: 0.06),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: _shadowColor.withValues(alpha: 0.05),
        ),
      ];

  static List<BoxShadow> get fab => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: FintechColors.primary.withValues(alpha: 0.25),
        ),
      ];
}

// =============================================================================
// TRANSITIONS
// =============================================================================

class AppTransitions {
  AppTransitions._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}

// =============================================================================
// Z-INDEX (for Stack ordering)
// =============================================================================

class AppZIndex {
  AppZIndex._();

  static const int base = 0;
  static const int dropdown = 100;
  static const int sticky = 200;
  static const int fixed = 300;
  static const int overlay = 400;
  static const int modal = 500;
  static const int popover = 600;
  static const int tooltip = 700;
  static const int toast = 800;
}

// =============================================================================
// CATEGORY ICON HELPER
// =============================================================================

class CategoryIconColors {
  CategoryIconColors._();

  static const Map<String, Map<String, Color>> colors = {
    'food': {'icon': FintechColors.categoryOrange, 'bg': FintechColors.categoryOrangeBg},
    'transport': {'icon': FintechColors.categoryBlue, 'bg': FintechColors.categoryBlueBg},
    'shopping': {'icon': FintechColors.categoryPink, 'bg': FintechColors.categoryPinkBg},
    'entertainment': {'icon': FintechColors.categoryPurple, 'bg': FintechColors.categoryPurpleBg},
    'bills': {'icon': FintechColors.categoryRed, 'bg': FintechColors.categoryRedBg},
    'health': {'icon': FintechColors.categoryGreen, 'bg': FintechColors.categoryGreenBg},
    'travel': {'icon': FintechColors.categoryCyan, 'bg': FintechColors.categoryCyanBg},
    'education': {'icon': FintechColors.categoryIndigo, 'bg': FintechColors.categoryIndigoBg},
    'office': {'icon': FintechColors.categoryTeal, 'bg': FintechColors.categoryTealBg},
    'other': {'icon': FintechColors.secondary, 'bg': Color(0xFFF1F5F9)},
  };

  static Color getIconColor(String? category) {
    final key = category?.toLowerCase() ?? 'other';
    return colors[key]?['icon'] ?? colors['other']!['icon']!;
  }

  static Color getBgColor(String? category) {
    final key = category?.toLowerCase() ?? 'other';
    return colors[key]?['bg'] ?? colors['other']!['bg']!;
  }
}
