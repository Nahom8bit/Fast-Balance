
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Callback types for different actions
typedef ShortcutCallback = void Function();
typedef ContextShortcutCallback = void Function(BuildContext context);

class KeyboardShortcutsService {
  static final KeyboardShortcutsService _instance = KeyboardShortcutsService._internal();
  factory KeyboardShortcutsService() => _instance;
  KeyboardShortcutsService._internal();

  static KeyboardShortcutsService get instance => _instance;

  // Global shortcut callbacks
  final Map<LogicalKeySet, ShortcutCallback> _globalShortcuts = {};
  final Map<LogicalKeySet, ContextShortcutCallback> _contextShortcuts = {};

  // Common keyboard shortcuts
  static final LogicalKeySet saveShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS);
  static final LogicalKeySet printShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP);
  static final LogicalKeySet newShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN);
  static final LogicalKeySet refreshShortcut = LogicalKeySet(LogicalKeyboardKey.f5);
  static final LogicalKeySet escapeShortcut = LogicalKeySet(LogicalKeyboardKey.escape);
  static final LogicalKeySet deleteShortcut = LogicalKeySet(LogicalKeyboardKey.delete);
  static final LogicalKeySet editShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE);
  static final LogicalKeySet searchShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF);
  static final LogicalKeySet exportShortcut = LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX);
  static final LogicalKeySet helpShortcut = LogicalKeySet(LogicalKeyboardKey.f1);

  // Register a global shortcut
  void registerGlobalShortcut(LogicalKeySet keySet, ShortcutCallback callback) {
    _globalShortcuts[keySet] = callback;
  }

  // Register a context-aware shortcut
  void registerContextShortcut(LogicalKeySet keySet, ContextShortcutCallback callback) {
    _contextShortcuts[keySet] = callback;
  }

  // Unregister shortcuts
  void unregisterShortcut(LogicalKeySet keySet) {
    _globalShortcuts.remove(keySet);
    _contextShortcuts.remove(keySet);
  }

  // Clear all shortcuts
  void clearAllShortcuts() {
    _globalShortcuts.clear();
    _contextShortcuts.clear();
  }

  // Get shortcuts map for Shortcuts widget
  Map<LogicalKeySet, Intent> getShortcutsMap() {
    final Map<LogicalKeySet, Intent> shortcuts = {};
    
    for (final keySet in _globalShortcuts.keys) {
      shortcuts[keySet] = CallbackIntent(key: keySet);
    }
    
    for (final keySet in _contextShortcuts.keys) {
      shortcuts[keySet] = CallbackIntent(key: keySet);
    }
    
    return shortcuts;
  }

  // Get actions map for Actions widget
  Map<Type, Action<Intent>> getActionsMap(BuildContext context) {
    return {
      CallbackIntent: CallbackAction<CallbackIntent>(
        onInvoke: (intent) {
          final keySet = intent.key;
          
          // Try global shortcuts first
          if (_globalShortcuts.containsKey(keySet)) {
            _globalShortcuts[keySet]!();
            return null;
          }
          
          // Then try context shortcuts
          if (_contextShortcuts.containsKey(keySet)) {
            _contextShortcuts[keySet]!(context);
            return null;
          }
          
          return null;
        },
      ),
    };
  }

  // Show shortcuts help dialog
  static void showShortcutsHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Keyboard Shortcuts'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShortcutSection('General', [
                _ShortcutInfo('Ctrl + S', 'Save current form'),
                _ShortcutInfo('Ctrl + P', 'Print receipt'),
                _ShortcutInfo('Ctrl + N', 'New record'),
                _ShortcutInfo('F5', 'Refresh data'),
                _ShortcutInfo('Esc', 'Cancel/Close'),
                _ShortcutInfo('F1', 'Show this help'),
              ]),
              const SizedBox(height: 16),
              _buildShortcutSection('Admin Panel', [
                _ShortcutInfo('Ctrl + F', 'Focus search'),
                _ShortcutInfo('Ctrl + E', 'Edit selected'),
                _ShortcutInfo('Delete', 'Delete selected'),
                _ShortcutInfo('Ctrl + X', 'Export data'),
              ]),
              const SizedBox(height: 16),
              _buildShortcutSection('Navigation', [
                _ShortcutInfo('Tab', 'Next field'),
                _ShortcutInfo('Shift + Tab', 'Previous field'),
                _ShortcutInfo('Enter', 'Submit/Confirm'),
                _ShortcutInfo('Space', 'Toggle/Select'),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildShortcutSection(String title, List<_ShortcutInfo> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...shortcuts.map((shortcut) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Text(
                  shortcut.keys,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  shortcut.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _ShortcutInfo {
  final String keys;
  final String description;

  _ShortcutInfo(this.keys, this.description);
}

class CallbackIntent extends Intent {
  const CallbackIntent({required this.key});
  final LogicalKeySet key;
}

// Widget wrapper for keyboard shortcuts
class KeyboardShortcutsWrapper extends StatefulWidget {
  final Widget child;
  final Map<LogicalKeySet, VoidCallback>? shortcuts;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.shortcuts,
  });

  @override
  State<KeyboardShortcutsWrapper> createState() => _KeyboardShortcutsWrapperState();
}

class _KeyboardShortcutsWrapperState extends State<KeyboardShortcutsWrapper> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService.instance;

  @override
  void initState() {
    super.initState();
    _registerShortcuts();
  }

  @override
  void dispose() {
    _unregisterShortcuts();
    super.dispose();
  }

  void _registerShortcuts() {
    if (widget.shortcuts != null) {
      for (final entry in widget.shortcuts!.entries) {
        _shortcutsService.registerGlobalShortcut(entry.key, entry.value);
      }
    }
  }

  void _unregisterShortcuts() {
    if (widget.shortcuts != null) {
      for (final keySet in widget.shortcuts!.keys) {
        _shortcutsService.unregisterShortcut(keySet);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcutsService.getShortcutsMap(),
      child: Actions(
        actions: _shortcutsService.getActionsMap(context),
        child: Focus(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}
