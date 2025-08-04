import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class RecordDetailScreen extends StatefulWidget {
  final Map<String, dynamic> record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = dbHelper.getExpensesForRecord(widget.record[DatabaseHelper.columnId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Details (ID: ${widget.record[DatabaseHelper.columnId]})'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
           child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Closing Details", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildDetailRow('Date:', DateTime.parse(widget.record[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)),
                _buildDetailRow('Cashier:', widget.record[DatabaseHelper.columnCashier]),
                 const Divider(height: 24),
                _buildDetailRow('Cash:', widget.record[DatabaseHelper.columnCash]),
                _buildDetailRow('TPA:', widget.record[DatabaseHelper.columnTpa]),
                _buildDetailRow('Opening Balance:', widget.record[DatabaseHelper.columnOpeningBalance]),
                 const Divider(height: 24),
                _buildDetailRow('Sales:', widget.record[DatabaseHelper.columnSales]),
                _buildDetailRow('Net Result (Counted):', widget.record[DatabaseHelper.columnNetResult], isBold: true),
                _buildDetailRow(
                  'Discrepancy (vs. System Sales):',
                  widget.record[DatabaseHelper.columnDiscrepancy],
                  isBold: true,
                  color: (widget.record[DatabaseHelper.columnDiscrepancy] as double).abs() < 0.01 ? Colors.green : Colors.red,
                ),
                const Divider(height: 24),
                Text("Expenses", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error loading expenses: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No expenses recorded.');
                    } else {
                      final expenses = snapshot.data!;
                      return Column(
                        children: expenses.map((expense) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    expense[DatabaseHelper.columnExpenseDescription],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(symbol: '').format(expense[DatabaseHelper.columnExpenseAmount]),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      );
                    }
                  },
                ),
                const Divider(height: 24),
                _buildDetailRow('Total Expenses:', widget.record[DatabaseHelper.columnExpenses], isBold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            value is double ? NumberFormat.currency(symbol: '').format(value) : value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
