import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(Map<String, dynamic> closingData) async {
    final doc = pw.Document();
    final dbHelper = DatabaseHelper.instance;

    // Get the detailed expenses list for this record
    List<Map<String, dynamic>> expensesList = [];
    if (closingData[DatabaseHelper.columnId] != null) {
      expensesList = await dbHelper.getExpensesForRecord(closingData[DatabaseHelper.columnId]);
    }

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
              pw.Text('Mini Mercado', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Closing Report', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
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
          pw.Text(NumberFormat.currency(symbol: '').format(value), style: style),
        ],
      ),
    );
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
            NumberFormat.currency(symbol: '').format(amount),
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }
}
