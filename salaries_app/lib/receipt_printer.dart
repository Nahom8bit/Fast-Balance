import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'settings_service.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(Map<String, dynamic> closingData) async {
    final doc = pw.Document();
    final dbHelper = DatabaseHelper.instance;
    final settingsService = SettingsService();

    // Get the detailed expenses list for this record
    List<Map<String, dynamic>> expensesList = [];
    if (closingData[DatabaseHelper.columnId] != null) {
      expensesList = await dbHelper.getExpensesForRecord(closingData[DatabaseHelper.columnId]);
    }

    // Get settings for customization
    // final businessName = await settingsService.getBusinessName();
    final businessAddress = await settingsService.getBusinessAddress();
    final businessPhone = await settingsService.getBusinessPhone();
    final businessEmail = await settingsService.getBusinessEmail();
    final businessWebsite = await settingsService.getBusinessWebsite();
    final businessTaxId = await settingsService.getBusinessTaxId();
    final receiptHeader = await settingsService.getReceiptHeader();
    final receiptFooter = await settingsService.getReceiptFooter();
    final reportTitle = await settingsService.getReportTitle();
    // final currencySymbol = await settingsService.getCurrencySymbol();
    // final decimalPlaces = await settingsService.getDecimalPlaces();

    // Standard POS receipt size (80mm width)
    // Height can be adjusted based on content, using a fixed large value here
    // for simplicity.
    const pageFormat = PdfPageFormat(
      80 * PdfPageFormat.mm,
      200 * PdfPageFormat.mm,
      marginAll: 5 * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business Header
              pw.Text(receiptHeader, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (businessAddress.isNotEmpty)
                pw.Text(businessAddress, style: const pw.TextStyle(fontSize: 8)),
              if (businessPhone.isNotEmpty)
                pw.Text('Phone: $businessPhone', style: const pw.TextStyle(fontSize: 8)),
              if (businessEmail.isNotEmpty)
                pw.Text('Email: $businessEmail', style: const pw.TextStyle(fontSize: 8)),
              if (businessWebsite.isNotEmpty)
                pw.Text('Web: $businessWebsite', style: const pw.TextStyle(fontSize: 8)),
              if (businessTaxId.isNotEmpty)
                pw.Text('Tax ID: $businessTaxId', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 8),
              
              // Report Title
              pw.Text(reportTitle, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              
              // Date and Cashier
              pw.Text(
                'Date: ${DateTime.parse(closingData[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Cashier: ${closingData[DatabaseHelper.columnCashier]}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Divider(height: 10),
              
              _buildRow('Cash:', closingData['cash']),
              _buildRow('TPA:', closingData['tpa']),
              _buildRow('Opening Balance:', closingData['openingBalance']),
              pw.Divider(),
              _buildRow('Sales:', closingData['sales']),
              pw.Divider(),
              
              // Add detailed expenses list
              pw.Text('EXPENSES LIST:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              
              if (expensesList.isNotEmpty) ...[
                ...expensesList.map((expense) => _buildExpenseRow(
                  expense[DatabaseHelper.columnExpenseDescription],
                  expense[DatabaseHelper.columnExpenseAmount],
                )),
                pw.Divider(height: 8),
              ] else ...[
                pw.Text('No expenses recorded', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 4),
              ],
              
              _buildRow('Total Expenses:', closingData['expenses']),
              pw.Divider(),
              _buildRow('Net Result (Counted):', closingData['netResult'], isBold: true),
              _buildRow('Discrepancy (vs. System Sales):', closingData['discrepancy'], isBold: true),
              pw.SizedBox(height: 10),
              pw.Text(receiptFooter, style: const pw.TextStyle(fontSize: 8)),
              pw.Text('--- End of Report ---', style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Widget _buildRow(String label, double value, {bool isBold = false}) {
    final style = pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(_formatCurrency(value), style: style),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    // Use a simple format since we can't access settings in static context
    // This will be improved when we pass settings as parameters
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  static pw.Widget _buildExpenseRow(String description, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Description (with word wrapping)
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              description,
              style: const pw.TextStyle(fontSize: 8),
              maxLines: 2,
            ),
          ),
          pw.SizedBox(width: 4),
          // Amount
          pw.Text(
            _formatCurrency(amount),
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }
}
