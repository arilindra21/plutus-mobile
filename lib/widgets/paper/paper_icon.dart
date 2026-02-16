import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_tokens.dart';

/// Paper Icon Component
///
/// Displays SVG icons from the assets/icons folder.
/// Ported from Paper Multiverse.
class PaperIcon extends StatelessWidget {
  const PaperIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.color,
    this.width,
    this.height,
  });

  /// Asset name without path (e.g., 'ic_logo' or 'ic_logo.svg')
  final String asset;

  /// Size of the icon (used for both width and height if not specified)
  final double size;

  /// Color to apply to the SVG
  final Color? color;

  /// Custom width (overrides size)
  final double? width;

  /// Custom height (overrides size)
  final double? height;

  String get _assetPath {
    final name = asset.endsWith('.svg') ? asset : '$asset.svg';
    return 'assets/icons/$name';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: width ?? size,
      height: height ?? size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Paper Icon with predefined icons
class PaperIcons {
  PaperIcons._();

  // Common icons
  static const String logo = 'ic_logo';
  static const String logoCircle = 'ic_logo_circle';
  static const String search = 'ic_search';
  static const String settings = 'ic_settings';
  static const String setting = 'ic_setting';
  static const String edit = 'ic_edit';
  static const String delete = 'ic_delete';
  static const String trash = 'ic_trash';
  static const String refresh = 'ic_refresh';
  static const String helper = 'ic_helper';
  static const String warning = 'ic_warning_outline';

  // Finance icons
  static const String bank = 'ic_bank';
  static const String payment = 'ic_payment';
  static const String rupiah = 'ic_rupiah';
  static const String promo = 'ic_promo';

  // User icons
  static const String contact = 'ic_contact';
  static const String userPlus = 'ic_user_plus';
  static const String userSquare = 'ic_user_square';
  static const String partner = 'ic_partner';

  // Document icons
  static const String document = 'ic_document';
  static const String folder = 'ic_folder';
  static const String tag = 'ic_tag';

  // Other icons
  static const String globe = 'ic_globe';
  static const String cursor = 'ic_cursor';
  static const String alarmClock = 'ic_alarm_clock';
  static const String dotsHorizontal = 'ic_dots_horizontal';
  static const String connection = 'connection-up-down-circle';
  static const String zoomPreview = 'ic_zoom_preview';
}

/// Paper Image Component
///
/// Displays images from the assets/images folder.
class PaperImage extends StatelessWidget {
  const PaperImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// Asset path relative to assets/images/
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  String get _assetPath => 'assets/images/$asset';

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        _assetPath,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// Paper Empty State Widget
///
/// Displays an empty state illustration with message.
class PaperEmptyStateImage extends StatelessWidget {
  const PaperEmptyStateImage({
    super.key,
    required this.imageName,
    required this.title,
    this.subtitle,
    this.action,
    this.imageSize = 200,
  });

  final String imageName;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PaperSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PaperImage(
              asset: 'empty-state/$imageName',
              width: imageSize,
              height: imageSize,
            ),
            const SizedBox(height: PaperSpacing.xl),
            Text(
              title,
              style: PaperText.headingLarge.primary,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: PaperSpacing.sm),
              Text(
                subtitle!,
                style: PaperText.bodyRegular.secondary,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: PaperSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Circular icon container with background
class PaperIconCircle extends StatelessWidget {
  const PaperIconCircle({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  final String icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? PaperColor.blue10,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: PaperIcon(
          asset: icon,
          size: iconSize,
          color: iconColor ?? PaperColor.blue,
        ),
      ),
    );
  }
}

/// Category icon with emoji fallback
class PaperCategoryIcon extends StatelessWidget {
  const PaperCategoryIcon({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 24,
    this.backgroundColor,
  });

  final String icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;

  bool get _isEmoji {
    // Check if it's an emoji (simple check for common emoji ranges)
    if (icon.isEmpty) return false;
    final codeUnit = icon.codeUnitAt(0);
    return codeUnit > 0x1000 || icon.length <= 2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? PaperColor.blue10,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: _isEmoji
            ? Text(icon, style: TextStyle(fontSize: iconSize))
            : PaperIcon(
                asset: icon,
                size: iconSize,
                color: PaperColor.blue,
              ),
      ),
    );
  }
}
