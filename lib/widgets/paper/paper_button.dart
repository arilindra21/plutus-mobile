import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Paper Button Color variants
enum PaperButtonColor {
  blue,
  blueSecondary,
  blueGhost,
  green,
  greenSecondary,
  greenGhost,
  red,
  redSecondary,
  redGhost,
  white,
  whiteGhost,
  whiteSecondary,
  greySecondary,
  greyGhost,
}

/// Paper Button Width presets
enum PaperButtonWidth { large, medium, small, smaller, tiny, custom }

/// Paper Button State
enum PaperButtonState { active, pressed, inactive }

/// Paper Button Component
///
/// A comprehensive button component with multiple color and state variants.
/// Ported from Paper Multiverse DS 2.0
class PaperButton extends StatelessWidget {
  const PaperButton({
    required this.text,
    required this.onPressed,
    this.leftIcon,
    this.rightIcon,
    this.widthType = PaperButtonWidth.medium,
    this.buttonState = PaperButtonState.active,
    this.buttonColor = PaperButtonColor.blue,
    this.customWidth,
    this.customFontSize,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final PaperButtonWidth? widthType;
  final PaperButtonState? buttonState;
  final PaperButtonColor? buttonColor;
  final num? customWidth;
  final num? customFontSize;

  double _generateWidth(PaperButtonWidth widthType) {
    switch (widthType) {
      case PaperButtonWidth.large:
        return double.maxFinite;
      case PaperButtonWidth.medium:
        return 210;
      case PaperButtonWidth.small:
        return 167;
      case PaperButtonWidth.smaller:
        return 147;
      case PaperButtonWidth.tiny:
        return 120;
      case PaperButtonWidth.custom:
        return (customWidth ?? 120).toDouble();
    }
  }

  double _generateFontSize(PaperButtonWidth widthType) {
    switch (widthType) {
      case PaperButtonWidth.large:
        return 16;
      case PaperButtonWidth.medium:
        return 14;
      case PaperButtonWidth.small:
        return 12;
      case PaperButtonWidth.custom:
        return (customFontSize ?? 10).toDouble();
      default:
        return 14;
    }
  }

  Color _generateBackgroundColor(
    PaperButtonState buttonState,
    PaperButtonColor buttonColor,
  ) {
    if (buttonColor.name.toLowerCase().contains('secondary') &&
        buttonColor.name.toLowerCase().contains('white')) {
      return Colors.transparent;
    }

    if (buttonColor.name.toLowerCase().contains('secondary')) {
      return PaperArtboardColor.surfaceVariant;
    }

    if (buttonColor.name.toLowerCase().contains('ghost')) {
      return Colors.transparent;
    }

    switch (buttonColor) {
      case PaperButtonColor.blue:
        return buttonState == PaperButtonState.inactive
            ? PaperColor.blue30
            : PaperColor.blue;

      case PaperButtonColor.green:
        return buttonState == PaperButtonState.inactive
            ? PaperColor.green30
            : PaperColor.green;

      case PaperButtonColor.red:
        return buttonState == PaperButtonState.inactive
            ? PaperColor.red30
            : PaperColor.red;
      default:
        return buttonState == PaperButtonState.inactive
            ? PaperColor.blue30
            : PaperColor.blue;
    }
  }

  Color _generateBorderColor(
    PaperButtonState buttonState,
    PaperButtonColor buttonColor,
  ) {
    if (buttonState == PaperButtonState.inactive) {
      return PaperArtboardColor.divider;
    }

    switch (buttonColor) {
      case PaperButtonColor.blueSecondary:
      case PaperButtonColor.blueGhost:
        return PaperColor.blue;
      case PaperButtonColor.greenSecondary:
      case PaperButtonColor.greenGhost:
        return PaperColor.green;
      case PaperButtonColor.redSecondary:
      case PaperButtonColor.redGhost:
        return PaperColor.red;
      case PaperButtonColor.whiteSecondary:
      case PaperButtonColor.whiteGhost:
        return PaperColor.white;
      case PaperButtonColor.greySecondary:
        return PaperColor.darkGrey30;
      case PaperButtonColor.greyGhost:
        return PaperColor.white;
      default:
        return PaperColor.blue;
    }
  }

  Color _generateTextColor(
    PaperButtonState buttonState,
    PaperButtonColor buttonColor,
  ) {
    if (buttonColor.name.toLowerCase().contains('secondary') ||
        buttonColor.name.toLowerCase().contains('ghost')) {
      if (buttonState == PaperButtonState.inactive) {
        return PaperArtboardColor.divider;
      }

      switch (buttonColor) {
        case PaperButtonColor.blueSecondary:
        case PaperButtonColor.blueGhost:
          return PaperColor.blue;
        case PaperButtonColor.greenSecondary:
        case PaperButtonColor.greenGhost:
          return PaperColor.green;
        case PaperButtonColor.redSecondary:
        case PaperButtonColor.redGhost:
          return PaperColor.red;
        case PaperButtonColor.whiteSecondary:
        case PaperButtonColor.whiteGhost:
          return PaperColor.white;
        case PaperButtonColor.greySecondary:
        case PaperButtonColor.greyGhost:
          return PaperColor.darkBlue30;
        default:
          return PaperColor.blue;
      }
    } else {
      return PaperColor.white;
    }
  }

  double _generateHeight(BuildContext context) {
    final fontSize = _generateFontSize(widthType!);
    final textScale =
        MediaQuery.of(context).textScaler.scale(fontSize) / fontSize;

    if (textScale == 1.0) {
      return 50;
    }
    return 50 * textScale;
  }

  @override
  Widget build(BuildContext context) {
    final isSecondary = buttonColor!.name.toLowerCase().contains('secondary');

    return Material(
      color: _generateBackgroundColor(buttonState!, buttonColor!),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSecondary
              ? _generateBorderColor(buttonState!, buttonColor!)
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: buttonState == PaperButtonState.inactive ? null : onPressed,
        child: Container(
          constraints: BoxConstraints(
            minWidth: _generateWidth(widthType!),
            maxHeight: _generateHeight(context),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widthType == PaperButtonWidth.large
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (leftIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: leftIcon,
                ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: _generateFontSize(widthType!),
                  fontWeight: FontWeight.w700,
                  color: _generateTextColor(buttonState!, buttonColor!),
                ),
              ),
              if (rightIcon != null) rightIcon!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience factory constructors for common button variants
extension PaperButtonExt on PaperButton {
  /// Creates a full-width blue primary button
  static PaperButton primary({
    required String text,
    required VoidCallback? onPressed,
    Widget? leftIcon,
    bool enabled = true,
  }) {
    return PaperButton(
      text: text,
      onPressed: onPressed,
      leftIcon: leftIcon,
      widthType: PaperButtonWidth.large,
      buttonState: enabled ? PaperButtonState.active : PaperButtonState.inactive,
      buttonColor: PaperButtonColor.blue,
    );
  }

  /// Creates a full-width outlined button
  static PaperButton secondary({
    required String text,
    required VoidCallback? onPressed,
    Widget? leftIcon,
    bool enabled = true,
  }) {
    return PaperButton(
      text: text,
      onPressed: onPressed,
      leftIcon: leftIcon,
      widthType: PaperButtonWidth.large,
      buttonState: enabled ? PaperButtonState.active : PaperButtonState.inactive,
      buttonColor: PaperButtonColor.blueSecondary,
    );
  }

  /// Creates a danger/red button
  static PaperButton danger({
    required String text,
    required VoidCallback? onPressed,
    Widget? leftIcon,
    bool enabled = true,
  }) {
    return PaperButton(
      text: text,
      onPressed: onPressed,
      leftIcon: leftIcon,
      widthType: PaperButtonWidth.large,
      buttonState: enabled ? PaperButtonState.active : PaperButtonState.inactive,
      buttonColor: PaperButtonColor.red,
    );
  }

  /// Creates a success/green button
  static PaperButton success({
    required String text,
    required VoidCallback? onPressed,
    Widget? leftIcon,
    bool enabled = true,
  }) {
    return PaperButton(
      text: text,
      onPressed: onPressed,
      leftIcon: leftIcon,
      widthType: PaperButtonWidth.large,
      buttonState: enabled ? PaperButtonState.active : PaperButtonState.inactive,
      buttonColor: PaperButtonColor.green,
    );
  }
}
