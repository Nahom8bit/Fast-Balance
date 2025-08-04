import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Dashboard header widget with date pickers and period selection
class DashboardHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String selectedPeriod;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(String) onPeriodChanged;

  const DashboardHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedPeriod,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).appBarTheme.foregroundColor,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.store,
              color: Theme.of(context).appBarTheme.foregroundColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Mini Mercado - KPI Dashboard',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _buildDatePicker(
              context,
              'Start Date',
              startDate,
              onStartDateChanged,
            ),
            const SizedBox(width: 16),
            _buildDatePicker(
              context,
              'End Date',
              endDate,
              onEndDateChanged,
            ),
            const SizedBox(width: 16),
            _buildPeriodDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd-MM-yyyy').format(date),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.grey,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedPeriod,
        underline: Container(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
        items: ['This Month', 'Last Month', 'This Quarter', 'This Year']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onPeriodChanged(newValue);
          }
        },
      ),
    );
  }
} 