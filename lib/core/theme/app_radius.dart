import 'package:flutter/material.dart';

/// iOS-style border radius system
/// Consistent corners following Apple Human Interface Guidelines
class AppRadius {
  AppRadius._();

  // ============================================
  // BASE RADIUS VALUES
  // ============================================

  /// 0px - No radius (sharp corners)
  static const double none = 0;

  /// 4px - Extra small radius
  static const double xs = 4;

  /// 6px - Small radius
  static const double sm = 6;

  /// 8px - Medium small radius (inputs, small buttons)
  static const double md = 8;

  /// 10px - Medium radius (buttons, tags)
  static const double lg = 10;

  /// 12px - Large radius (cards - iOS standard)
  static const double xl = 12;

  /// 14px - Extra large radius (bottom sheets top)
  static const double xl2 = 14;

  /// 16px - XXL radius (modals, large cards)
  static const double xl3 = 16;

  /// 20px - XXXL radius (large modals)
  static const double xl4 = 20;

  /// 24px - Huge radius
  static const double xl5 = 24;

  /// 9999px - Full/circular radius (pills, circles)
  static const double full = 9999;

  // ============================================
  // SEMANTIC RADIUS VALUES
  // ============================================

  /// Card radius (iOS standard: 12px)
  static const double card = 12;

  /// Card radius large (16px)
  static const double cardLarge = 16;

  /// Button radius (10px)
  static const double button = 10;

  /// Button radius small (8px)
  static const double buttonSmall = 8;

  /// Input field radius (10px)
  static const double input = 10;

  /// Chip/Tag radius (pill shape)
  static const double chip = full;

  /// Badge radius
  static const double badge = 6;

  /// Bottom sheet radius (14px top corners)
  static const double bottomSheet = 14;

  /// Modal/Dialog radius (14px)
  static const double modal = 14;

  /// Alert radius
  static const double alert = 14;

  /// Toast radius
  static const double toast = 10;

  /// Avatar radius (full circle)
  static const double avatar = full;

  /// Thumbnail radius
  static const double thumbnail = 8;

  /// Progress bar radius
  static const double progressBar = full;

  /// Slider track radius
  static const double slider = full;

  // ============================================
  // BORDER RADIUS PRESETS
  // ============================================

  /// No radius
  static const BorderRadius zero = BorderRadius.zero;

  /// Extra small radius all corners
  static const BorderRadius allXs = BorderRadius.all(Radius.circular(xs));

  /// Small radius all corners
  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));

  /// Medium radius all corners (buttons, inputs)
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));

  /// Large radius all corners (cards)
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));

  /// XL radius all corners
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));

  /// XXL radius all corners
  static const BorderRadius allXl2 = BorderRadius.all(Radius.circular(xl2));

  /// XXXL radius all corners
  static const BorderRadius allXl3 = BorderRadius.all(Radius.circular(xl3));

  /// Full/circular radius
  static const BorderRadius allFull = BorderRadius.all(Radius.circular(full));

  /// Card radius preset
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));

  /// Card large radius preset
  static const BorderRadius cardLargeRadius = BorderRadius.all(Radius.circular(cardLarge));

  /// Button radius preset
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));

  /// Input radius preset
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));

  /// Bottom sheet radius (top corners only)
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );

  /// Modal radius preset
  static const BorderRadius modalRadius = BorderRadius.all(Radius.circular(modal));

  // ============================================
  // DIRECTIONAL RADIUS PRESETS
  // ============================================

  /// Top corners only
  static BorderRadius topOnly(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );

  /// Bottom corners only
  static BorderRadius bottomOnly(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  /// Left corners only
  static BorderRadius leftOnly(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
      );

  /// Right corners only
  static BorderRadius rightOnly(double radius) => BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create uniform BorderRadius
  static BorderRadius circular(double radius) =>
      BorderRadius.all(Radius.circular(radius));

  /// Create BorderRadius with custom corners
  static BorderRadius custom({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );

  /// Create Radius value
  static Radius radius(double value) => Radius.circular(value);
}

/// Extension for easy BorderRadius creation
extension RadiusExtension on num {
  /// Create circular BorderRadius
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());

  /// Create Radius
  Radius get radius => Radius.circular(toDouble());
}
