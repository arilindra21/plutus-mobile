import 'package:flutter/material.dart';

/// iOS-style spacing system based on 8px grid
/// Following Apple Human Interface Guidelines for consistent spacing
class AppSpacing {
  AppSpacing._();

  // ============================================
  // BASE SPACING SCALE (8px grid)
  // ============================================

  /// 0px - No spacing
  static const double none = 0;

  /// 2px - Extra extra small
  static const double xxs = 2;

  /// 4px - Extra small
  static const double xs = 4;

  /// 8px - Small (base unit)
  static const double sm = 8;

  /// 12px - Medium small
  static const double md = 12;

  /// 16px - Medium (standard spacing)
  static const double lg = 16;

  /// 20px - Medium large
  static const double xl = 20;

  /// 24px - Large
  static const double xl2 = 24;

  /// 32px - Extra large
  static const double xl3 = 32;

  /// 40px - Extra extra large
  static const double xl4 = 40;

  /// 48px - Huge
  static const double xl5 = 48;

  /// 56px - Massive
  static const double xl6 = 56;

  /// 64px - Giant
  static const double xl7 = 64;

  // ============================================
  // SEMANTIC SPACING
  // ============================================

  /// Page horizontal padding (iOS standard: 16px)
  static const double pagePaddingH = 16;

  /// Page vertical padding
  static const double pagePaddingV = 20;

  /// Card internal padding
  static const double cardPadding = 16;

  /// Card internal padding compact
  static const double cardPaddingCompact = 12;

  /// List item vertical spacing
  static const double listItemSpacing = 12;

  /// Section spacing (between cards/sections)
  static const double sectionSpacing = 24;

  /// Grouped table section spacing (iOS)
  static const double groupedSectionSpacing = 35;

  /// Input field internal padding
  static const double inputPadding = 12;

  /// Button internal padding horizontal
  static const double buttonPaddingH = 20;

  /// Button internal padding vertical
  static const double buttonPaddingV = 14;

  /// Icon spacing from text
  static const double iconSpacing = 8;

  /// Navigation bar height
  static const double navBarHeight = 44;

  /// Large title nav bar height
  static const double navBarLargeTitleHeight = 96;

  /// Tab bar height
  static const double tabBarHeight = 49;

  /// Safe area bottom padding
  static const double safeAreaBottom = 34;

  // ============================================
  // EDGE INSETS PRESETS
  // ============================================

  /// No padding
  static const EdgeInsets zero = EdgeInsets.zero;

  /// Horizontal padding only (16px)
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical padding only (16px)
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: lg);

  /// Standard page padding
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
    vertical: pagePaddingV,
  );

  /// Horizontal page padding only
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
  );

  /// Card content padding
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  /// Compact card padding
  static const EdgeInsets cardCompact = EdgeInsets.all(cardPaddingCompact);

  /// List item padding (iOS style)
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Input field padding
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: inputPadding,
    vertical: inputPadding,
  );

  /// Button padding
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: buttonPaddingH,
    vertical: buttonPaddingV,
  );

  /// Button padding compact
  static const EdgeInsets buttonCompact = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  /// Small padding (8px all sides)
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// Medium padding (12px all sides)
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// Large padding (16px all sides)
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// XL padding (24px all sides)
  static const EdgeInsets allXl = EdgeInsets.all(xl2);

  /// XL2 padding (24px all sides)
  static const EdgeInsets allXl2 = EdgeInsets.all(xl2);

  /// Card padding preset
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);

  // ============================================
  // SIZED BOX HELPERS
  // ============================================

  /// Vertical spacers (SizedBox)
  static const Widget vXxs = SizedBox(height: xxs);
  static const Widget vXs = SizedBox(height: xs);
  static const Widget vSm = SizedBox(height: sm);
  static const Widget vMd = SizedBox(height: md);
  static const Widget vLg = SizedBox(height: lg);
  static const Widget vXl = SizedBox(height: xl);
  static const Widget vXl2 = SizedBox(height: xl2);
  static const Widget vXl3 = SizedBox(height: xl3);
  static const Widget vXl4 = SizedBox(height: xl4);

  /// Horizontal spacers (SizedBox)
  static const Widget hXxs = SizedBox(width: xxs);
  static const Widget hXs = SizedBox(width: xs);
  static const Widget hSm = SizedBox(width: sm);
  static const Widget hMd = SizedBox(width: md);
  static const Widget hLg = SizedBox(width: lg);
  static const Widget hXl = SizedBox(width: xl);
  static const Widget hXl2 = SizedBox(width: xl2);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create symmetric EdgeInsets
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Create EdgeInsets from individual values
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  /// Create uniform EdgeInsets
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Create a vertical SizedBox
  static Widget vertical(double height) => SizedBox(height: height);

  /// Create a horizontal SizedBox
  static Widget horizontal(double width) => SizedBox(width: width);

  /// Create a square SizedBox
  static Widget square(double size) => SizedBox(width: size, height: size);
}

/// Extension for easy margin/padding creation
extension SpacingExtension on num {
  /// Create uniform EdgeInsets
  EdgeInsets get all => EdgeInsets.all(toDouble());

  /// Create horizontal EdgeInsets
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: toDouble());

  /// Create vertical EdgeInsets
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: toDouble());

  /// Create a vertical SizedBox
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Create a horizontal SizedBox
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
