import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(Map<String, dynamic> closingData) async {
    final doc = pw.Document();

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
              pw.Text('Closing Report', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date: ${DateTime.parse(closingData[DatabaseHelper.columnDate]).toLocal().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Divider(height: 10),
              
              _buildRow('Cash:', closingData['cash']),
              _buildRow('TPA:', closingData['tpa']),
              _buildRow('Expenses:', closingData['expenses']),
              _buildRow('Opening Balance:', closingData['openingBalance']),
              pw.Divider(),
              _buildRow('Sales:', closingData['sales']),
              pw.Divider(),
              _buildRow('Net Result (Counted):', closingData['netResult'], isBold: true),
              _buildRow('Discrepancy (vs. System Sales):', closingData['discrepancy'], isBold: true),
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
}
