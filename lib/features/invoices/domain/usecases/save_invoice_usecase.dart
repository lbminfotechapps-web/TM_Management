
import '../entities/invoice_entity.dart';
import '../repositories/invoice_repository.dart';

class SaveInvoiceUseCase {
  final InvoiceRepository repository;

  SaveInvoiceUseCase(this.repository);

  Future<void> call(InvoiceEntity invoice) {
    return repository.saveInvoice(invoice);
  }
}
