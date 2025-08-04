import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../currency_formatter.dart';
import '../database_helper.dart';

/// Transaction table widget for displaying transaction details
class TransactionTable extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  final TextEditingController searchController;
  final int maxDisplayRecords;

  const TransactionTable({
    super.key,
    required this.records,
    required this.searchController,
    this.maxDisplayRecords = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.grid_on,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 300,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final displayRecords = records.take(maxDisplayRecords).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          _buildDataColumn('Date', context),
          _buildDataColumn('Cashier', context),
          _buildDataColumn('Cash Amount', context),
          _buildDataColumn('TPA Amount', context),
          _buildDataColumn('Total', context),
          _buildDataColumn('Discrepancy', context),
          _buildDataColumn('Status', context),
        ],
        rows: displayRecords.map((record) {
          return _buildDataRow(record, context);
        }).toList(),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, BuildContext context) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> record, BuildContext context) {
    final date = DateTime.parse(record[DatabaseHelper.columnDate]);
    final cashier = record[DatabaseHelper.columnCashier] as String? ?? 'Unknown';
    final cash = record[DatabaseHelper.columnCash] as double;
    final tpa = record[DatabaseHelper.columnTpa] as double;
    final total = cash + tpa;
    final discrepancy = record[DatabaseHelper.columnDiscrepancy] as double;

    return DataRow(
      cells: [
        DataCell(
          Text(
            DateFormat('MM/dd/yyyy').format(date),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DataCell(
          Text(
            cashier,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DataCell(
          Text(
            CurrencyFormatter.format(cash),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DataCell(
          Text(
            CurrencyFormatter.format(tpa),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DataCell(
          Text(
            CurrencyFormatter.format(total),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DataCell(
          Text(
            '${discrepancy >= 0 ? '+' : ''}${CurrencyFormatter.format(discrepancy)}',
            style: TextStyle(
              color: discrepancy >= 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
        ),
        DataCell(_buildStatusChip('COMPLETED')),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'COMPLETED':
        color = const Color(0xFF10B981);
        break;
      case 'PENDING':
        color = const Color(0xFFF59E0B);
        break;
      case 'CANCELLED':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Transaction table with loading state
class TransactionTableLoading extends StatelessWidget {
  const TransactionTableLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction table with error state
class TransactionTableError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const TransactionTableError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grid_on,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load transaction data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 