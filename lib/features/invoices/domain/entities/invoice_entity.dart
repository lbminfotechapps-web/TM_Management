
class InvoiceItemEntity {
  final String name;
  final double quantity;
  final double rate;

  const InvoiceItemEntity({
    required this.name,
    required this.quantity,
    required this.rate,
  });

  double get total => quantity * rate;
}

class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;

  final String companyName;
  final String companyTagline;
  final String companyAddress;
  final String companyGstin;

  final String customerName;
  final String customerMobile;
  final String customerAddress;

  final List<InvoiceItemEntity> items;

  final double discount;
  final double gstPercent;
  final double paidAmount;

  final String paymentMethod;
  final String remark;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.companyName,
    this.companyTagline = '',
    this.companyAddress = '',
    this.companyGstin = '',
    required this.customerName,
    required this.customerMobile,
    this.customerAddress = '',
    required this.items,
    this.discount = 0,
    this.gstPercent = 0,
    this.paidAmount = 0,
    this.paymentMethod = '',
    this.remark = 'Thank you for your business!',
  });

  double get subTotal => items.fold(
        0.0,
        (total, item) => total + item.total,
      );

  double get taxableAmount =>
      (subTotal - discount).clamp(0.0, double.infinity);

  double get gstAmount =>
      taxableAmount * gstPercent / 100;

  double get grandTotal => taxableAmount + gstAmount;

  double get dueAmount =>
      (grandTotal - paidAmount).clamp(0.0, double.infinity);

  String get paymentStatus {
    if (dueAmount < 0.005) return 'Paid';
    if (paidAmount > 0) return 'Partial';
    return 'Unpaid';
  }
}
