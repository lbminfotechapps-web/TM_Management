
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tailorpro_clean/core/theme/invoice_colors.dart';

import '../../domain/entities/invoice_entity.dart';

class InvoiceReceipt extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceReceipt({
    super.key,
    required this.invoice,
  });

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _quantity = NumberFormat('0.##');

  String _money(double value) => _currency.format(value);

  String _qty(double value) => _quantity.format(value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: InvoiceColors.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: InvoiceColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: InvoiceColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanyHeader(),

          const SizedBox(height: 14),

          const Divider(
            height: 1,
            color: InvoiceColors.divider,
          ),

          const SizedBox(height: 14),

          _buildCustomerDetails(),

          const SizedBox(height: 17),

          _buildItems(),

          const SizedBox(height: 15),

          _buildTotals(),

          const SizedBox(height: 13),

          const Divider(
            height: 1,
            color: InvoiceColors.border,
          ),

          const SizedBox(height: 13),

          _buildPaymentDetails(),

          const SizedBox(height: 22),

          _buildThankYou(),
        ],
      ),
    );
  }

  // ============================================================
  // COMPANY HEADER
  // ============================================================

  Widget _buildCompanyHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: InvoiceColors.softGold,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            size: 23,
            color: InvoiceColors.darkGold,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.companyName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: InvoiceColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),

              if (invoice.companyTagline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  invoice.companyTagline,
                  maxLines: 2,
                  style: const TextStyle(
                    color: InvoiceColors.subText,
                    fontSize: 9.5,
                    height: 1.3,
                  ),
                ),
              ],

              if (invoice.companyGstin.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'GSTIN: ${invoice.companyGstin}',
                  style: const TextStyle(
                    color: InvoiceColors.subText,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'INVOICE',
              style: TextStyle(
                color: InvoiceColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              invoice.invoiceNumber,
              maxLines: 1,
              style: const TextStyle(
                color: InvoiceColors.text,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              DateFormat('dd MMM yyyy')
                  .format(invoice.invoiceDate),
              style: const TextStyle(
                color: InvoiceColors.subText,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _heading({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: InvoiceColors.darkGold,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: InvoiceColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CUSTOMER DETAILS
  // ============================================================

  Widget _buildCustomerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          icon: Icons.person_outline_rounded,
          title: 'Customer',
        ),

        const SizedBox(height: 8),

        Text(
          invoice.customerName,
          style: const TextStyle(
            color: InvoiceColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 13,
              color: InvoiceColors.subText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                invoice.customerMobile,
                style: const TextStyle(
                  color: InvoiceColors.subText,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),

        if (invoice.customerAddress.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: InvoiceColors.subText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  invoice.customerAddress,
                  style: const TextStyle(
                    color: InvoiceColors.subText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================
  // ITEMS TABLE
  // ============================================================

  Widget _buildItems() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: InvoiceColors.softGold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _itemCell('Item', 4, header: true),
              _itemCell('Qty', 1, header: true),
              _itemCell('Price', 2, header: true),
              _itemCell('Total', 2, header: true),
            ],
          ),
        ),

        ...invoice.items.map(
          (item) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 11,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: InvoiceColors.divider,
                ),
              ),
            ),
            child: Row(
              children: [
                _itemCell(
                  item.name,
                  4,
                  left: true,
                ),
                _itemCell(
                  _qty(item.quantity),
                  1,
                ),
                _itemCell(
                  _money(item.rate),
                  2,
                ),
                _itemCell(
                  _money(item.total),
                  2,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemCell(
    String value,
    int flex, {
    bool header = false,
    bool bold = false,
    bool left = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: left || flex == 4
            ? TextAlign.left
            : TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: InvoiceColors.text,
          fontSize: header ? 10 : 9.5,
          fontWeight: header || bold
              ? FontWeight.w800
              : FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // COMMON AMOUNT ROW
  // ============================================================

  Widget _amountRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold
                    ? InvoiceColors.text
                    : InvoiceColors.subText,
                fontSize: bold ? 13 : 10.5,
                fontWeight: bold
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? InvoiceColors.text,
              fontSize: bold ? 15 : 10.5,
              fontWeight: bold
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBTOTAL / DISCOUNT / GRAND TOTAL
  // ============================================================

  Widget _buildTotals() {
    return Column(
      children: [
        _amountRow(
          'Subtotal',
          _money(invoice.subTotal),
        ),

        _amountRow(
          'Discount',
          '- ${_money(invoice.discount)}',
        ),

        if (invoice.gstPercent > 0)
          _amountRow(
            'GST (${_qty(invoice.gstPercent)}%)',
            _money(invoice.gstAmount),
          ),

        const SizedBox(height: 5),

        const Divider(
          height: 1,
          color: InvoiceColors.border,
        ),

        const SizedBox(height: 8),

        _amountRow(
          'Grand Total',
          _money(invoice.grandTotal),
          bold: true,
          valueColor: InvoiceColors.primary,
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  Widget _buildPaymentDetails() {
    final status = invoice.paymentStatus;

    final Color statusColor;
    final Color statusBackground;

    if (status == 'Paid') {
      statusColor = InvoiceColors.success;
      statusBackground = InvoiceColors.successBackground;
    } else if (status == 'Partial') {
      statusColor = InvoiceColors.pending;
      statusBackground = InvoiceColors.pendingBackground;
    } else {
      statusColor = InvoiceColors.error;
      statusBackground = InvoiceColors.errorBackground;
    }

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Payment Status',
              style: TextStyle(
                color: InvoiceColors.text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status == 'Paid'
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    color: statusColor,
                    size: 13,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _amountRow(
          'Payment Method',
          invoice.paymentMethod.isEmpty
              ? '-'
              : invoice.paymentMethod,
        ),

        _amountRow(
          'Paid Amount',
          _money(invoice.paidAmount),
        ),

        _amountRow(
          'Due Amount',
          _money(invoice.dueAmount),
          valueColor: invoice.dueAmount > 0
              ? InvoiceColors.error
              : InvoiceColors.text,
        ),
      ],
    );
  }

  // ============================================================
  // THANK YOU
  // ============================================================

  Widget _buildThankYou() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Thank you!',
            style: TextStyle(
              color: InvoiceColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            invoice.remark,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: InvoiceColors.subText,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
