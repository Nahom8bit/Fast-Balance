import 'package:flutter/material.dart';
import 'database_helper.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _closingRecords;

  @override
  void initState() {
    super.initState();
    _closingRecords = dbHelper.queryAllRows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - All Records'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                final status = record[DatabaseHelper.columnStatus];
                Color statusColor;
                if (status == 'Balanced') {
                  statusColor = Colors.green;
                } else if (status == 'Excess') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      'Record ID: ${record[DatabaseHelper.columnId]} - ${record[DatabaseHelper.columnStatus]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${DateTime.parse(record[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)}'),
                        Text('Difference: L.K.R ${record[DatabaseHelper.columnDifference].toStringAsFixed(2)}'),
                      ],
                    ),
                    onTap: () {
                      // Optional: Show a detailed view of the record
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
