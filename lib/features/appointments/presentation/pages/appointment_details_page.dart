
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _lightBg = Color(0xFFFAF7F3);

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFFAD7A3C);
      case AppointmentStatus.confirmed:
        return const Color(0xFF4079B6);
      case AppointmentStatus.completed:
        return const Color(0xFF26866A);
      case AppointmentStatus.cancelled:
        return const Color(0xFFD35555);
    }
  }

  Color _statusBackground(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFFFBF0DF);
      case AppointmentStatus.confirmed:
        return const Color(0xFFEAF2FD);
      case AppointmentStatus.completed:
        return const Color(0xFFE8F6EE);
      case AppointmentStatus.cancelled:
        return const Color(0xFFFCECEC);
    }
  }

  IconData _statusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule_rounded;
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
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        // Get updated appointment after editing.
        final matches = state.appointments.where(
          (item) => item.id == appointment.id,
        );

        final current = matches.isNotEmpty
            ? matches.first
            : appointment;

        final date = DateFormat(
          'dd MMM yyyy',
        ).format(current.dateTime);

        final time = DateFormat(
          'hh:mm a',
        ).format(current.dateTime);

        void editAppointment() {
          context.push(
            AppRoutes.editAppointment,
            extra: current,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          // =====================================
          // APP BAR
          // =====================================
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Appointment Details',
              style: TextStyle(
                color: _primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Appointment',
                onPressed: editAppointment,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),

          // =====================================
          // BODY
          // =====================================
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
                    // ==================================
                    // COMPACT APPOINTMENT HEADER
                    // ==================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primary,
                            _brownLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.10),
                            blurRadius: 11,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 47,
                                height: 47,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEED4A7),
                                  borderRadius:
                                      BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.event_available_outlined,
                                  color: _primary,
                                  size: 24,
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      current.customerName.trim().isEmpty
                                          ? 'Unknown Customer'
                                          : current.customerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      current.purpose.trim().isEmpty
                                          ? 'No purpose specified'
                                          : current.purpose,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFF2CD96),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            height: 1,
                            color: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '#${current.id}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF2D5AD),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBackground(
                                    current.status,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _statusIcon(
                                        current.status,
                                      ),
                                      color: _statusColor(
                                        current.status,
                                      ),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      current.status.label,
                                      style: TextStyle(
                                        color: _statusColor(
                                          current.status,
                                        ),
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================
                    // DATE / TIME TILES
                    // ==================================
                    Row(
                      children: [
                        Expanded(
                          child: _DateTimeTile(
                            title: 'Appointment Date',
                            value: date,
                            icon: Icons.calendar_month_outlined,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _DateTimeTile(
                            title: 'Appointment Time',
                            value: time,
                            icon: Icons.access_time_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==================================
                    // APPOINTMENT INFORMATION
                    // ==================================
                    const _SectionHeading(
                      title: 'Appointment Information',
                      icon: Icons.assignment_outlined,
                    ),

                    const SizedBox(height: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Customer',
                            value: current.customerName,
                          ),

                          const Divider(
                            height: 1,
                            color: _border,
                          ),

                          _InfoRow(
                            label: 'Purpose',
                            value: current.purpose,
                          ),

                          const Divider(
                            height: 1,
                            color: _border,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _statusIcon(current.status),
                                  color: _statusColor(
                                    current.status,
                                  ),
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  current.status.label,
                                  style: TextStyle(
                                    color: _statusColor(
                                      current.status,
                                    ),
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================
                    // OPTIONAL NOTES
                    // ==================================
                    if (current.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 15),

                      const _SectionHeading(
                        title: 'Special Instructions',
                        icon: Icons.sticky_note_2_outlined,
                      ),

                      const SizedBox(height: 9),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: _border,
                          ),
                        ),
                        child: Text(
                          current.notes.trim(),
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // =====================================
          // FIXED BOTTOM EDIT BUTTON
          // =====================================
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                14, 9, 14, 11,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _border),
                ),
              ),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton.icon(
                      onPressed: editAppointment,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Edit Appointment',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// SECTION HEADING
// ==========================================

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF79512E),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF392417),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DATE / TIME TILE
// ==========================================

class _DateTimeTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DateTimeTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFEDE6DE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EFE1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 17,
              color: const Color(0xFFBD8A47),
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
                    color: Color(0xFF8B8178),
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF392417),
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
}

// ==========================================
// COMPACT INFO ROW
// ==========================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B8178),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty
                  ? 'Not provided'
                  : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF392417),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
