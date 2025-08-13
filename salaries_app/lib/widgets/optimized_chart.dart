import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';

/// Optimized chart widget with better performance and error handling
class OptimizedChart extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  final String title;
  final int maxDataPoints;
  final bool showLegend;

  const OptimizedChart({
    super.key,
    required this.records,
    required this.title,
    this.maxDataPoints = 50,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyChart(context);
    }

    final optimizedData = _optimizeData(records);
    final chartData = _prepareChartData(optimizedData);

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
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: _calculateMaxY(chartData),
                  gridData: _buildGridData(context),
                  titlesData: _buildTitlesData(context, optimizedData),
                  borderData: FlBorderData(show: false),
                  lineBarsData: _buildLineBarsData(chartData),
                ),
              ),
            ),
            if (showLegend) ...[
              const SizedBox(height: 16),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
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
                Icon(Icons.trending_up, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No data available for chart',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.trending_up, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey),
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
    );
  }

  List<Map<String, dynamic>> _optimizeData(List<Map<String, dynamic>> records) {
    if (records.length <= maxDataPoints) {
      return records;
    }

    // Sort records by date
    final sortedRecords = List<Map<String, dynamic>>.from(records);
    sortedRecords.sort((a, b) => DateTime.parse(a[DatabaseHelper.columnDate])
        .compareTo(DateTime.parse(b[DatabaseHelper.columnDate])));

    // Sample data points evenly
    final step = (sortedRecords.length / maxDataPoints).ceil();
    final optimizedRecords = <Map<String, dynamic>>[];
    
    for (int i = 0; i < sortedRecords.length; i += step) {
      optimizedRecords.add(sortedRecords[i]);
    }

    return optimizedRecords;
  }

  Map<String, List<FlSpot>> _prepareChartData(List<Map<String, dynamic>> records) {
    final cashSpots = <FlSpot>[];
    final tpaSpots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      cashSpots.add(FlSpot(i.toDouble(), record[DatabaseHelper.columnCash] as double));
      tpaSpots.add(FlSpot(i.toDouble(), record[DatabaseHelper.columnTpa] as double));
    }

    return {
      'cash': cashSpots,
      'tpa': tpaSpots,
    };
  }

  double _calculateMaxY(Map<String, List<FlSpot>> chartData) {
    double maxValue = 0;
    
    for (final spots in chartData.values) {
      for (final spot in spots) {
        if (spot.y > maxValue) {
          maxValue = spot.y;
        }
      }
    }

    // Add 10% padding and round to nearest interval
    maxValue = maxValue * 1.1;
    return _calculateInterval(maxValue);
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 0) return 1000;
    
    if (maxValue < 1000) {
      return 100;
    } else if (maxValue < 5000) {
      return 500;
    } else if (maxValue < 10000) {
      return 1000;
    } else if (maxValue < 50000) {
      return 5000;
    } else if (maxValue < 100000) {
      return 10000;
    } else {
      return 25000;
    }
  }

  FlGridData _buildGridData(BuildContext context) {
    return FlGridData(
      show: true,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
        strokeWidth: 1,
      ),
      drawVerticalLine: false,
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context, List<Map<String, dynamic>> records) {
    return FlTitlesData(
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
              'Kz${value.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            );
          },
                     interval: 1000, // Default interval, will be calculated dynamically
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData(Map<String, List<FlSpot>> chartData) {
    return [
      LineChartBarData(
        spots: chartData['cash']!,
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
        spots: chartData['tpa']!,
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
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Cash', const Color(0xFF10B981)),
        const SizedBox(width: 24),
        _buildLegendItem('TPA (POS)', const Color(0xFF3B82F6)),
      ],
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
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 