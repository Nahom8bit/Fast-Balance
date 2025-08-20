import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../currency_formatter.dart';

enum ExportFormat { csv, pdf, excel, json }

class EnhancedExportService {
  static Future<void> showExportDialog(
    BuildContext context,
    List<Map<String, dynamic>> records,
  ) async {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(records: records),
    );
  }

  static Future<void> exportRecords(
    BuildContext context,
    List<Map<String, dynamic>> records,
    ExportFormat format, {
    String? fileName,
    String? directoryPath,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final defaultFileName = fileName ?? 'balance_records_$timestamp';
      
      String? selectedDirectory = directoryPath;
      if (selectedDirectory == null) {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory == null) return;
      }

      String finalFileName;
      File file;

      switch (format) {
        case ExportFormat.csv:
          finalFileName = '$defaultFileName.csv';
          file = File('$selectedDirectory/$finalFileName');
          await _exportToCsv(records, file);
          break;
        
        case ExportFormat.pdf:
          finalFileName = '$defaultFileName.pdf';
          file = File('$selectedDirectory/$finalFileName');
          await _exportToPdf(records, file);
          break;
        
        case ExportFormat.json:
          finalFileName = '$defaultFileName.json';
          file = File('$selectedDirectory/$finalFileName');
          await _exportToJson(records, file);
          break;
        
        case ExportFormat.excel:
          finalFileName = '$defaultFileName.xlsx';
          file = File('$selectedDirectory/$finalFileName');
          await _exportToExcel(records, file);
          break;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Exported ${records.length} records to: $finalFileName')),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open Folder',
              textColor: Colors.white,
              onPressed: () => _openDirectory(selectedDirectory!),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Export failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _exportToCsv(List<Map<String, dynamic>> records, File file) async {
    final csvData = [
      ['Date', 'Cashier', 'Opening Balance', 'Cash Sales', 'TPA Sales', 'Total Sales', 'Total Expenses', 'Net Result', 'Discrepancy', 'Status']
    ];

    for (var record in records) {
      final discrepancy = _calculateDiscrepancy(record);
      final status = _getDiscrepancyStatus(discrepancy);
      
      csvData.add([
        _formatDate(record[DatabaseHelper.columnDate]),
        record[DatabaseHelper.columnCashier] ?? '',
        (record[DatabaseHelper.columnOpeningBalance] ?? 0).toString(),
        (record[DatabaseHelper.columnCash] ?? 0).toString(),
        (record[DatabaseHelper.columnTpa] ?? 0).toString(),
        (record[DatabaseHelper.columnSales] ?? 0).toString(),
        (record[DatabaseHelper.columnExpenses] ?? 0).toString(),
        _calculateNetResult(record).toString(),
        discrepancy.toString(),
        status,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
  }

  static Future<void> _exportToPdf(List<Map<String, dynamic>> records, File file) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(),
            pw.SizedBox(height: 20),
            _buildPdfSummary(records),
            pw.SizedBox(height: 20),
            _buildPdfTable(records),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
  }

  static Future<void> _exportToJson(List<Map<String, dynamic>> records, File file) async {
    final exportData = {
      'export_info': {
        'generated_at': DateTime.now().toIso8601String(),
        'total_records': records.length,
        'format_version': '2.0',
        'exported_by': 'Mini Mercado Balance System',
      },
      'summary': _generateSummary(records),
      'records': records.map((record) => {
        'id': record[DatabaseHelper.columnId],
        'date': record[DatabaseHelper.columnDate],
        'cashier': record[DatabaseHelper.columnCashier],
        'financial_data': {
          'opening_balance': record[DatabaseHelper.columnOpeningBalance],
          'cash_sales': record[DatabaseHelper.columnCash],
          'tpa_sales': record[DatabaseHelper.columnTpa],
          'total_sales': record[DatabaseHelper.columnSales],
          'total_expenses': record[DatabaseHelper.columnExpenses],
          'net_result': _calculateNetResult(record),
          'discrepancy': _calculateDiscrepancy(record),
        },
        'status': _getDiscrepancyStatus(_calculateDiscrepancy(record)),
        'metadata': {
          'created_at': record[DatabaseHelper.columnDate],
          'record_type': 'balance_closing',
        }
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    await file.writeAsString(jsonString);
  }

  static Future<void> _exportToExcel(List<Map<String, dynamic>> records, File file) async {
    // For now, create a formatted CSV that can be opened in Excel
    // Note: Current implementation exports Excel-compatible CSV format.\n    // Future enhancement: Use 'excel' package for native .xlsx format
    final csvData = [
      ['Balance Closing Records - Excel Format'],
      ['Generated:', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())],
      ['Total Records:', records.length.toString()],
      [''], // Empty row
      ['Date', 'Cashier', 'Opening Balance (Kz)', 'Cash Sales (Kz)', 'TPA Sales (Kz)', 'Total Sales (Kz)', 'Total Expenses (Kz)', 'Net Result (Kz)', 'Discrepancy (Kz)', 'Status', 'Variance %']
    ];

    for (var record in records) {
      final discrepancy = _calculateDiscrepancy(record);
      final sales = record[DatabaseHelper.columnSales] ?? 0;
      final variancePercent = sales != 0 ? ((discrepancy / sales) * 100).toStringAsFixed(2) : '0.00';
      
      csvData.add([
        _formatDate(record[DatabaseHelper.columnDate]),
        record[DatabaseHelper.columnCashier] ?? '',
        (record[DatabaseHelper.columnOpeningBalance] ?? 0).toStringAsFixed(2),
        (record[DatabaseHelper.columnCash] ?? 0).toStringAsFixed(2),
        (record[DatabaseHelper.columnTpa] ?? 0).toStringAsFixed(2),
        (record[DatabaseHelper.columnSales] ?? 0).toStringAsFixed(2),
        (record[DatabaseHelper.columnExpenses] ?? 0).toStringAsFixed(2),
        _calculateNetResult(record).toStringAsFixed(2),
        discrepancy.toStringAsFixed(2),
        _getDiscrepancyStatus(discrepancy),
        '$variancePercent%',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
  }

  static pw.Widget _buildPdfHeader() {
    return pw.Column(
      children: [
        pw.Text(
          'MINI MERCADO BALANCE CLOSING RECORDS',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated: ${DateFormat('EEEE, MMMM d, yyyy \'at\' HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildPdfSummary(List<Map<String, dynamic>> records) {
    final summary = _generateSummary(records);
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Total Records: ${summary['total_records']}'),
                  pw.Text('Date Range: ${summary['date_range']}'),
                  pw.Text('Cashiers: ${summary['unique_cashiers']}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total Sales: ${CurrencyFormatter.format(summary['total_sales'])}'),
                  pw.Text('Total Expenses: ${CurrencyFormatter.format(summary['total_expenses'])}'),
                  pw.Text('Total Discrepancies: ${CurrencyFormatter.format(summary['total_discrepancies'])}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfTable(List<Map<String, dynamic>> records) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(2),
        7: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildPdfCell('Date', isHeader: true),
            _buildPdfCell('Cashier', isHeader: true),
            _buildPdfCell('Cash Sales', isHeader: true),
            _buildPdfCell('TPA Sales', isHeader: true),
            _buildPdfCell('Total Sales', isHeader: true),
            _buildPdfCell('Expenses', isHeader: true),
            _buildPdfCell('Discrepancy', isHeader: true),
            _buildPdfCell('Status', isHeader: true),
          ],
        ),
        ...records.map((record) {
          final discrepancy = _calculateDiscrepancy(record);
          return pw.TableRow(
            children: [
              _buildPdfCell(_formatDate(record[DatabaseHelper.columnDate])),
              _buildPdfCell(record[DatabaseHelper.columnCashier] ?? ''),
              _buildPdfCell(CurrencyFormatter.format(record[DatabaseHelper.columnCash] ?? 0)),
              _buildPdfCell(CurrencyFormatter.format(record[DatabaseHelper.columnTpa] ?? 0)),
              _buildPdfCell(CurrencyFormatter.format(record[DatabaseHelper.columnSales] ?? 0)),
              _buildPdfCell(CurrencyFormatter.format(record[DatabaseHelper.columnExpenses] ?? 0)),
              _buildPdfCell(
                CurrencyFormatter.format(discrepancy),
                textColor: discrepancy >= 0 ? PdfColors.green800 : PdfColors.red800,
              ),
              _buildPdfCell(
                _getDiscrepancyStatus(discrepancy),
                textColor: discrepancy >= 0 ? PdfColors.green800 : PdfColors.red800,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildPdfCell(String text, {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Map<String, dynamic> _generateSummary(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return {
        'total_records': 0,
        'date_range': 'No records',
        'unique_cashiers': 0,
        'total_sales': 0,
        'total_expenses': 0,
        'total_discrepancies': 0,
      };
    }

    final dates = records.map((r) => DateTime.parse(r[DatabaseHelper.columnDate])).toList();
    dates.sort();
    
    final cashiers = records.map((r) => r[DatabaseHelper.columnCashier]).toSet();
    
    return {
      'total_records': records.length,
      'date_range': '${_formatDate(dates.first.toIso8601String())} - ${_formatDate(dates.last.toIso8601String())}',
      'unique_cashiers': cashiers.length,
      'total_sales': records.fold<double>(0, (sum, r) => sum + (r[DatabaseHelper.columnSales] ?? 0)),
      'total_expenses': records.fold<double>(0, (sum, r) => sum + (r[DatabaseHelper.columnExpenses] ?? 0)),
      'total_discrepancies': records.fold<double>(0, (sum, r) => sum + _calculateDiscrepancy(r)),
    };
  }

  static double _calculateDiscrepancy(Map<String, dynamic> record) {
    final netResult = _calculateNetResult(record);
    final sales = record[DatabaseHelper.columnSales] ?? 0;
    return netResult - sales;
  }

  static double _calculateNetResult(Map<String, dynamic> record) {
    final cash = record[DatabaseHelper.columnCash] ?? 0;
    final tpa = record[DatabaseHelper.columnTpa] ?? 0;
    final expenses = record[DatabaseHelper.columnExpenses] ?? 0;
    final openingBalance = record[DatabaseHelper.columnOpeningBalance] ?? 0;
    
    return (cash + tpa + expenses) - openingBalance;
  }

  static String _getDiscrepancyStatus(double discrepancy) {
    if (discrepancy.abs() < 0.01) return 'Balanced';
    return discrepancy > 0 ? 'Surplus' : 'Shortage';
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static void _openDirectory(String path) {
    // TODO: Implement directory opening for different platforms
    // For now, just print the path
    // ignore: avoid_print\n    print('Opening directory: $path');
  }
}

class ExportDialog extends StatefulWidget {
  final List<Map<String, dynamic>> records;

  const ExportDialog({super.key, required this.records});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  final TextEditingController _fileNameController = TextEditingController();
  bool _includeMetadata = true;
  bool _includeSummary = true;

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'balance_records_${DateFormat('yyyy_MM_dd').format(DateTime.now())}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text('Export Records'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${widget.records.length} records',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            
            const Text('Export Format:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ExportFormat.values.map((format) => RadioListTile<ExportFormat>(
              title: Text(_getFormatTitle(format)),
              subtitle: Text(_getFormatDescription(format)),
              value: format,
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            )),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter file name (without extension)',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Include Summary'),
              subtitle: const Text('Add summary statistics to export'),
              value: _includeSummary,
              onChanged: (value) {
                setState(() {
                  _includeSummary = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Include Metadata'),
              subtitle: const Text('Add generation info and timestamps'),
              value: _includeMetadata,
              onChanged: (value) {
                setState(() {
                  _includeMetadata = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }

  String _getFormatTitle(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'CSV (Spreadsheet)';
      case ExportFormat.pdf:
        return 'PDF (Document)';
      case ExportFormat.excel:
        return 'Excel (XLSX)';
      case ExportFormat.json:
        return 'JSON (Data)';
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Comma-separated values for spreadsheet apps';
      case ExportFormat.pdf:
        return 'Formatted document with tables and summary';
      case ExportFormat.excel:
        return 'Microsoft Excel compatible format';
      case ExportFormat.json:
        return 'Structured data format for developers';
    }
  }

  void _export() {
    if (_fileNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a file name')),
      );
      return;
    }

    Navigator.of(context).pop();
    EnhancedExportService.exportRecords(
      context,
      widget.records,
      _selectedFormat,
      fileName: _fileNameController.text.trim(),
    );
  }
}
