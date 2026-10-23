
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class ExportInvoiceUseCase {
  final InvoiceRepository repository;

  ExportInvoiceUseCase(this.repository);

  Future<String> savePdf(InvoiceEntity invoice) {
    return repository.savePdf(invoice);
  }

  Future<void> sharePdf(InvoiceEntity invoice) {
    return repository.sharePdf(invoice);
  }
}
