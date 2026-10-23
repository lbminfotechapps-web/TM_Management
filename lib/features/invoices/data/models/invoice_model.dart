
import '../../domain/entities/invoice_entity.dart';

class InvoiceModel {
  InvoiceModel._();

  static Map<String, dynamic> toJson(InvoiceEntity invoice) {
    return {
      'id': invoice.id,
      'invoice_number': invoice.invoiceNumber,
      'invoice_date': invoice.invoiceDate.toIso8601String(),
      'company_name': invoice.companyName,
      'company_tagline': invoice.companyTagline,
      'company_address': invoice.companyAddress,
      'company_gstin': invoice.companyGstin,
      'customer_name': invoice.customerName,
      'customer_mobile': invoice.customerMobile,
      'customer_address': invoice.customerAddress,
      'discount': invoice.discount,
      'gst_percent': invoice.gstPercent,
      'paid_amount': invoice.paidAmount,
      'payment_method': invoice.paymentMethod,
      'remark': invoice.remark,
      'items': invoice.items.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'rate': item.rate,
      }).toList(),
    };
  }

  static InvoiceEntity fromJson(Map<String, dynamic> json) {
    String str(String key) =>
        json[key]?.toString() ?? '';

    double number(dynamic value) =>
        double.tryParse(value?.toString() ?? '') ?? 0;

    final rawItems = json['items'];

    return InvoiceEntity(
      id: str('id'),
      invoiceNumber: str('invoice_number'),
      invoiceDate: DateTime.tryParse(str('invoice_date')) ??
          DateTime.now(),
      companyName: str('company_name'),
      companyTagline: str('company_tagline'),
      companyAddress: str('company_address'),
      companyGstin: str('company_gstin'),
      customerName: str('customer_name'),
      customerMobile: str('customer_mobile'),
      customerAddress: str('customer_address'),
      discount: number(json['discount']),
      gstPercent: number(json['gst_percent']),
      paidAmount: number(json['paid_amount']),
      paymentMethod: str('payment_method'),
      remark: str('remark'),
      items: rawItems is List
          ? rawItems.map((raw) {
              final item = Map<String, dynamic>.from(raw as Map);
              return InvoiceItemEntity(
                name: item['name']?.toString() ?? '',
                quantity: number(item['quantity']),
                rate: number(item['rate']),
              );
            }).toList()
          : [],
    );
  }
}
