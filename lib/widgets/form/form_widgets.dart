import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';

/// Input field type
enum InputType {
  text,
  number,
  amount,
  date,
  select,
  search,
}

/// Standardized input field with validation
///
/// Provides consistent form input across application.
class AppInputField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final InputType type;
  final bool readOnly;
  final bool required;
  final int? maxLines;
  final bool obscureText;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? helperText;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? hintText;

  const AppInputField({
    super.key,
    required this.label,
    this.initialValue,
    this.controller,
    this.validator,
    this.type = InputType.text,
    this.readOnly = false,
    this.required = false,
    this.maxLines,
    this.obscureText = false,
    this.onTap,
    this.suffixIcon,
    this.helperText,
    this.maxLength,
    this.textInputAction,
    this.hintText,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (widget.label.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    children.add(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.readOnly
                ? AppColors.border.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: _controller,
          validator: widget.validator,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            border: InputBorder.none,
            enabled: !widget.readOnly,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            errorStyle: const TextStyle(color: AppColors.statusRejected),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.statusRejected, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.statusRejected, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffixIcon,
                  )
                : null,
          ),
        ),
      ),
    );

    if (widget.helperText != null) {
      children.add(const SizedBox(height: 4));
      children.add(
        Text(
          widget.helperText!,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// Standardized date picker
///
/// Provides consistent date selection across application.
class AppDatePicker extends StatelessWidget {
  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;

  const AppDatePicker({
    super.key,
    this.label,
    this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showCupertinoModalPopup<DateTime>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                initialDateTime: value,
                mode: CupertinoDatePickerMode.date,
                minimumDate: firstDate,
                maximumDate: lastDate,
                minimumYear: 2000,
                maximumYear: DateTime.now().year,
                onDateTimeChanged: (DateTime dateTime) {
                  Navigator.of(context).pop(dateTime);
                },
              ),
            );
          },
        );

        if (picked != null) {
          onChanged(picked);
        }
      },
      child: _buildDateField(),
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                value != null
                    ? '${value!.day}/${value!.month}/${value!.year}'
                    : 'Select Date',
                style: TextStyle(
                  fontSize: 14,
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: required ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized dropdown
///
/// Provides consistent dropdown selection across application.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<T>? items;
  final String Function(T)? displayString;
  final ValueChanged<T?> onChanged;
  final bool required;
  final String? hintText;
  final String? emptyText;

  const AppDropdown({
    super.key,
    this.label,
    this.value,
    this.items,
    this.displayString,
    required this.onChanged,
    this.required = false,
    this.hintText,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (label != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    children.add(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items?.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  displayString?.call(item) ?? item.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            hint: Text(
              hintText ?? emptyText ?? 'Select an option',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            icon: value != null
                ? const Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: AppColors.textMuted,
                  )
                : null,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// Amount input field with currency formatting
///
/// Provides formatted amount input with currency prefix.
class AppAmountInput extends StatefulWidget {
  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool required;
  final String currency;
  final VoidCallback? onCurrencyTap;

  const AppAmountInput({
    super.key,
    required this.label,
    this.initialValue,
    this.controller,
    this.validator,
    this.required = false,
    this.currency = 'IDR',
    this.onCurrencyTap,
  });

  @override
  State<AppAmountInput> createState() => _AppAmountInputState();
}

class _AppAmountInputState extends State<AppAmountInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (widget.label.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    children.add(
      GestureDetector(
        onTap: widget.onCurrencyTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  widget.currency,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  validator: widget.validator,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _AmountFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(
                      CupertinoIcons.money_dollar_circle,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digit characters except comma (for decimal separator)
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Check if there's already a decimal separator (comma)
    int commaIndex = cleanText.indexOf(',');
    String integerPart;
    String decimalPart = '';

    if (commaIndex != -1) {
      // Split into integer and decimal parts
      integerPart = cleanText.substring(0, commaIndex);
      decimalPart = cleanText.substring(commaIndex + 1);
    } else {
      integerPart = cleanText;
    }

    // Remove leading zeros from integer part
    integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    // Add thousand separator (using dots for Indonesian format)
    // Process from right to left
    String withSeparator = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if ((integerPart.length - 1 - i) % 3 == 0 && i > 0) {
        // Add dot every 3 digits from the right, but skip position 0
        withSeparator += '.';
      }
      withSeparator += integerPart[i];
    }

    // Combine integer part, decimal part, and new selection
    String formattedText = withSeparator;
    if (decimalPart.isNotEmpty) {
      formattedText = '$formattedText,$decimalPart';
    }

    // Preserve cursor position
    int selectionIndex = formattedText.length;
    if (newValue.selection.end <= cleanText.length) {
      selectionIndex = formattedText.length -
          (cleanText.length - newValue.selection.end);
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: selectionIndex,
      affinity: TextAffinity.downstream,
      ),
    );
  }
}
