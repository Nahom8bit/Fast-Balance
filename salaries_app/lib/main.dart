import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salaries_app/admin_panel.dart';
import 'package:salaries_app/currency_formatter.dart';
import 'database_helper.dart';
import 'receipt_printer.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:salaries_app/settings_screen.dart';
import 'update_service.dart';
import 'update_dialog.dart';

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
  runApp(const BalanceClosingApp());
  
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

class BalanceClosingApp extends StatelessWidget {
  const BalanceClosingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Mercado - Balance Closing',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          elevation: 1.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16.0),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
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

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_updateCalculations);
    _tpaController.addListener(_updateCalculations);
    _openingBalanceController.addListener(_updateCalculations);
    _salesController.addListener(_updateCalculations);
    _loadCashiers();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _tpaController.dispose();
    _openingBalanceController.dispose();
    _salesController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  Future<void> _loadCashiers() async {
    final cashiers = await dbHelper.getCashiers();
    setState(() {
      _cashiers = cashiers;
      _isAdmin = widget.username == 'admin';
      
      // Auto-select current user if they're a cashier
      if (!_isAdmin) {
        _selectedCashier = widget.username;
      } else if (cashiers.isNotEmpty) {
        _selectedCashier = cashiers.first[DatabaseHelper.columnUsername];
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Closing - ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          if (widget.username == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                );
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
    );
  }

  Widget _buildFormPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Daily Closing Form", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildCashierDropdown(),
                const SizedBox(height: 16),
                _buildTextField(controller: _cashController, label: 'Cash'),
                _buildTextField(controller: _tpaController, label: 'TPA'),
                _buildTextField(controller: _expensesController, label: 'Expenses', readOnly: true),
                _buildTextField(controller: _openingBalanceController, label: 'Opening Balance'),
                const Divider(height: 30, thickness: 1),
                _buildTextField(controller: _salesController, label: 'Sales'),
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
                  ? const Center(child: Text('No expenses added.'))
                  : ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return ListTile(
                          title: Text(expense.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(NumberFormat.currency(symbol: '').format(expense.amount)),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                                onPressed: () {
                                  setState(() => _expenses.removeAt(index));
                                  _updateCalculations();
                                },
                              ),
                            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          Text(
            NumberFormat.currency(symbol: '').format(value),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? (highlight ? Theme.of(context).primaryColor : Colors.black87),
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Add Expense'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  setState(() {
                    _expenses.add(Expense(
                      description: descriptionController.text,
                      amount: double.parse(amountController.text),
                    ));
                  });
                  _updateCalculations();
                  Navigator.of(context).pop();
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

      await dbHelper.insertRecord(closingData);
      
      setState(() => _lastClosingData = closingData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Closing record saved successfully!')),
        );
      }
    }
  }
}

class Expense {
  String description;
  double amount;
  Expense({required this.description, required this.amount});
}
