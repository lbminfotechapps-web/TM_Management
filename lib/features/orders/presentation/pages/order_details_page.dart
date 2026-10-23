
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tailorpro_clean/core/theme/invoice_colors.dart';
import 'package:tailorpro_clean/features/orders/domain/mappers/order_invoice_mapper.dart';

import '../../../../core/router/app_routes.dart';


import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  static const _primary = InvoiceColors.primary;
  static const _gold = InvoiceColors.gold;
  static const _text = InvoiceColors.text;
  static const _muted = InvoiceColors.subText;
  static const _border = InvoiceColors.border;
  static const _background = InvoiceColors.background;
  static const _card = InvoiceColors.card;
  static const _green = InvoiceColors.success;
  static const _red = InvoiceColors.error;

  static final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // ============================================================
  // ORDER STATUS COLOR
  // ============================================================

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return const Color(0xFF64748B);
      case OrderStatus.cutting:
        return const Color(0xFF3B82F6);
      case OrderStatus.stitching:
        return _gold;
      case OrderStatus.trial:
        return const Color(0xFF8B5CF6);
      case OrderStatus.ready:
        return const Color(0xFF0D9488);
      case OrderStatus.delivered:
        return _green;
      case OrderStatus.cancelled:
        return _red;
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _editOrder(
    BuildContext context,
    OrderEntity current,
  ) {
    context.push(
      AppRoutes.editOrder,
      extra: current,
    );
  }

  void _generateInvoice(
    BuildContext context,
    OrderEntity current,
  ) {
    if (current.amount <= 0 ||
        current.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A valid quantity and amount are required '
            'to generate an invoice.',
          ),
        ),
      );
      return;
    }

    if (current.status == OrderStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot generate an invoice for a cancelled order.',
          ),
        ),
      );
      return;
    }

    // Convert latest order data to invoice data.
    final invoice = OrderInvoiceMapper.fromOrder(current);

    // OPEN INVOICE PREVIEW SCREEN
    context.pushNamed(
      'invoicePreview',
      extra: invoice,
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _surface({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: InvoiceColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: InvoiceColors.softGold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: InvoiceColors.darkGold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM ORDER HEADER
  // ============================================================

  Widget _orderHeader(OrderEntity current) {
    final statusColor = _statusColor(current.status);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            InvoiceColors.primary,
            Color(0xFF79512E),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: InvoiceColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2DBB5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checkroom_outlined,
                  size: 24,
                  color: _primary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.garment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Order #${current.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF2DBB5),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Container(
                constraints: const BoxConstraints(
                  maxWidth: 105,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  current.status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _headerInfo(
                  label: 'CUSTOMER',
                  value: current.customerName,
                ),
              ),
              const SizedBox(width: 12),
              _headerInfo(
                label: 'QUANTITY',
                value: '${current.quantity} Pieces',
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo({
    required String label,
    required String value,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE5C8A7),
            fontSize: 9,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Not provided' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd
              ? TextAlign.right
              : TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORDER AND DELIVERY DATES
  // ============================================================

  Widget _dateTile({
    required String title,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
  }) {
    return _surface(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT SUMMARY
  // ============================================================

  Widget _paymentSummary(OrderEntity current) {
    final amount = current.amount.toDouble();
    final advance = current.advance.toDouble();

    final ratio = amount > 0
        ? (advance / amount).clamp(0.0, 1.0).toDouble()
        : 0.0;

    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Payment Summary',
          Icons.account_balance_wallet_outlined,
        ),

        const SizedBox(height: 9),

        _surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Order Value',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _money.format(current.amount),
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: InvoiceColors.softGold,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '$percent% Collected',
                      style: const TextStyle(
                        color: InvoiceColors.darkGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 7,
                  backgroundColor: InvoiceColors.softGold,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    _green,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _paymentValue(
                      'Advance Paid',
                      _money.format(current.advance),
                      _green,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 37,
                    color: _border,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _paymentValue(
                      'Balance Due',
                      _money.format(current.balance),
                      current.balance > 0 ? _red : _green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentValue(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INVOICE SHORTCUT
  // ============================================================

  Widget _invoiceShortcut(
    BuildContext context,
    OrderEntity current,
  ) {
    return Material(
      color: InvoiceColors.softGold,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _generateInvoice(context, current),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: InvoiceColors.gold.withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: InvoiceColors.darkGold,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Preview',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'View, save or share your invoice',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: InvoiceColors.darkGold,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADDITIONAL NOTES
  // ============================================================

  Widget _notes(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Additional Notes',
          Icons.sticky_note_2_outlined,
        ),

        const SizedBox(height: 9),

        _surface(
          child: Text(
            notes,
            style: const TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FIXED BOTTOM ACTIONS
  // ============================================================

  Widget _bottomActions(
    BuildContext context,
    OrderEntity current,
  ) {
    final canInvoice = current.amount > 0 &&
        current.quantity > 0 &&
        current.status != OrderStatus.cancelled;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14, 9, 14, 11,
        ),
        decoration: const BoxDecoration(
          color: _card,
          border: Border(
            top: BorderSide(color: _border),
          ),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 47,
                    child: OutlinedButton.icon(
                      onPressed: () => _editOrder(context, current),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                      label: const Text('Edit Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        backgroundColor: _card,
                        side: const BorderSide(color: _border),
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 47,
                    child: ElevatedButton.icon(
                      onPressed: canInvoice
                          ? () => _generateInvoice(context, current)
                          : null,
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                      ),
                      label: const Text('Generate Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _border,
                        disabledForegroundColor: _muted,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final matching = state.orders.where(
          (item) => item.id == order.id,
        );

        final current =
            matching.isNotEmpty ? matching.first : order;

        final today = DateTime.now();
        final deliveryDay = DateTime(
          current.deliveryDate.year,
          current.deliveryDate.month,
          current.deliveryDate.day,
        );

        final currentDay = DateTime(
          today.year,
          today.month,
          today.day,
        );

        final isOverdue =
            deliveryDay.isBefore(currentDay) &&
            current.status != OrderStatus.delivered &&
            current.status != OrderStatus.cancelled;

        return Scaffold(
          backgroundColor: _background,

          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Order Details',
              style: TextStyle(
                color: _primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Order',
                onPressed: () => _editOrder(context, current),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 21,
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),

          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 650,
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    14, 8, 14, 22,
                  ),
                  children: [
                    _orderHeader(current),

                    const SizedBox(height: 11),

                    Row(
                      children: [
                        Expanded(
                          child: _dateTile(
                            title: 'Order Date',
                            date: current.orderDate,
                            icon: Icons.calendar_month_outlined,
                            iconColor: _gold,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _dateTile(
                            title: isOverdue
                                ? 'Overdue Delivery'
                                : 'Delivery Date',
                            date: current.deliveryDate,
                            icon: Icons.event_available_outlined,
                            iconColor: isOverdue ? _red : _green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    _paymentSummary(current),

                    const SizedBox(height: 13),

                    _invoiceShortcut(context, current),

                    if (current.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 17),
                      _notes(current.notes),
                    ],
                  ],
                ),
              ),
            ),
          ),

          bottomNavigationBar: _bottomActions(
            context,
            current,
          ),
        );
      },
    );
  }
}
