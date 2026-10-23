
import 'package:tailorpro_clean/features/invoices/domain/entities/invoice_entity.dart';
import 'package:tailorpro_clean/features/orders/domain/entities/order_entity.dart';



class OrderInvoiceMapper {
  OrderInvoiceMapper._();

  static InvoiceEntity fromOrder(
    OrderEntity order, {
    String companyName = 'TailorPro',
    String companyTagline = 'Style Stitched for You',
    String companyAddress = '',
    String companyGstin = '',
    String customerMobile = '',
    String customerAddress = '',
    String paymentMethod = '',
  }) {
    final quantity = order.quantity > 0
        ? order.quantity.toDouble()
        : 1.0;

    final amount = order.amount.toDouble();

    return InvoiceEntity(
      // Stable local invoice ID for this order.
      id: 'order-invoice-${order.id}',

      // Preview reference only.
      // Replace with a real invoice number from your backend
      // before issuing an official invoice.
      invoiceNumber: 'DRAFT-${order.id}',

      invoiceDate: order.orderDate,

      companyName: companyName,
      companyTagline: companyTagline,
      companyAddress: companyAddress,
      companyGstin: companyGstin,

      customerName: order.customerName,
      customerMobile: customerMobile,
      customerAddress: customerAddress,

      items: [
        InvoiceItemEntity(
          name: order.garment,
          quantity: quantity,
          rate: amount / quantity,
        ),
      ],

      // OrderEntity currently exposes one overall amount,
      // not a separate discount / tax breakdown.
      discount: 0,
      gstPercent: 0,

      paidAmount: order.advance.toDouble(),
      paymentMethod: paymentMethod,

      remark: order.notes.trim().isNotEmpty
          ? order.notes
          : 'Thank you for your business!',
    );
  }
}
