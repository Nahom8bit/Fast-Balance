import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Accessibility wrapper for screen reader support
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isSelected;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      selected: isSelected,
      onTap: onTap,
      child: child,
    );
  }
}

/// High contrast mode support
class HighContrastWidget extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const HighContrastWidget({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: _getHighContrastColorScheme(context),
        textTheme: _getHighContrastTextTheme(context),
      ),
      child: child,
    );
  }

  ColorScheme _getHighContrastColorScheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      );
    } else {
      return const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.blue,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        background: Colors.white,
        onBackground: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      );
    }
  }

  TextTheme _getHighContrastTextTheme(BuildContext context) {
    final baseTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return baseTheme.copyWith(
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Keyboard navigation support
class KeyboardNavigableWidget extends StatelessWidget {
  final Widget child;
  final FocusNode? focusNode;
  final VoidCallback? onEnter;
  final VoidCallback? onEscape;
  final bool autofocus;

  const KeyboardNavigableWidget({
    super.key,
    required this.child,
    this.focusNode,
    this.onEnter,
    this.onEscape,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
            onEnter!();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape && onEscape != null) {
            onEscape!();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// Focus indicator for keyboard navigation
class FocusIndicator extends StatelessWidget {
  final Widget child;
  final bool showIndicator;
  final Color? indicatorColor;

  const FocusIndicator({
    super.key,
    required this.child,
    this.showIndicator = true,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIndicator) {
      return child;
    }

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          final color = indicatorColor ?? Theme.of(context).colorScheme.primary;

          return Container(
            decoration: hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: color,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  )
                : null,
            child: child,
          );
        },
      ),
    );
  }
}

/// Screen reader announcement
class ScreenReaderAnnouncement extends StatelessWidget {
  final String message;
  final Widget child;

  const ScreenReaderAnnouncement({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      child: child,
    );
  }
}

/// Accessible button with proper semantics
class AccessibleButton extends StatelessWidget {
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final Widget? icon;
  final ButtonStyle? style;
  final bool isOutlined;

  const AccessibleButton({
    super.key,
    required this.label,
    this.hint,
    this.onPressed,
    this.icon,
    this.style,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(label),
            style: style,
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(label),
            style: style,
          );

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

/// Accessible text field with proper semantics
class AccessibleTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const AccessibleTextField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      readOnly: readOnly,
      onTap: onTap,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }
}

/// Accessible list item with proper semantics
class AccessibleListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;

  const AccessibleListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      hint: subtitle,
      value: value,
      selected: isSelected,
      onTap: onTap,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        selected: isSelected,
      ),
    );
  }
}

/// Accessibility settings provider
class AccessibilitySettings extends ChangeNotifier {
  bool _highContrastEnabled = false;
  bool _screenReaderEnabled = false;
  bool _keyboardNavigationEnabled = true;
  double _textScaleFactor = 1.0;

  bool get highContrastEnabled => _highContrastEnabled;
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get keyboardNavigationEnabled => _keyboardNavigationEnabled;
  double get textScaleFactor => _textScaleFactor;

  void toggleHighContrast() {
    _highContrastEnabled = !_highContrastEnabled;
    notifyListeners();
  }

  void toggleScreenReader() {
    _screenReaderEnabled = !_screenReaderEnabled;
    notifyListeners();
  }

  void toggleKeyboardNavigation() {
    _keyboardNavigationEnabled = !_keyboardNavigationEnabled;
    notifyListeners();
  }

  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.5, 3.0);
    notifyListeners();
  }
} 