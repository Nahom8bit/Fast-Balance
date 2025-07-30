import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'database_helper.dart';

class ReceiptPrinter {
  static Future<void> printReceipt(Map<String, dynamic> data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Balance Closing Receipt', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateTime.parse(data[DatabaseHelper.columnDate]).toLocal()}'),
              pw.Divider(),
              _buildRow('Opening Balance:', data[DatabaseHelper.columnOpeningBalance]),
              _buildRow('Cash Sales:', data[DatabaseHelper.columnCashSales]),
              _buildRow('TPA Sales:', data[DatabaseHelper.columnTpaSales]),
              _buildRow('Total Sales:', data[DatabaseHelper.columnTotalSales]),
              _buildRow('Total Expenses:', data[DatabaseHelper.columnTotalExpenses]),
              pw.Divider(),
              _buildRow('Expected Cash:', data[DatabaseHelper.columnExpectedCash]),
              _buildRow('Actual Cash:', data[DatabaseHelper.columnCashOnHand]),
              pw.Divider(),
              _buildRow('Difference:', data[DatabaseHelper.columnDifference], isBold: true),
              _buildRow('Status:', data[DatabaseHelper.columnStatus], isBold: true),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Widget _buildRow(String label, dynamic value, {bool isBold = false}) {
    String formattedValue;
    if (value is double) {
      formattedValue = 'L.K.R ${value.toStringAsFixed(2)}';
    } else {
      formattedValue = value.toString();
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : const pw.TextStyle()),
          pw.Text(formattedValue, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : const pw.TextStyle()),
        ],
      ),
    );
  }
}
