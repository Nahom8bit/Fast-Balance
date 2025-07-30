import 'package:flutter/material.dart';
import 'package:salaries_app/admin_panel.dart';
import 'database_helper.dart';
import 'receipt_printer.dart';
import 'login_screen.dart';

void main() {
  runApp(const BalanceClosingApp());
}

class BalanceClosingApp extends StatelessWidget {
  const BalanceClosingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balance Closing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}

class ClosingScreen extends StatefulWidget {
  final String username;
  const ClosingScreen({super.key, required this.username});

  @override
  _ClosingScreenState createState() => _ClosingScreenState();
}

class _ClosingScreenState extends State<ClosingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _openingBalanceController = TextEditingController();
  final _cashSalesController = TextEditingController();
  final _tpaSalesController = TextEditingController();
  final _totalSalesController = TextEditingController();
  final _cashOnHandController = TextEditingController();

  // List to hold expense entries
  final List<Expense> _expenses = [];

  // State variables for results
  double? _expectedCash;
  double? _actualCash;
  double? _difference;
  String? _status;
  Map<String, dynamic>? _lastClosingData;

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Closing - ${widget.username}'),
        actions: [
          if (widget.username == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(controller: _openingBalanceController, label: 'Opening Balance'),
              _buildTextField(controller: _cashSalesController, label: 'Cash Sales (Over the Counter)'),
              _buildTextField(controller: _tpaSalesController, label: 'TPA (POS) Sales'),
              _buildTextField(controller: _totalSalesController, label: 'Total Sales (from system)'),
              const SizedBox(height: 20),
              _buildExpenseSection(),
              const SizedBox(height: 20),
              _buildTextField(controller: _cashOnHandController, label: 'Cash on Hand (at close)'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _closeBalance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close Balance', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExpenseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Expenses / Petty Cash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: _showAddExpenseDialog,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _expenses.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(_expenses[index].description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('L.K.R ${_expenses[index].amount.toStringAsFixed(2)}'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExpense(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_expenses.isEmpty)
          const Center(child: Text('No expenses added yet.')),
      ],
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
          title: const Text('Add Expense'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  final newExpense = Expense(
                    description: descriptionController.text,
                    amount: double.parse(amountController.text),
                  );
                  setState(() {
                    _expenses.add(newExpense);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _closeBalance() async {
    if (_formKey.currentState!.validate()) {
      final openingBalance = double.parse(_openingBalanceController.text);
      final cashSales = double.parse(_cashSalesController.text);
      final tpaSales = double.parse(_tpaSalesController.text);
      final totalSales = double.parse(_totalSalesController.text);
      final cashOnHand = double.parse(_cashOnHandController.text);

      final totalExpenses = _expenses.fold<double>(0, (sum, item) => sum + item.amount);

      final expectedCash = openingBalance + cashSales - totalExpenses;
      final difference = cashOnHand - expectedCash;

      String status;
      if (difference.abs() < 0.01) {
        status = 'Balanced';
      } else if (difference > 0) {
        status = 'Excess';
      } else {
        status = 'Shortage';
      }

      final closingData = {
        DatabaseHelper.columnDate: DateTime.now().toIso8601String(),
        DatabaseHelper.columnOpeningBalance: openingBalance,
        DatabaseHelper.columnCashSales: cashSales,
        DatabaseHelper.columnTpaSales: tpaSales,
        DatabaseHelper.columnTotalSales: totalSales,
        DatabaseHelper.columnTotalExpenses: totalExpenses,
        DatabaseHelper.columnCashOnHand: cashOnHand,
        DatabaseHelper.columnExpectedCash: expectedCash,
        DatabaseHelper.columnDifference: difference,
        DatabaseHelper.columnStatus: status,
      };

      setState(() {
        _expectedCash = expectedCash;
        _actualCash = cashOnHand;
        _difference = difference;
        _status = status;
        _lastClosingData = closingData;
      });

      // Save to database
      final id = await dbHelper.insert(closingData);
      print('inserted row id: $id');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Closing record saved successfully!')),
      );
    }
  }

  Widget _buildResultsSection() {
    if (_status == null) {
      return Container(); // Don't show anything until a calculation is made
    }

    Color statusColor;
    if (_status == 'Balanced') {
      statusColor = Colors.green;
    } else if (_status == 'Excess') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Calculation Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildResultRow('Expected Cash:', 'L.K.R ${_expectedCash?.toStringAsFixed(2)}'),
            _buildResultRow('Actual Cash:', 'L.K.R ${_actualCash?.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _buildResultRow(
              'Difference:',
              'L.K.R ${_difference?.toStringAsFixed(2)}',
              valueStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            _buildResultRow(
              'Status:',
              _status!,
              valueStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Receipt'),
              onPressed: () {
                if (_lastClosingData != null) {
                  ReceiptPrinter.printReceipt(_lastClosingData!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: valueStyle ?? const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class Expense {
  String description;
  double amount;

  Expense({required this.description, required this.amount});
}
