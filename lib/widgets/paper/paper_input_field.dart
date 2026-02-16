import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';

/// Paper Input Field Type
enum PaperInputFieldType { outline, underline }

/// Paper Input Field Component
///
/// A comprehensive input field with label, validation, helper text support.
/// Ported from Paper Multiverse DS 2.0
class PaperInputField extends StatefulWidget {
  const PaperInputField({
    this.labelText = '',
    this.secondaryLabelText = '',
    this.hintText = '',
    this.suffixIcon,
    this.prefixIcon,
    this.disable = false,
    this.validation,
    this.required = false,
    this.optional = false,
    this.helperText = '',
    this.errorText = '',
    this.controller,
    this.focusNode,
    this.fieldType = PaperInputFieldType.outline,
    required this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign,
    this.textInputAction,
    this.maxLines = 1,
    this.readonly = false,
    this.fillColor,
    this.borderColor,
    this.dense = false,
    this.initialCheck = false,
    this.onFocusChange,
    this.obscureText = false,
    this.contentPadding,
    super.key,
  });

  final String? labelText;
  final String? secondaryLabelText;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? disable;
  final bool? readonly;
  final bool Function(String val)? validation;
  final bool? required;
  final bool? optional;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final PaperInputFieldType fieldType;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final Color? fillColor;
  final Color? borderColor;
  final bool? dense;
  final bool? initialCheck;
  final ValueChanged<bool>? onFocusChange;
  final bool obscureText;
  final EdgeInsets? contentPadding;

  @override
  State<PaperInputField> createState() => PaperInputFieldState();
}

class PaperInputFieldState extends State<PaperInputField> {
  late FocusNode _focus;
  bool isFocus = false;
  bool isError = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
    _controller = widget.controller ?? TextEditingController();
    _initialError();
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChange?.call(_focus.hasFocus);
    setState(() {
      isFocus = _focus.hasFocus;
    });
  }

  void _initialError() {
    if (widget.validation != null && widget.initialCheck == true) {
      isError = widget.validation!(_controller.text);
    }
  }

  void setError() {
    setState(() => isError = true);
  }

  void setValid() {
    setState(() => isError = false);
  }

  void validate() {
    setState(() {
      if (widget.validation != null) {
        isError = widget.validation!(_controller.text);
      }
    });
  }

  InputBorder _setInputType({bool isFocusState = false}) {
    Color borderColor;

    if (widget.disable == true) {
      borderColor = PaperColor.grey30;
    } else if (isError) {
      borderColor = PaperColor.red;
    } else if (isFocusState) {
      borderColor = PaperColor.blue;
    } else {
      borderColor = widget.borderColor ?? PaperArtboardColor.border;
    }

    switch (widget.fieldType) {
      case PaperInputFieldType.outline:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderColor),
        );
      case PaperInputFieldType.underline:
        return UnderlineInputBorder(borderSide: BorderSide(color: borderColor));
    }
  }

  Color _backgroundColor() {
    if (widget.disable == true) {
      return PaperColor.grey10;
    } else if (widget.fillColor != null) {
      return widget.fillColor!;
    } else {
      return PaperArtboardColor.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if ((widget.labelText ?? '').isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  widget.labelText!,
                  style: PaperText.headingSmall.copyWith(
                    color: isError
                        ? PaperTextColor.red
                        : isFocus
                            ? PaperTextColor.blue
                            : PaperTextColor.primary,
                  ),
                ),
                if ((widget.secondaryLabelText ?? '').isNotEmpty)
                  Text(
                    ' ${widget.secondaryLabelText}',
                    style: PaperText.bodySmall.secondary,
                  ),
                if (widget.required == true)
                  Text(
                    ' *',
                    style: PaperText.headingSmall.red,
                  ),
                if (widget.optional == true)
                  Text(
                    ' (Opsional)',
                    style: PaperText.bodySmall.secondary,
                  ),
              ],
            ),
          ),
        ],

        // Text Field
        TextField(
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textAlign: widget.textAlign ?? TextAlign.start,
          textInputAction: widget.textInputAction,
          enabled: widget.disable != true,
          readOnly: widget.readonly ?? false,
          obscureText: widget.obscureText,
          onSubmitted: (val) {
            widget.onSubmitted?.call(val);
            setState(() {
              if (widget.validation != null) {
                isError = widget.validation!(val);
              }
            });
          },
          onChanged: (val) {
            widget.onChanged(val);
            setState(() {
              if (widget.validation != null) {
                isError = widget.validation!(val);
              }
            });
          },
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          autocorrect: false,
          controller: _controller,
          focusNode: _focus,
          style: PaperText.bodyRegular.copyWith(
            color: PaperTextColor.primary,
          ),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            hintText: widget.hintText,
            hintStyle: PaperText.bodyRegular.copyWith(
              color: PaperTextColor.tertiary,
            ),
            counterText: '',
            fillColor: _backgroundColor(),
            filled: true,
            isDense: widget.dense,
            enabledBorder: _setInputType(),
            focusedBorder: _setInputType(isFocusState: true),
            disabledBorder: _setInputType(),
            errorBorder: _setInputType(),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: PaperSpacing.md,
                  vertical: PaperSpacing.md,
                ),
          ),
        ),

        // Helper/Error Text
        if ((widget.helperText ?? '').isNotEmpty || isError) ...[
          const SizedBox(height: 4),
          if (isError && (widget.errorText ?? '').isNotEmpty)
            Text(
              widget.errorText!,
              style: PaperText.bodyXSmall.red,
            ),
          if ((widget.helperText ?? '').isNotEmpty)
            Text(
              widget.helperText!,
              style: PaperText.bodyXSmall.secondary,
            ),
        ],
      ],
    );
  }
}

/// Password Input Field with show/hide toggle
class PaperPasswordField extends StatefulWidget {
  const PaperPasswordField({
    this.labelText = 'Password',
    this.hintText = 'Enter password',
    this.required = false,
    this.controller,
    required this.onChanged,
    this.validation,
    this.errorText,
    super.key,
  });

  final String? labelText;
  final String? hintText;
  final bool? required;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final bool Function(String val)? validation;
  final String? errorText;

  @override
  State<PaperPasswordField> createState() => _PaperPasswordFieldState();
}

class _PaperPasswordFieldState extends State<PaperPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return PaperInputField(
      labelText: widget.labelText,
      hintText: widget.hintText,
      required: widget.required,
      controller: widget.controller,
      onChanged: widget.onChanged,
      validation: widget.validation,
      errorText: widget.errorText,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: PaperIconColor.lowerEmphasis,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
