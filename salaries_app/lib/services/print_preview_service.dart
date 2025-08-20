import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../currency_formatter.dart';

class PrintPreviewService {
  static void showPrintPreview(BuildContext context, Map<String, dynamic> closingData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrintPreviewScreen(closingData: closingData),
      ),
    );
  }
}

class PrintPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> closingData;

  const PrintPreviewScreen({super.key, required this.closingData});

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  bool _useCompactLayout = false;
  bool _includeLogo = false;
  bool _showHeader = true;
  bool _showFooter = true;
  int _copies = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Preview'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPrintSettings,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printDocument,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildPrintToolbar(),
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(format),
              initialPageFormat: _pageFormat,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
              canDebug: false,
              maxPageWidth: 800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPageFormatSelector(),
          const SizedBox(width: 16),
          _buildCopiesSelector(),
          const Spacer(),
          _buildLayoutToggle(),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _printDocument,
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFormatSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<PdfPageFormat>(
        value: _pageFormat,
        underline: Container(),
        items: [
          DropdownMenuItem(
            value: PdfPageFormat.a4,
            child: const Text('A4'),
          ),
          DropdownMenuItem(
            value: PdfPageFormat.letter,
            child: const Text('Letter'),
          ),
          DropdownMenuItem(
            value: PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm),
            child: const Text('Receipt (80mm)'),
          ),
        ],
        onChanged: (format) {
          if (format != null) {
            setState(() {
              _pageFormat = format;
            });
          }
        },
      ),
    );
  }

  Widget _buildCopiesSelector() {
    return Row(
      children: [
        const Text('Copies:'),
        const SizedBox(width: 8),
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: _copies,
            underline: Container(),
            items: List.generate(5, (index) => index + 1)
                .map((copies) => DropdownMenuItem(
                      value: copies,
                      child: Text(copies.toString()),
                    ))
                .toList(),
            onChanged: (copies) {
              if (copies != null) {
                setState(() {
                  _copies = copies;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutToggle() {
    return Row(
      children: [
        const Text('Layout:'),
        const SizedBox(width: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Standard')),
            ButtonSegment(value: true, label: Text('Compact')),
          ],
          selected: {_useCompactLayout},
          onSelectionChanged: (Set<bool> selection) {
            setState(() {
              _useCompactLayout = selection.first;
            });
          },
        ),
      ],
    );
  }

  void _showPrintSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Settings'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Include Business Logo'),
                value: _includeLogo,
                onChanged: (value) {
                  setDialogState(() {
                    _includeLogo = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Show Header'),
                value: _showHeader,
                onChanged: (value) {
                  setDialogState(() {
                    _showHeader = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Show Footer'),
                value: _showFooter,
                onChanged: (value) {
                  setDialogState(() {
                    _showFooter = value;
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _printDocument() async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => _generatePdf(format),
        format: _pageFormat,
        name: 'Balance_Closing_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Document sent to printer successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Print failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    // Extract data
    final data = widget.closingData;
    final expenses = data['expenses'] as List<Map<String, dynamic>>? ?? [];
    
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: _useCompactLayout 
            ? const pw.EdgeInsets.all(20)
            : const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (_showHeader) ...[
                _buildPdfHeader(),
                pw.SizedBox(height: _useCompactLayout ? 10 : 20),
              ],
              _buildPdfContent(data, expenses),
              if (_showFooter) ...[
                pw.Spacer(),
                _buildPdfFooter(),
              ],
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  pw.Widget _buildPdfHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'MINI MERCADO BALANCE CLOSING',
          style: pw.TextStyle(
            fontSize: _useCompactLayout ? 16 : 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: _useCompactLayout ? 5 : 10),
        pw.Text(
          'Closing Report',
          style: pw.TextStyle(fontSize: _useCompactLayout ? 12 : 14),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildPdfContent(Map<String, dynamic> data, List<Map<String, dynamic>> expenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Basic Information
        _buildPdfInfoSection(data),
        pw.SizedBox(height: _useCompactLayout ? 10 : 15),
        
        // Financial Summary
        _buildPdfFinancialSection(data),
        pw.SizedBox(height: _useCompactLayout ? 10 : 15),
        
        // Expenses List
        if (expenses.isNotEmpty) ...[
          _buildPdfExpensesSection(expenses),
          pw.SizedBox(height: _useCompactLayout ? 10 : 15),
        ],
        
        // Calculations
        _buildPdfCalculationsSection(data),
      ],
    );
  }

  pw.Widget _buildPdfInfoSection(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CASHIER INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cashier: ${data['cashier'] ?? 'N/A'}'),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(data['date']))}'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFinancialSection(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfTableRow('Opening Balance', data['openingBalance']),
              _buildPdfTableRow('Cash Sales', data['cash']),
              _buildPdfTableRow('TPA Sales', data['tpa']),
              _buildPdfTableRow('Total Sales', data['sales']),
              _buildPdfTableRow('Total Expenses', data['expenses']),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfExpensesSection(List<Map<String, dynamic>> expenses) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EXPENSE DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...expenses.map((expense) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(expense['description'] ?? ''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(CurrencyFormatter.format(expense['amount'] ?? 0)),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCalculationsSection(Map<String, dynamic> data) {
    final discrepancy = data['discrepancy'] ?? 0.0;
    final isPositive = discrepancy >= 0;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BALANCE CALCULATIONS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfTableRow('Expected Amount', data['netResult']),
              _buildPdfTableRow('Actual Sales', data['sales']),
              pw.TableRow(
                decoration: isPositive ? const pw.BoxDecoration(color: PdfColors.green100) : const pw.BoxDecoration(color: PdfColors.red100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Discrepancy', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '${isPositive ? '+' : ''}${CurrencyFormatter.format(discrepancy)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            isPositive ? 'SURPLUS: Account shows more money than expected' : 'SHORTAGE: Account shows less money than expected',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: _useCompactLayout ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildPdfTableRow(String label, dynamic value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(CurrencyFormatter.format(value ?? 0)),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
            pw.Text('Mini Mercado Balance System v2.0'),
          ],
        ),
      ],
    );
  }
}
