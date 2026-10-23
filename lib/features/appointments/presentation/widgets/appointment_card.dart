
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<AppointmentStatus> onStatusChanged;

  const AppointmentCard({
    super.key,
    required this.appointment,
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
  static const Color _dateBg = Color(0xFFF8EFE1);

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFFAD7A3C);
      case AppointmentStatus.confirmed:
        return const Color(0xFF4079B6);
      case AppointmentStatus.completed:
        return AppColors.green;
      case AppointmentStatus.cancelled:
        return AppColors.red;
    }
  }

  IconData _statusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.event_available_outlined;
      case AppointmentStatus.confirmed:
        return Icons.verified_outlined;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final statusColor = _statusColor(a.status);

    final dateDay = DateFormat('dd').format(a.dateTime);
    final dateMonth = DateFormat('MMM').format(a.dateTime);
    final dateTime = DateFormat('hh:mm a').format(a.dateTime);

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
              10, 9, 6, 9,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ====================================
                // COMPACT DATE BOX
                // ====================================
                Container(
                  width: 51,
                  height: 65,
                  decoration: BoxDecoration(
                    color: _dateBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateDay,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateMonth.toUpperCase(),
                        style: const TextStyle(
                          color: _brownLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ====================================
                // APPOINTMENT INFORMATION
                // ====================================
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a.customerName.trim().isEmpty
                            ? 'Unknown Customer'
                            : a.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        a.purpose.trim().isEmpty
                            ? 'No purpose specified'
                            : a.purpose,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: _gold,
                            size: 13,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            dateTime,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Flexible(
                            child: _buildStatusMenu(
                              statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 3),

                // ====================================
                // ACTION MENU
                // ====================================
                _buildActionMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================
  // STATUS CHANGE MENU
  // ====================================
  Widget _buildStatusMenu(Color color) {
    return PopupMenuButton<AppointmentStatus>(
      tooltip: 'Change appointment status',
      padding: EdgeInsets.zero,
      onSelected: (status) {
        if (status != appointment.status) {
          onStatusChanged(status);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (_) {
        return AppointmentStatus.values.map((status) {
          final itemColor = _statusColor(status);

          return PopupMenuItem<AppointmentStatus>(
            value: status,
            height: 42,
            child: Row(
              children: [
                Icon(
                  _statusIcon(status),
                  size: 17,
                  color: itemColor,
                ),
                const SizedBox(width: 10),
                Text(
                  status.label,
                  style: TextStyle(
                    color: status == appointment.status
                        ? itemColor
                        : _primary,
                    fontSize: 12,
                    fontWeight: status == appointment.status
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                if (status == appointment.status) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: itemColor,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                appointment.status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: color,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  // ====================================
  // VIEW / EDIT / DELETE MENU
  // ====================================
  Widget _buildActionMenu() {
    return SizedBox(
      width: 33,
      height: 38,
      child: PopupMenuButton<String>(
        tooltip: 'Appointment actions',
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
                Text('Edit Appointment'),
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
                  'Delete Appointment',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
