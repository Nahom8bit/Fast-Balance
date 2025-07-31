import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _recordsFuture;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'This Month';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() {
    setState(() {
      _recordsFuture = dbHelper.queryRecordsByDateRange(
        _startDate,
        _endDate.add(const Duration(days: 1)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available for the selected range.'));
                } else {
                  return _buildDashboardContent(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 8),
            const Icon(Icons.store, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Mini Mercado - KPI Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            _buildDatePicker('Start Date', _startDate, (date) {
              setState(() {
                _startDate = date;
              });
              _fetchRecords();
            }),
            const SizedBox(width: 16),
            _buildDatePicker('End Date', _endDate, (date) {
              setState(() {
                _endDate = date;
              });
              _fetchRecords();
            }),
            const SizedBox(width: 16),
            _buildPeriodDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1E3A8A), size: 16),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd-MM-yyyy').format(date),
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        underline: Container(),
        style: const TextStyle(
          color: Color(0xFF1E3A8A),
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
            setState(() {
              _selectedPeriod = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(List<Map<String, dynamic>> records) {
    final kpis = _calculateKPIs(records);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPICards(kpis),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSalesTrendChart(records),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildDiscrepanciesByCashier(records),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTransactionDetailsTable(records),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateKPIs(List<Map<String, dynamic>> records) {
    double totalCash = records.map((r) => r[DatabaseHelper.columnCash] as double).fold(0.0, (a, b) => a + b);
    double totalTpa = records.map((r) => r[DatabaseHelper.columnTpa] as double).fold(0.0, (a, b) => a + b);
    double totalExpenses = records.map((r) => r[DatabaseHelper.columnExpenses] as double).fold(0.0, (a, b) => a + b);
    double totalDiscrepancies = records.map((r) => r[DatabaseHelper.columnDiscrepancy] as double).fold(0.0, (a, b) => a + b);

    // Calculate percentage changes (simplified - you can implement actual comparison)
    double cashChange = records.isNotEmpty ? 5.2 : 0.0;
    double tpaChange = records.isNotEmpty ? 3.7 : 0.0;
    double expensesChange = records.isNotEmpty ? 2.1 : 0.0;
    double discrepanciesChange = records.isNotEmpty ? -12.3 : 0.0;

    return {
      'cash': totalCash,
      'tpa': totalTpa,
      'expenses': totalExpenses,
      'discrepancies': totalDiscrepancies,
      'cashChange': cashChange,
      'tpaChange': tpaChange,
      'expensesChange': expensesChange,
      'discrepanciesChange': discrepanciesChange,
    };
  }

  Widget _buildKPICards(Map<String, dynamic> kpis) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildKPICard('Cash', kpis['cash'], kpis['cashChange'], Icons.shopping_bag, const Color(0xFF10B981)),
        _buildKPICard('TPA (POS)', kpis['tpa'], kpis['tpaChange'], Icons.credit_card, const Color(0xFF3B82F6)),
        _buildKPICard('Expenses', kpis['expenses'], kpis['expensesChange'], Icons.receipt_long, const Color(0xFFEF4444)),
        _buildKPICard('Discrepancies', kpis['discrepancies'], kpis['discrepanciesChange'], Icons.warning, const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildKPICard(String title, double value, double change, IconData icon, Color color) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(value),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: changeColor,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    '${change.abs().toStringAsFixed(1)}% from last period',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildSalesTrendChart(List<Map<String, dynamic>> records) {
    records.sort((a, b) => DateTime.parse(a[DatabaseHelper.columnDate]).compareTo(DateTime.parse(b[DatabaseHelper.columnDate])));
    
    final cashSpots = records.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value[DatabaseHelper.columnCash]);
    }).toList();

    final tpaSpots = records.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value[DatabaseHelper.columnTpa]);
    }).toList();

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
                const Icon(Icons.trending_up, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                const Text(
                  'Sales Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButton<String>(
                    value: 'Weekly',
                    underline: Container(),
                    style: const TextStyle(fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    ],
                    onChanged: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: records.isNotEmpty ? LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < records.length) {
                            final date = DateTime.parse(records[value.toInt()][DatabaseHelper.columnDate]);
                            return Text(
                              DateFormat('MMM d').format(date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            );
                          }
                          return Container();
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          );
                        },
                        interval: 500,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: cashSpots,
                      isCurved: true,
                      color: const Color(0xFF10B981),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: tpaSpots,
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ) : const Center(child: Text('No data available for chart')),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Cash', const Color(0xFF10B981)),
                const SizedBox(width: 24),
                _buildLegendItem('TPA (POS)', const Color(0xFF3B82F6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscrepanciesByCashier(List<Map<String, dynamic>> records) {
    // Calculate discrepancies by cashier from actual records
    final Map<String, double> cashierDiscrepancies = {};
    
    for (final record in records) {
      final cashier = record[DatabaseHelper.columnCashier] as String? ?? 'Unknown';
      final discrepancy = record[DatabaseHelper.columnDiscrepancy] as double;
      
      if (cashierDiscrepancies.containsKey(cashier)) {
        cashierDiscrepancies[cashier] = cashierDiscrepancies[cashier]! + discrepancy;
      } else {
        cashierDiscrepancies[cashier] = discrepancy;
      }
    }
    
    final cashiers = cashierDiscrepancies.entries.map((entry) => {
      'name': entry.key,
      'discrepancy': entry.value,
    }).toList();

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
                const Icon(Icons.list, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                const Text(
                  'Discrepancies by Cashier',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...cashiers.map((cashier) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                                         child: Text(
                       cashier['name'] as String,
                       style: const TextStyle(
                         fontSize: 14,
                         color: Color(0xFF1E293B),
                       ),
                     ),
                  ),
                                     Text(
                     '${(cashier['discrepancy'] as double) >= 0 ? '+' : ''}${CurrencyFormatter.format(cashier['discrepancy'] as double)}',
                     style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: (cashier['discrepancy'] as double) >= 0 
                           ? const Color(0xFFEF4444) 
                           : const Color(0xFF10B981),
                     ),
                   ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailsTable(List<Map<String, dynamic>> records) {
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
                const Icon(Icons.grid_on, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Cashier')),
                  DataColumn(label: Text('Cash Amount')),
                  DataColumn(label: Text('TPA Amount')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Discrepancy')),
                  DataColumn(label: Text('Status')),
                ],
                                 rows: records.take(10).map((record) {
                   final date = DateTime.parse(record[DatabaseHelper.columnDate]);
                   final cashier = record[DatabaseHelper.columnCashier] as String? ?? 'Unknown';
                   final cash = record[DatabaseHelper.columnCash] as double;
                   final tpa = record[DatabaseHelper.columnTpa] as double;
                   final total = cash + tpa;
                   final discrepancy = record[DatabaseHelper.columnDiscrepancy] as double;
                   
                   return DataRow(
                     cells: [
                       DataCell(Text(DateFormat('MM/dd/yyyy').format(date))),
                       DataCell(Text(cashier)),
                       DataCell(Text(CurrencyFormatter.format(cash))),
                       DataCell(Text(CurrencyFormatter.format(tpa))),
                       DataCell(Text(CurrencyFormatter.format(total))),
                       DataCell(Text(
                         '${discrepancy >= 0 ? '+' : ''}${CurrencyFormatter.format(discrepancy)}',
                         style: TextStyle(
                           color: discrepancy >= 0 
                               ? const Color(0xFFEF4444) 
                               : const Color(0xFF10B981),
                         ),
                       )),
                       DataCell(_buildStatusChip('COMPLETED')),
                     ],
                   );
                 }).toList(),
              ),
            ),
          ],
        ),
      ),
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