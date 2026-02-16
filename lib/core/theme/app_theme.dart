import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_radius.dart';

/// Unified iOS-style theme for the app
/// Combines all design tokens into cohesive ThemeData
class AppTheme {
  AppTheme._();

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTextStyles.fontFamily,

        // Colors
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundSecondary,
        canvasColor: AppColors.backgroundPrimary,
        cardColor: AppColors.surface,
        dividerColor: AppColors.separator,
        hintColor: AppColors.textPlaceholder,
        focusColor: AppColors.primary.withOpacity(0.12),
        hoverColor: AppColors.primary.withOpacity(0.08),
        splashColor: AppColors.primary.withOpacity(0.12),
        highlightColor: AppColors.primary.withOpacity(0.08),

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.gray,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: AppColors.backgroundSecondary,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 24,
          ),
        ),

        // Bottom Navigation Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navBarBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: AppSpacing.button,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            textStyle: AppTextStyles.buttonLarge,
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: AppSpacing.button,
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            textStyle: AppTextStyles.buttonLarge,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: AppSpacing.buttonCompact,
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fillSecondary,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textPlaceholder,
          ),
          labelStyle: AppTextStyles.label,
          errorStyle: AppTextStyles.caption1.copyWith(
            color: AppColors.error,
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.fillSecondary,
          selectedColor: AppColors.primary.withOpacity(0.12),
          labelStyle: AppTextStyles.caption1,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: const StadiumBorder(),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: AppColors.separator,
          thickness: 0.5,
          space: 0,
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding: AppSpacing.listItem,
          tileColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
          titleTextStyle: AppTextStyles.body,
          subtitleTextStyle: AppTextStyles.footnote,
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Bottom Sheet Theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          modalBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          elevation: 0,
        ),

        // Dialog Theme
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.modalRadius,
          ),
          titleTextStyle: AppTextStyles.headline,
          contentTextStyle: AppTextStyles.body,
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.gray6Dark,
          contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.allLg,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.fillSecondary,
          circularTrackColor: AppColors.fillSecondary,
        ),

        // Switch Theme
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.success;
            }
            return AppColors.fillSecondary;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),

        // Checkbox Theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Radio Theme
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textTertiary;
          }),
        ),

        // Cupertino Override Theme
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundSecondary,
          barBackgroundColor: AppColors.navBarBackground,
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: AppTextStyles.largeTitle,
          displayMedium: AppTextStyles.title1,
          displaySmall: AppTextStyles.title2,
          headlineLarge: AppTextStyles.title1,
          headlineMedium: AppTextStyles.title2,
          headlineSmall: AppTextStyles.title3,
          titleLarge: AppTextStyles.headline,
          titleMedium: AppTextStyles.subheadlineEmphasized,
          titleSmall: AppTextStyles.subheadline,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.callout,
          bodySmall: AppTextStyles.footnote,
          labelLarge: AppTextStyles.buttonLarge,
          labelMedium: AppTextStyles.buttonMedium,
          labelSmall: AppTextStyles.caption1,
        ),
      );

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTextStyles.fontFamily,

        // Colors
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundSecondaryDark,
        canvasColor: AppColors.backgroundPrimaryDark,
        cardColor: AppColors.surfaceDark,
        dividerColor: AppColors.separatorDark,
        hintColor: AppColors.textPlaceholderDark,
        focusColor: AppColors.primary.withOpacity(0.24),
        hoverColor: AppColors.primary.withOpacity(0.12),
        splashColor: AppColors.primary.withOpacity(0.24),
        highlightColor: AppColors.primary.withOpacity(0.12),

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.grayDark,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
        ),

        // AppBar Theme (Dark)
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: AppColors.backgroundSecondaryDark,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.textPrimaryDark,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 24,
          ),
        ),

        // Bottom Navigation Theme (Dark)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navBarBackgroundDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Card Theme (Dark)
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
        ),

        // Input Decoration Theme (Dark)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fillSecondaryDark,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textPlaceholderDark,
          ),
        ),

        // Bottom Sheet Theme (Dark)
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceSecondaryDark,
          modalBackgroundColor: AppColors.surfaceSecondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
        ),

        // Dialog Theme (Dark)
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceSecondaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.modalRadius,
          ),
        ),

        // Text Theme (Dark)
        textTheme: TextTheme(
          displayLarge: AppTextStyles.largeTitle.dark,
          displayMedium: AppTextStyles.title1.dark,
          displaySmall: AppTextStyles.title2.dark,
          headlineLarge: AppTextStyles.title1.dark,
          headlineMedium: AppTextStyles.title2.dark,
          headlineSmall: AppTextStyles.title3.dark,
          titleLarge: AppTextStyles.headline.dark,
          titleMedium: AppTextStyles.subheadlineEmphasized.dark,
          titleSmall: AppTextStyles.subheadline.dark,
          bodyLarge: AppTextStyles.body.dark,
          bodyMedium: AppTextStyles.callout.dark,
          bodySmall: AppTextStyles.footnote.dark,
          labelLarge: AppTextStyles.buttonLarge.dark,
          labelMedium: AppTextStyles.buttonMedium.dark,
          labelSmall: AppTextStyles.caption1.dark,
        ),

        // Cupertino Override Theme (Dark)
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundSecondaryDark,
          barBackgroundColor: AppColors.navBarBackgroundDark,
        ),
      );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get theme based on brightness
  static ThemeData of(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
