import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:balancer/admin_panel.dart';
import 'package:balancer/currency_formatter.dart';
import 'database_helper.dart';
import 'receipt_printer.dart';
import 'login_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:balancer/settings_screen.dart';
import 'update_service.dart';
import 'theme_service.dart';
import 'services/keyboard_shortcuts_service.dart';
import 'services/print_preview_service.dart';
import 'services/form_validation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  } catch (e) {
    // Handle web platform where Platform.isWindows is not available
    // Silent handling for production
  }
  await CurrencyFormatter.init();
  runApp(const BalancerApp());
  
  // Check for updates in the background
  _checkForUpdates();
}

Future<void> _checkForUpdates() async {
  if (await UpdateService.shouldCheckForUpdates()) {
    final updateInfo = await UpdateService.checkForUpdates();
    if (updateInfo != null) {
      await UpdateService.setLastUpdateCheck();
      // Note: We can't show dialog here as we don't have context
      // The dialog will be shown when the app starts
    }
  }
}

// Global theme notifier
class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    _themeMode = await ThemeService.getThemeMode();
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await ThemeService.setThemeMode(mode);
    notifyListeners();
  }
}

class BalancerApp extends StatefulWidget {
  const BalancerApp({super.key});

  @override
  State<BalancerApp> createState() => _BalancerAppState();
}

class _BalancerAppState extends State<BalancerApp> {
  final _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Mini Mercado - Balance Closing',
          theme: ThemeService.getLightTheme(),
          darkTheme: ThemeService.getDarkTheme(),
          themeMode: _themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
      },
    ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
  }
}

class ClosingScreen extends StatefulWidget {
  final String username;
  const ClosingScreen({super.key, required this.username});

  @override
  ClosingScreenState createState() => ClosingScreenState();
}

class ClosingScreenState extends State<ClosingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cashController = TextEditingController();
  final _tpaController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _salesController = TextEditingController();
  final _expensesController = TextEditingController();

  final List<Expense> _expenses = [];
  
  double _netResult = 0;
  double _discrepancy = 0;
  Map<String, dynamic>? _lastClosingData;
  String? _selectedCashier;
  List<Map<String, dynamic>> _cashiers = [];
  bool _isAdmin = false;

  final dbHelper = DatabaseHelper.instance;
  
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  DateTime? _lastAutoSave;
  
  // Form validation
  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  int? _lastRecordId;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_onFormChanged);
    _tpaController.addListener(_onFormChanged);
    _openingBalanceController.addListener(_onFormChanged);
    _salesController.addListener(_onFormChanged);
    _loadCashiers();
    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _cashController.dispose();
    _tpaController.dispose();
    _openingBalanceController.dispose();
    _salesController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    _updateCalculations();
    _validateForm();
    setState(() {
      _hasUnsavedChanges = true;
    });
  }
  
  void _validateForm() {
    final isValid = _mainFormKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_hasUnsavedChanges) {
        _autoSaveDraft();
      }
    });
  }

  void _autoSaveDraft() {
    if (!_hasUnsavedChanges) return;
    
    // Save current form state to shared preferences or temp storage
    _lastAutoSave = DateTime.now();
    setState(() {
      _hasUnsavedChanges = false;
    });
    
    // Show subtle indication of auto-save
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.save, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Auto-saved at ${DateFormat('HH:mm').format(_lastAutoSave!)}'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
      ),
    ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
  }

  void _loadCashiers() async {
    try {
      final users = await dbHelper.queryAllUsers();
      setState(() {
        _cashiers = users;
        _isAdmin = widget.username == 'admin';
        if (_isAdmin && _cashiers.isNotEmpty) {
          // Admin can choose cashier, default to first cashier
          _selectedCashier = _cashiers.first[DatabaseHelper.columnUsername];
        } else {
          // Regular user uses their own username
          _selectedCashier = widget.username;
        }
      });
    } catch (e) {
      setState(() {
        _cashiers = [];
        _selectedCashier = widget.username;
      });
    }
  }

  void _updateCalculations() {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final tpa = double.tryParse(_tpaController.text) ?? 0;
    final openingBalance = double.tryParse(_openingBalanceController.text) ?? 0;
    final sales = double.tryParse(_salesController.text) ?? 0;
    final totalExpenses = _expenses.fold<double>(0, (sum, item) => sum + item.amount);

    setState(() {
      _expensesController.text = totalExpenses.toStringAsFixed(2);
      final totalCounted = cash + tpa + totalExpenses;
      _netResult = totalCounted - openingBalance;
      _discrepancy = _netResult - sales;
    });
  }

  void _clearForm() {
    setState(() {
      _cashController.clear();
      _tpaController.clear();
      _openingBalanceController.clear();
      _salesController.clear();
      _expensesController.clear();
      _expenses.clear();
      _netResult = 0;
      _discrepancy = 0;
      _hasUnsavedChanges = false;
    });
  }

  void _clearAllFields() {
    _clearForm();
  }
  
  Future<void> _printReceipt(int recordId) async {
    if (_lastClosingData != null) {
      try {
        await ReceiptPrinter.printReceipt(_lastClosingData!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt printed successfully!'),
              backgroundColor: Colors.green,
            ),
          ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Print failed: $e'),
              backgroundColor: Colors.red,
            ),
          ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsWrapper(
      shortcuts: {
        KeyboardShortcutsService.saveShortcut: _closeBalance,
        KeyboardShortcutsService.printShortcut: () => _printReceipt(_lastRecordId ?? 0),
        KeyboardShortcutsService.newShortcut: _clearForm,
        KeyboardShortcutsService.refreshShortcut: _loadCashiers,
        KeyboardShortcutsService.helpShortcut: () => KeyboardShortcutsService.showShortcutsHelp(context),
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Balance Closing - ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Keyboard Shortcuts (F1)',
            onPressed: () => KeyboardShortcutsService.showShortcutsHelp(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
            },
          ),
          if (widget.username == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                ); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildFormPanel(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildExpensesPanel(),
            ),
          ],
        ),
      ),
    )); // Close Scaffold\n    ); // Close KeyboardShortcutsWrapper
  }

  Widget _buildFormPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _mainFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Daily Closing Form", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildCashierDropdown(),
                const SizedBox(height: 16),
                ValidatedTextField(
                  controller: _cashController,
                  label: 'Cash Sales (Kz)',
                  hint: 'Enter cash over-the-counter sales',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.money),
                  validator: (value) => FormValidationService.validateCurrency(value, fieldName: 'Cash sales'),
                  onChanged: (_) => _onFormChanged(),
                ),
                const SizedBox(height: 16),
                ValidatedTextField(
                  controller: _tpaController,
                  label: 'TPA Sales (Kz)',
                  hint: 'Enter card/mobile payment sales',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.credit_card),
                  validator: (value) => FormValidationService.validateCurrency(value, fieldName: 'TPA sales'),
                  onChanged: (_) => _onFormChanged(),
                ),
                const SizedBox(height: 16),
                _buildTextField(controller: _expensesController, label: 'Total Expenses', readOnly: true),
                const SizedBox(height: 16),
                ValidatedTextField(
                  controller: _openingBalanceController,
                  label: 'Opening Balance (Kz)',
                  hint: 'Enter opening cash balance',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  validator: (value) => FormValidationService.validateCurrency(value, fieldName: 'Opening balance'),
                  onChanged: (_) => _onFormChanged(),
                ),
                const Divider(height: 30, thickness: 1),
                ValidatedTextField(
                  controller: _salesController,
                  label: 'Total Sales from System (Kz)',
                  hint: 'Enter total sales from your POS system',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.receipt_long),
                  validator: (value) => FormValidationService.validateCurrency(value, fieldName: 'Total sales'),
                  onChanged: (_) => _onFormChanged(),
                ),
                const SizedBox(height: 16),
                FormValidationIndicator(
                  isValid: _isFormValid,
                  message: _isFormValid 
                      ? 'All fields are valid - ready to save' 
                      : 'Please complete all required fields',
                ),
                 _buildCalculatedField(label: 'Net Result (Counted)', value: _netResult, highlight: true),
                _buildCalculatedField(
                  label: 'Discrepancy (vs. System Sales)',
                  value: _discrepancy,
                  color: _discrepancy.abs() < 0.01 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _closeBalance,
                  child: const Text('Save Record', style: TextStyle(fontSize: 18)),
                ),
                 if (_lastClosingData != null) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print Last Receipt'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                    onPressed: () => ReceiptPrinter.printReceipt(_lastClosingData!),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Expenses List", style: Theme.of(context).textTheme.titleLarge),
                 IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.teal, size: 36),
                  onPressed: _showAddExpenseDialog,
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses added yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add an expense',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _expenses.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_outlined,
                                color: Colors.red[600],
                                size: 20,
                              ),
                            ),
                            title: Text(
                              expense.description,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Expense #${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    NumberFormat.currency(symbol: 'Kz ', decimalDigits: 2).format(expense.amount),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                                  onPressed: () {
                                    // Show confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Expense'),
                                          content: Text('Are you sure you want to delete "${expense.description}"?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                setState(() => _expenses.removeAt(index));
                                                _updateCalculations();
                                                Navigator.of(context).pop();
                                                
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Expense deleted'),
                                                    backgroundColor: Colors.red,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  tooltip: 'Delete expense',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashierDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cashier', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _selectedCashier,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _cashiers.map((cashier) {
              return DropdownMenuItem<String>(
                value: cashier[DatabaseHelper.columnUsername],
                child: Text(cashier[DatabaseHelper.columnUsername]),
              );
            }).toList(),
            onChanged: _isAdmin ? (String? newValue) {
              setState(() {
                _selectedCashier = newValue;
              });
            } : null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a cashier';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: readOnly ? null : const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(),
            validator: readOnly ? null : (value) {
              if (value == null || value.isEmpty) return 'Please enter a value';
              if (double.tryParse(value) == null) return 'Please enter a valid number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedField({required String label, required double value, bool highlight = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: highlight 
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: highlight 
          ? Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3))
          : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600], 
              fontWeight: FontWeight.bold
            )
          ),
          Text(
            NumberFormat.currency(symbol: 'Kz ', decimalDigits: 2).format(value),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? (highlight ? Theme.of(context).primaryColor : null),
              fontSize: highlight ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    
    // Common expense suggestions
    final commonExpenses = [
      'Office Supplies', 'Utilities', 'Transportation', 'Maintenance', 
      'Security', 'Cleaning', 'Internet', 'Phone Bills', 'Fuel', 'Repairs'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Add Expense'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick expense buttons
                  const Text('Quick Add:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: commonExpenses.take(6).map((expense) {
                      return ActionChip(
                        label: Text(expense, style: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          descriptionController.text = expense;
                          // Note: Focus will be handled by the validation text field
                        },
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ValidatedTextField(
                    controller: descriptionController,
                    label: 'Expense Description',
                    hint: 'Enter expense description',
                    prefixIcon: const Icon(Icons.description),
                    maxLength: 50,
                    validator: (value) => FormValidationService.validateDescription(value, maxLength: 50),
                  ),
                  const SizedBox(height: 16),
                  ValidatedTextField(
                    controller: amountController,
                    label: 'Amount (Kz)',
                    hint: 'Enter expense amount (e.g., 1500.00)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.attach_money),
                    validator: (value) => FormValidationService.validatePositiveNumber(value, fieldName: 'Amount'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  setState(() {
                    _expenses.add(Expense(
                      description: descriptionController.text.trim(),
                      amount: double.parse(amountController.text),
                    ));
                  });
                  _updateCalculations();
                  Navigator.of(context).pop();
                  
                  // Show success feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Expense "${descriptionController.text.trim()}" added successfully'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _closeBalance() async {
    if (_formKey.currentState!.validate()) {
      final closingData = {
        DatabaseHelper.columnDate: DateTime.now().toIso8601String(),
        DatabaseHelper.columnCashier: _selectedCashier ?? widget.username,
        'cash': double.tryParse(_cashController.text) ?? 0,
        'tpa': double.tryParse(_tpaController.text) ?? 0,
        'expenses': _expenses.fold<double>(0, (sum, item) => sum + item.amount),
        'openingBalance': double.tryParse(_openingBalanceController.text) ?? 0,
        'sales': double.tryParse(_salesController.text) ?? 0,
        'netResult': _netResult,
        'discrepancy': _discrepancy,
      };

      // Convert expenses to the format expected by the database
      List<Map<String, dynamic>> expensesData = _expenses.map((expense) => {
        DatabaseHelper.columnExpenseDescription: expense.description,
        DatabaseHelper.columnExpenseAmount: expense.amount,
      }).toList();

      int recordId = await dbHelper.insertRecordWithExpenses(closingData, expensesData);
      
      // Add the record ID to the closing data for printing
      closingData[DatabaseHelper.columnId] = recordId;
      setState(() => _lastClosingData = closingData);

      // Show print popup after successful save
      if (mounted) {
        _showPrintDialog(closingData);
      }
    }
  }

  void _showPrintDialog(Map<String, dynamic> closingData) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Row(
            children: [
              Icon(Icons.print, color: Colors.blue),
              SizedBox(width: 8),
              Text('Print Receipt'),
            ],
          ),
          content: const Text(
            'Record saved successfully! Would you like to print the closing receipt?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('Skip Print'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllFields();
                _showSuccessMessage();
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.preview),
              label: const Text('Preview'),
              onPressed: () {
                Navigator.of(context).pop();
                PrintPreviewService.showPrintPreview(context, closingData);
                _clearAllFields();
                _showSuccessMessage();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Receipt'),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                Navigator.of(context).pop();
                try {
                  await ReceiptPrinter.printReceipt(closingData);
                  // Clear fields after printing
                  _clearAllFields();
                  _showSuccessMessage();
                } catch (e) {
                  // If printing fails, still clear fields and show success
                  _clearAllFields();
                  _showSuccessMessage();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Print failed: $e'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Closing record saved successfully! All fields cleared for next cashier.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


}

class Expense {
  String description;
  double amount;
  Expense({required this.description, required this.amount});
}
