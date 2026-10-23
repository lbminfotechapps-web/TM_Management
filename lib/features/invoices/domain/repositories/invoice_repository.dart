
import '../entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<void> saveInvoice(InvoiceEntity invoice);

  Future<InvoiceEntity?> getInvoice(String id);

  Future<String> savePdf(InvoiceEntity invoice);

  Future<void> sharePdf(InvoiceEntity invoice);
}
