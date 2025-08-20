import 'package:flutter/material.dart';

class FormValidationService {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateNumber(String? value, {String? fieldName, double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }
    
    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} cannot exceed $max';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final result = validateNumber(value, fieldName: fieldName, min: 0);
    return result;
  }

  static String? validateCurrency(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    // Remove currency symbols and spaces
    String cleanValue = value.replaceAll(RegExp(r'[^\d.,]'), '');
    cleanValue = cleanValue.replaceAll(',', '.');
    
    final number = double.tryParse(cleanValue);
    if (number == null) {
      return 'Please enter a valid amount';
    }
    
    if (number < 0) {
      return 'Amount cannot be negative';
    }
    
    return null;
  }

  static String? validateDescription(String? value, {int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    
    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return 'Description cannot exceed $maxLength characters';
    }
    
    return null;
  }

  static String? validateDropdown(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please select ${fieldName ?? 'an option'}';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }
}

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final bool validateOnChange;
  final int? maxLines;
  final int? maxLength;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validateOnChange = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasBeenTouched && widget.validateOnChange) {
      _validateField();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
      });
    }
  }

  void _onFocusLost() {
    setState(() {
      _hasBeenTouched = true;
    });
    _validateField();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _onFocusLost();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText != null 
                      ? Colors.red 
                      : Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: _errorText != null 
                  ? Colors.red.withValues(alpha: 0.05)
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[50],
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ValidatedDropdown<T> extends StatefulWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool validateOnChange;

  const ValidatedDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.onChanged,
    this.validator,
    this.validateOnChange = true,
  });

  @override
  State<ValidatedDropdown<T>> createState() => _ValidatedDropdownState<T>();
}

class _ValidatedDropdownState<T> extends State<ValidatedDropdown<T>> {
  String? _errorText;

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.value);
      });
    }
  }

  void _onChanged(T? value) {
    if (widget.validateOnChange) {
      _validateField();
    }
    
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          value: widget.value,
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorText != null 
                    ? Colors.red 
                    : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: _errorText != null 
                ? Colors.red.withValues(alpha: 0.05)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[50],
          ),
          items: widget.items,
          onChanged: _onChanged,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red[700],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FormValidationIndicator extends StatelessWidget {
  final bool isValid;
  final String? message;
  final bool showIcon;

  const FormValidationIndicator({
    super.key,
    required this.isValid,
    this.message,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              isValid ? Icons.check_circle : Icons.warning,
              color: isValid ? Colors.green[700] : Colors.orange[700],
              size: 18,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: isValid ? Colors.green[700] : Colors.orange[700],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
