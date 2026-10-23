import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<OrderStatus> onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _lightBg = Color(0xFFF8EFE1);

  Color get statusColor {
    switch (order.status) {
      case OrderStatus.received:
        return const Color(0xFF64748B);
      case OrderStatus.cutting:
        return const Color(0xFF3B82F6);
      case OrderStatus.stitching:
        return const Color(0xFFC08B3B);
      case OrderStatus.trial:
        return const Color(0xFF8B5CF6);
      case OrderStatus.ready:
        return const Color(0xFF0D9488);
      case OrderStatus.delivered:
        return AppColors.green;
      case OrderStatus.cancelled:
        return AppColors.red;
    }
  }

  Color _colorForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return const Color(0xFF64748B);
      case OrderStatus.cutting:
        return const Color(0xFF3B82F6);
      case OrderStatus.stitching:
        return const Color(0xFFC08B3B);
      case OrderStatus.trial:
        return const Color(0xFF8B5CF6);
      case OrderStatus.ready:
        return const Color(0xFF0D9488);
      case OrderStatus.delivered:
        return AppColors.green;
      case OrderStatus.cancelled:
        return AppColors.red;
    }
  }

  bool get _isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final due = DateTime(
      order.deliveryDate.year,
      order.deliveryDate.month,
      order.deliveryDate.day,
    );

    return due.isBefore(today) &&
        order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.035),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================================
                // HEADER: GARMENT, ID, STATUS, MENU
                // ================================
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _lightBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.checkroom_outlined,
                        color: _brownLight,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.garment.trim().isEmpty
                                ? 'Unnamed Garment'
                                : order.garment,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '#${order.id}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '• Qty ${order.quantity}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 5),

                    // CHANGE STATUS
                    _buildStatusMenu(),

                    // EDIT / DELETE ACTIONS
                    _buildActionMenu(),
                  ],
                ),

                const SizedBox(height: 10),

                const Divider(
                  height: 1,
                  thickness: 0.7,
                  color: _border,
                ),

                const SizedBox(height: 9),

                // ================================
                // CUSTOMER AND DELIVERY DATE
                // ================================
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: _muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.customerName.trim().isEmpty
                            ? 'Unknown Customer'
                            : order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: _isOverdue ? AppColors.red : _gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(order.deliveryDate),
                      style: TextStyle(
                        color: _isOverdue ? AppColors.red : _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // ================================
                // AMOUNT AND BALANCE
                // ================================
                Row(
                  children: [
                    const Text(
                      'Order Amount',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      money.format(order.amount),
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.balance > 0
                            ? AppColors.red.withValues(alpha: 0.08)
                            : AppColors.green.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.balance > 0
                            ? 'Due ${money.format(order.balance)}'
                            : 'Paid',
                        style: TextStyle(
                          color: order.balance > 0
                              ? AppColors.red
                              : AppColors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isOverdue) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Delivery overdue',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // STATUS DROPDOWN
  // ================================
  Widget _buildStatusMenu() {
    return PopupMenuButton<OrderStatus>(
      tooltip: 'Update order status',
      padding: EdgeInsets.zero,
      onSelected: (status) {
        if (status != order.status) {
          onStatusChanged(status);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      itemBuilder: (_) {
        return OrderStatus.values.map((status) {
          final color = _colorForStatus(status);

          return PopupMenuItem<OrderStatus>(
            value: status,
            height: 42,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  status.label,
                  style: TextStyle(
                    color: status == order.status ? color : _primary,
                    fontSize: 12,
                    fontWeight: status == order.status
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                if (status == order.status) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: color,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                order.status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // ACTION MENU
  // ================================
  Widget _buildActionMenu() {
    return SizedBox(
      width: 32,
      height: 38,
      child: PopupMenuButton<String>(
        tooltip: 'Order actions',
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert_rounded,
          color: _muted,
          size: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        onSelected: (value) {
          switch (value) {
            case 'view':
              onTap();
              break;
            case 'edit':
              onEdit();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem<String>(
            value: 'view',
            height: 42,
            child: Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: _primary,
                ),
                SizedBox(width: 10),
                Text('View Details'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'edit',
            height: 42,
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: _brownLight,
                ),
                SizedBox(width: 10),
                Text('Edit Order'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            height: 42,
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Delete Order',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
