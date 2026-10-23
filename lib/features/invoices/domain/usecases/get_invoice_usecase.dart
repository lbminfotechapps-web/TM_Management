
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class GetInvoiceUseCase {
  final InvoiceRepository repository;

  GetInvoiceUseCase(this.repository);

  Future<InvoiceEntity?> call(String invoiceId) {
    return repository.getInvoice(invoiceId);
  }
}
