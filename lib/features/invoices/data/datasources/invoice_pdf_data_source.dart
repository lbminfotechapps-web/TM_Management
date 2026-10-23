
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/invoice_entity.dart';

abstract class InvoicePdfDataSource {
  Future<Uint8List> generatePdf(InvoiceEntity invoice);

  Future<String> savePdf(InvoiceEntity invoice);

  Future<void> sharePdf(InvoiceEntity invoice);
}

class InvoicePdfDataSourceImpl
    implements InvoicePdfDataSource {
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  final NumberFormat _quantity = NumberFormat('0.##');

  String _fileName(String number) {
    final safe = number.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    return 'Invoice_$safe.pdf';
  }

  @override
  Future<Uint8List> generatePdf(
    InvoiceEntity invoice,
  ) async {
    final fontBytes = await rootBundle.load(
      'assets/fonts/NotoSans-Regular.ttf',
    );

    final regular = pw.Font.ttf(fontBytes);
    final pdf = pw.Document();

    final primary = PdfColor.fromHex('#392417');

    final date = DateFormat(
      'dd MMM yyyy',
    ).format(invoice.invoiceDate);

    pw.Widget totalRow(
      String label,
      String value, {
      bool bold = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: bold ? 12 : 10,
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: bold ? 13 : 10,
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(
          base: regular,
          bold: regular,
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      invoice.companyName,
                      style: pw.TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (invoice.companyTagline.isNotEmpty)
                      pw.Text(invoice.companyTagline),
                    if (invoice.companyAddress.isNotEmpty)
                      pw.Text(invoice.companyAddress),
                    if (invoice.companyGstin.isNotEmpty)
                      pw.Text('GSTIN: ${invoice.companyGstin}'),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      color: primary,
                      fontSize: 17,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(invoice.invoiceNumber),
                  pw.Text(date),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 18),
          pw.Divider(color: primary),
          pw.SizedBox(height: 12),

          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(invoice.customerName),
          pw.Text(invoice.customerMobile),
          if (invoice.customerAddress.isNotEmpty)
            pw.Text(invoice.customerAddress),

          pw.SizedBox(height: 20),

          pw.TableHelper.fromTextArray(
            headers: const [
              'Item',
              'Qty',
              'Rate',
              'Total',
            ],
            data: invoice.items.map((item) => [
              item.name,
              _quantity.format(item.quantity),
              _currency.format(item.rate),
              _currency.format(item.total),
            ]).toList(),
            headerDecoration: pw.BoxDecoration(
              color: primary,
            ),
            headerStyle: const pw.TextStyle(
              color: PdfColors.white,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.all(8),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
          ),

          pw.SizedBox(height: 16),
          totalRow(
            'Subtotal',
            _currency.format(invoice.subTotal),
          ),
          totalRow(
            'Discount',
            '- ${_currency.format(invoice.discount)}',
          ),
          if (invoice.gstPercent > 0)
            totalRow(
              'GST (${invoice.gstPercent}%)',
              _currency.format(invoice.gstAmount),
            ),
          pw.Divider(),
          totalRow(
            'Grand Total',
            _currency.format(invoice.grandTotal),
            bold: true,
          ),

          pw.SizedBox(height: 18),

          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          totalRow('Status', invoice.paymentStatus),
          totalRow('Method', invoice.paymentMethod),
          totalRow(
            'Paid Amount',
            _currency.format(invoice.paidAmount),
          ),
          totalRow(
            'Due Amount',
            _currency.format(invoice.dueAmount),
          ),

          pw.SizedBox(height: 24),

          pw.Center(
            child: pw.Text(
              invoice.remark,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Future<String> savePdf(InvoiceEntity invoice) async {
    final bytes = await generatePdf(invoice);

    final documents =
        await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${documents.path}/invoices',
    );

    await directory.create(recursive: true);

    final file = File(
      '${directory.path}/${_fileName(invoice.invoiceNumber)}',
    );

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  @override
  Future<void> sharePdf(InvoiceEntity invoice) async {
    final bytes = await generatePdf(invoice);

    await Printing.sharePdf(
      bytes: bytes,
      filename: _fileName(invoice.invoiceNumber),
    );
  }
}
