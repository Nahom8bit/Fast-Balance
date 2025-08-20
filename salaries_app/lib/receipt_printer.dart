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

    // Get all settings for customization
    final businessName = await settingsService.getBusinessName();
    final businessAddress = await settingsService.getBusinessAddress();
    final businessPhone = await settingsService.getBusinessPhone();
    final businessEmail = await settingsService.getBusinessEmail();
    final businessWebsite = await settingsService.getBusinessWebsite();
    final businessTaxId = await settingsService.getBusinessTaxId();
    final receiptHeader = await settingsService.getReceiptHeader();
    final receiptFooter = await settingsService.getReceiptFooter();
    final reportTitle = await settingsService.getReportTitle();
    // Currency formatting settings (for future use)
    // final currencySymbol = await settingsService.getCurrencySymbol();
    // final decimalPlaces = await settingsService.getDecimalPlaces();
    final paperSize = await settingsService.getPaperSize();
    final printQuality = await settingsService.getPrintQuality();
    final paperOrientation = await settingsService.getPaperOrientation();
    // Print copies setting (for future use)
    // final printCopies = await settingsService.getPrintCopies();
    final printPreview = await settingsService.getPrintPreview();

    // Determine page format based on settings
    PdfPageFormat pageFormat = _getPageFormat(paperSize, paperOrientation);

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Enhanced Business Header with Logo placeholder
              _buildBusinessHeader(
                businessName,
                receiptHeader,
                businessAddress,
                businessPhone,
                businessEmail,
                businessWebsite,
                businessTaxId,
              ),
              
              pw.SizedBox(height: 12),
              
              // Enhanced Report Title
              _buildReportTitle(reportTitle),
              
              pw.SizedBox(height: 8),
              
              // Enhanced Date and Cashier Information
              _buildTransactionInfo(closingData),
              
              pw.Divider(height: 12, thickness: 1),
              
              // Enhanced Financial Summary
              _buildFinancialSummary(closingData),
              
              pw.Divider(height: 12, thickness: 1),
              
              // Enhanced Detailed Expenses List
              _buildExpensesSection(expensesList, closingData['expenses']),
              
              pw.Divider(height: 12, thickness: 1),
              
              // Enhanced Results Section
              _buildResultsSection(closingData),
              
              pw.SizedBox(height: 16),
              
              // Enhanced Footer
              _buildFooter(receiptFooter),
            ],
          );
        },
      ),
    );

    // Apply print settings
    final printFormat = _getPrintFormat(printQuality);
    
    if (printPreview) {
      // Show print preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        format: printFormat,
      );
    } else {
      // Direct printing
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
        format: printFormat,
      );
    }
  }

  static pw.Widget _buildBusinessHeader(
    String businessName,
    String receiptHeader,
    String businessAddress,
    String businessPhone,
    String businessEmail,
    String businessWebsite,
    String businessTaxId,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Business Name/Header (centered)
        pw.Text(
          receiptHeader.isNotEmpty ? receiptHeader : businessName,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        
        if (businessAddress.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            businessAddress,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ],
        
        if (businessPhone.isNotEmpty || businessEmail.isNotEmpty || businessWebsite.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (businessPhone.isNotEmpty)
                pw.Text(
                  'Phone: $businessPhone',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              if (businessPhone.isNotEmpty && businessEmail.isNotEmpty)
                pw.Text(' | ', style: const pw.TextStyle(fontSize: 8)),
              if (businessEmail.isNotEmpty)
                pw.Text(
                  'Email: $businessEmail',
                  style: const pw.TextStyle(fontSize: 8),
                ),
            ],
          ),
        ],
        
        if (businessWebsite.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            'Web: $businessWebsite',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
        
        if (businessTaxId.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            'Tax ID: $businessTaxId',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildReportTitle(String reportTitle) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        reportTitle,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTransactionInfo(Map<String, dynamic> closingData) {
    final date = DateTime.parse(closingData[DatabaseHelper.columnDate]).toLocal();
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('HH:mm:ss').format(date);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Date:', formattedDate),
        _buildInfoRow('Time:', formattedTime),
        _buildInfoRow('Cashier:', closingData[DatabaseHelper.columnCashier]),
        _buildInfoRow('Report ID:', '#${closingData[DatabaseHelper.columnId] ?? 'N/A'}'),
      ],
    );
  }

  static pw.Widget _buildFinancialSummary(Map<String, dynamic> closingData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FINANCIAL SUMMARY',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        _buildSummaryRow('Cash on Hand:', closingData['cash']),
        _buildSummaryRow('TPA (Card/Mobile):', closingData['tpa']),
        _buildSummaryRow('Opening Balance:', closingData['openingBalance']),
        pw.Divider(height: 8),
        _buildSummaryRow('Total Sales:', closingData['sales'], isBold: true),
      ],
    );
  }

  static pw.Widget _buildExpensesSection(List<Map<String, dynamic>> expensesList, double totalExpenses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAILED EXPENSES',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        
        if (expensesList.isNotEmpty) ...[
          // Header row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Description',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  'Amount',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 4),
          
          // Expense items
          ...expensesList.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              child: _buildExpenseRow(
                expense[DatabaseHelper.columnExpenseDescription],
                expense[DatabaseHelper.columnExpenseAmount],
              ),
            );
          }),
          
          pw.Divider(height: 8),
          _buildSummaryRow('Total Expenses:', totalExpenses, isBold: true),
        ] else ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'No expenses recorded for this period',
              style: pw.TextStyle(
                fontSize: 9,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildResultsSection(Map<String, dynamic> closingData) {
    final netResult = closingData['netResult'] as double;
    final discrepancy = closingData['discrepancy'] as double;
    final isBalanced = discrepancy.abs() < 0.01;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CLOSING RESULTS',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        _buildSummaryRow('Net Result (Counted):', netResult, isBold: true),
        _buildSummaryRow(
          'Discrepancy (vs. System):',
          discrepancy,
          isBold: true,
          color: isBalanced ? PdfColors.green : PdfColors.red,
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: isBalanced ? PdfColors.green50 : PdfColors.red50,
            border: pw.Border.all(
              color: isBalanced ? PdfColors.green : PdfColors.red,
              width: 1,
            ),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            isBalanced ? '✓ BALANCED' : '⚠ DISCREPANCY DETECTED',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: isBalanced ? PdfColors.green : PdfColors.red,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(String receiptFooter) {
    return pw.Column(
      children: [
        if (receiptFooter.isNotEmpty) ...[
          pw.Text(
            receiptFooter,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
        ],
        pw.Text(
          '--- End of Report ---',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated on ${DateFormat('MMM dd, yyyy HH:mm:ss').format(DateTime.now())}',
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey500,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double value, {bool isBold = false, PdfColor? color}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
    );
    
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

  static pw.Widget _buildExpenseRow(String description, double amount) {
    return pw.Row(
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
        pw.SizedBox(width: 8),
        // Amount
                           pw.Text(
            _formatCurrency(amount),
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
      ],
    );
  }

  static String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
  }

  static PdfPageFormat _getPageFormat(String paperSize, String orientation) {
    double width, height;
    
    switch (paperSize.toLowerCase()) {
      case 'a4':
        width = PdfPageFormat.a4.width;
        height = PdfPageFormat.a4.height;
        break;
      case 'letter':
        width = PdfPageFormat.letter.width;
        height = PdfPageFormat.letter.height;
        break;
      case 'legal':
        width = PdfPageFormat.legal.width;
        height = PdfPageFormat.legal.height;
        break;
      case '80mm':
      default:
        width = 80 * PdfPageFormat.mm;
        height = 200 * PdfPageFormat.mm;
        break;
    }
    
    if (orientation.toLowerCase() == 'landscape') {
      final temp = width;
      width = height;
      height = temp;
    }
    
    return PdfPageFormat(
      width,
      height,
      marginAll: 10,
    );
  }

  static PdfPageFormat _getPrintFormat(String printQuality) {
    switch (printQuality.toLowerCase()) {
      case 'high':
        return PdfPageFormat.a4;
      case 'low':
        return PdfPageFormat.a4;
      case 'normal':
      default:
        return PdfPageFormat.a4;
    }
  }
}
