import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _avatarBg = Color(0xFFF8EFE1);

  String get _initials {
    final parts = customer.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return '?';

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String get _phone {
    final value = customer.phone.trim();
    return value.isEmpty ? 'No phone number' : value;
  }

  String get _address {
    final value = customer.address.trim();
    return value.isEmpty ? 'No address added' : value;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(customer.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              11,
              10,
              7,
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===============================
                // PROFILE HEADER
                // ===============================
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _avatarBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: _brownLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name.trim().isEmpty
                                ? 'Unnamed Customer'
                                : customer.name,
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
                              const Icon(
                                Icons.call_outlined,
                                size: 13,
                                color: _muted,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ===============================
                    // ACTION MENU
                    // ===============================
                    SizedBox(
                      width: 34,
                      height: 38,
                      child: PopupMenuButton<String>(
                        tooltip: 'Customer actions',
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: _muted,
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
                                Text('Edit Customer'),
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
                                  'Delete Customer',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ===============================
                // COMPACT DIVIDER
                // ===============================
                const Divider(
                  height: 1,
                  thickness: 0.7,
                  color: _border,
                ),

                const SizedBox(height: 9),

                // ===============================
                // ADDRESS AND DATE
                // ===============================
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: _gold,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: _muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
