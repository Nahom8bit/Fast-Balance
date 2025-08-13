import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts manager for productivity features
class KeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final Map<ShortcutKey, VoidCallback> shortcuts;
  final bool enabled;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    required this.shortcuts,
    this.enabled = true,
  });

  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          _handleKeyPress(event);
        }
        return KeyEventResult.handled;
      },
      child: widget.child,
    );
  }

  void _handleKeyPress(KeyDownEvent event) {
    final key = ShortcutKey(
      key: event.logicalKey,
      ctrl: HardwareKeyboard.instance.isControlPressed,
      shift: HardwareKeyboard.instance.isShiftPressed,
      alt: HardwareKeyboard.instance.isAltPressed,
    );

    final callback = widget.shortcuts[key];
    if (callback != null) {
      callback();
    }
  }
}

/// Shortcut key definition
class ShortcutKey {
  final LogicalKeyboardKey key;
  final bool ctrl;
  final bool shift;
  final bool alt;

  const ShortcutKey({
    required this.key,
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShortcutKey &&
        other.key == key &&
        other.ctrl == ctrl &&
        other.shift == shift &&
        other.alt == alt;
  }

  @override
  int get hashCode {
    return Object.hash(key, ctrl, shift, alt);
  }

  @override
  String toString() {
    final parts = <String>[];
    if (ctrl) parts.add('Ctrl');
    if (shift) parts.add('Shift');
    if (alt) parts.add('Alt');
    parts.add(key.keyLabel);
    return parts.join('+');
  }
}

/// Common shortcut keys
class CommonShortcuts {
  static const save = ShortcutKey(
    key: LogicalKeyboardKey.keyS,
    ctrl: true,
  );
  
  static const newRecord = ShortcutKey(
    key: LogicalKeyboardKey.keyN,
    ctrl: true,
  );
  
  static const search = ShortcutKey(
    key: LogicalKeyboardKey.keyF,
    ctrl: true,
  );
  
  static const print = ShortcutKey(
    key: LogicalKeyboardKey.keyP,
    ctrl: true,
  );
  
  static const refresh = ShortcutKey(
    key: LogicalKeyboardKey.keyR,
    ctrl: true,
  );
  
  static const escape = ShortcutKey(
    key: LogicalKeyboardKey.escape,
  );
  
  static const enter = ShortcutKey(
    key: LogicalKeyboardKey.enter,
  );
  
  static const tab = ShortcutKey(
    key: LogicalKeyboardKey.tab,
  );
}

/// Quick actions menu widget
class QuickActionsMenu extends StatelessWidget {
  final List<QuickAction> actions;
  final Widget? child;

  const QuickActionsMenu({
    super.key,
    required this.actions,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<QuickAction>(
      itemBuilder: (context) => actions.map((action) {
        return PopupMenuItem(
          value: action,
          child: Row(
            children: [
              Icon(action.icon, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(action.label)),
              if (action.shortcut != null) ...[
                const SizedBox(width: 8),
                Text(
                  action.shortcut.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onSelected: (action) => action.onTap?.call(),
      child: child ?? const Icon(Icons.more_vert),
    );
  }
}

/// Quick action definition
class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final ShortcutKey? shortcut;

  const QuickAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.shortcut,
  });
}

/// Auto-save functionality
class AutoSave extends StatefulWidget {
  final Widget child;
  final VoidCallback onSave;
  final Duration interval;
  final bool enabled;

  const AutoSave({
    super.key,
    required this.child,
    required this.onSave,
    this.interval = const Duration(minutes: 2),
    this.enabled = true,
  });

  @override
  State<AutoSave> createState() => _AutoSaveState();
}

class _AutoSaveState extends State<AutoSave> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startAutoSave();
    }
  }

  @override
  void didUpdateWidget(AutoSave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startAutoSave();
      } else {
        _stopAutoSave();
      }
    }
  }

  void _startAutoSave() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      widget.onSave();
    });
  }

  void _stopAutoSave() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoSave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Bulk operations widget
class BulkOperations extends StatefulWidget {
  final List<Widget> children;
  final List<BulkAction> actions;
  final bool enabled;

  const BulkOperations({
    super.key,
    required this.children,
    required this.actions,
    this.enabled = true,
  });

  @override
  State<BulkOperations> createState() => _BulkOperationsState();
}

class _BulkOperationsState extends State<BulkOperations> {
  final Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.enabled && _selectedIndices.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedIndices.length} items selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ...widget.actions.map((action) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => action.onExecute(_selectedIndices.toList()),
                    icon: Icon(action.icon, size: 16),
                    label: Text(action.label),
                  ),
                )),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _clearSelection,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return CheckboxListTile(
            value: _selectedIndices.contains(index),
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedIndices.add(index);
                } else {
                  _selectedIndices.remove(index);
                }
              });
            },
            title: child,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }),
      ],
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedIndices.clear();
    });
  }
}

/// Bulk action definition
class BulkAction {
  final String label;
  final IconData icon;
  final Function(List<int> indices) onExecute;

  const BulkAction({
    required this.label,
    required this.icon,
    required this.onExecute,
  });
}

/// Focus management widget
class FocusManager extends StatelessWidget {
  final Widget child;
  final List<FocusNode> focusNodes;

  const FocusManager({
    super.key,
    required this.child,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          _handleKeyNavigation(event);
        }
      },
      child: child,
    );
  }

  void _handleKeyNavigation(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      // Handle tab navigation
      _navigateFocus(HardwareKeyboard.instance.isShiftPressed);
    }
  }

  void _navigateFocus(bool reverse) {
    // Implement focus navigation logic
    // This would cycle through focus nodes
  }
} 