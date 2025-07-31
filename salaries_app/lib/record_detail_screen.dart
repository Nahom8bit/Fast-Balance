import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class RecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Details (ID: ${record[DatabaseHelper.columnId]})'),
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
                _buildDetailRow('Date:', DateTime.parse(record[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)),
                 const Divider(height: 24),
                _buildDetailRow('Cash:', record[DatabaseHelper.columnCash]),
                _buildDetailRow('TPA:', record[DatabaseHelper.columnTpa]),
                _buildDetailRow('Expenses:', record[DatabaseHelper.columnExpenses]),
                _buildDetailRow('Opening Balance:', record[DatabaseHelper.columnOpeningBalance]),
                 const Divider(height: 24),
                _buildDetailRow('Sales:', record[DatabaseHelper.columnSales]),
                _buildDetailRow('Net Result (Counted):', record[DatabaseHelper.columnNetResult], isBold: true),
                _buildDetailRow(
                  'Discrepancy (vs. System Sales):',
                  record[DatabaseHelper.columnDiscrepancy],
                  isBold: true,
                  color: (record[DatabaseHelper.columnDiscrepancy] as double).abs() < 0.01 ? Colors.green : Colors.red,
                ),
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
