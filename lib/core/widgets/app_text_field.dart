import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

/// iOS-style text field
/// Gray fill background, no border, rounded corners
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autovalidateMode,
    this.initialValue,
    this.showClearButton = false,
    this.fillColor,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? initialValue;
  final bool showClearButton;
  final Color? fillColor;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    final defaultFillColor = isDark
        ? AppColors.fillSecondaryDark
        : AppColors.fillSecondary;

    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    final hintColor = isDark
        ? AppColors.textPlaceholderDark
        : AppColors.textPlaceholder;

    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    // Build suffix widget
    Widget? suffixWidget;
    if (widget.showClearButton && _controller.text.isNotEmpty && _isFocused) {
      suffixWidget = GestureDetector(
        onTap: () {
          _controller.clear();
          widget.onChanged?.call('');
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.cancel,
            size: 18,
            color: isDark ? AppColors.gray4Dark : AppColors.gray4,
          ),
        ),
      );
    } else if (widget.obscureText) {
      suffixWidget = GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: isDark ? AppColors.gray3Dark : AppColors.gray3,
          ),
        ),
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.suffixIcon != null) {
      suffixWidget = Icon(
        widget.suffixIcon,
        size: 20,
        color: isDark ? AppColors.gray3Dark : AppColors.gray3,
      );
    }

    // Build prefix widget
    Widget? prefixWidget;
    if (widget.prefix != null) {
      prefixWidget = widget.prefix;
    } else if (widget.prefixIcon != null) {
      prefixWidget = Icon(
        widget.prefixIcon,
        size: 20,
        color: isDark ? AppColors.gray3Dark : AppColors.gray3,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.subheadline.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.vXs,
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {});
          },
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: AppTextStyles.body.copyWith(color: textColor),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body.copyWith(color: hintColor),
            filled: true,
            fillColor: widget.fillColor ?? defaultFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: prefixWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: prefixWidget,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffixWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffixWidget,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
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
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            counterText: '',
          ),
        ),
        if (widget.error != null && widget.error!.isNotEmpty) ...[
          AppSpacing.vXxs,
          Text(
            widget.error!,
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (widget.helper != null) ...[
          AppSpacing.vXxs,
          Text(
            widget.helper!,
            style: AppTextStyles.caption1.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// iOS-style search field
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.fillTertiaryDark : AppColors.fillTertiary,
        borderRadius: AppRadius.allMd,
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(() {});
        },
        onSubmitted: widget.onSubmitted,
        style: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: isDark
                ? AppColors.textPlaceholderDark
                : AppColors.textPlaceholder,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? AppColors.gray3Dark : AppColors.gray3,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                    setState(() {});
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.cancel,
                    size: 16,
                    color: isDark ? AppColors.gray4Dark : AppColors.gray4,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}
