import 'package:flutter/material.dart';
import 'package:salaries_app/record_detail_screen.dart';
import 'package:salaries_app/dashboard_screen.dart';
import 'package:salaries_app/user_management_screen.dart';
import 'database_helper.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _closingRecords;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _closingRecords = dbHelper.queryAllRecords();
  }

  void _filterRecords() {
    setState(() {
      _closingRecords = dbHelper.queryRecordsByDateRange(_startDate, _endDate);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _filterRecords();
    }
  }

  Future<void> _exportToCsv() async {
    final records = await _closingRecords;
    if (records.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records to export.')),
        );
      }
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(records.first.keys.toList());
    for (var record in records) {
      rows.add(record.values.toList());
    }

    String csv = const ListToCsvConverter().convert(rows);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV File',
      fileName: 'closing_records_${DateTime.now().toShortDateString()}.csv',
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to $outputFile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - All Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _closingRecords,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No closing records found.'));
                } else {
                  final records = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Record ID: ${record[DatabaseHelper.columnId]}'),
                          subtitle: Text('Date: ${DateTime.parse(record[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RecordDetailScreen(record: record),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_startDate == null ? 'Start Date' : "${_startDate!.toLocal()}".split(' ')[0]),
            onPressed: () => _selectDate(context, true),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(_endDate == null ? 'End Date' : "${_endDate!.toLocal()}".split(' ')[0]),
            onPressed: () => _selectDate(context, false),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _closingRecords = dbHelper.queryAllRecords();
              });
            },
          )
        ],
      ),
    );
  }
}

extension on DateTime {
  String toShortDateString() {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }
}
