
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';

import '../datasources/invoice_local_data_source.dart';
import '../datasources/invoice_pdf_data_source.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceLocalDataSource local;
  final InvoicePdfDataSource pdf;

  InvoiceRepositoryImpl({
    required this.local,
    required this.pdf,
  });

  @override
  Future<void> saveInvoice(InvoiceEntity invoice) {
    return local.saveInvoice(invoice);
  }

  @override
  Future<InvoiceEntity?> getInvoice(String id) {
    return local.getInvoice(id);
  }

  @override
  Future<String> savePdf(InvoiceEntity invoice) {
    return pdf.savePdf(invoice);
  }

  @override
  Future<void> sharePdf(InvoiceEntity invoice) {
    return pdf.sharePdf(invoice);
  }
}
