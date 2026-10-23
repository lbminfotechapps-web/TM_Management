
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';
import '../widgets/appointment_card.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _search = TextEditingController();
  String query = '';
  AppointmentStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(
      const LoadAppointmentsEvent(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: const Text('This appointment will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    context.read<AppointmentBloc>().add(
      DeleteAppointmentEvent(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment List'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<AppointmentBloc>().add(
              const LoadAppointmentsEvent(),
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.addAppointment),
        icon: const Icon(Icons.add),
        label: const Text('New Appointment'),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listenWhen: (oldState, newState) =>
            oldState.revision != newState.revision &&
            (newState.status == AppointmentBlocStatus.deleted ||
                newState.status == AppointmentBlocStatus.failure),
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AppointmentBlocStatus.loading &&
              state.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final text = query.trim().toLowerCase();
          final items = state.appointments.where((a) {
            final matchesText =
                a.customerName.toLowerCase().contains(text) ||
                a.purpose.toLowerCase().contains(text) ||
                a.id.toLowerCase().contains(text);

            return matchesText &&
                (selectedStatus == null ||
                    a.status == selectedStatus);
          }).toList();

          final today = DateTime.now();
          final todayCount = state.appointments.where((a) =>
              a.dateTime.year == today.year &&
              a.dateTime.month == today.month &&
              a.dateTime.day == today.day &&
              a.status != AppointmentStatus.cancelled).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF392417),
                            Color(0xFF79512E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available,
                            color: Color(0xFFF2CD96),
                            size: 32,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.appointments.length} Appointments',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$todayCount scheduled for today',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      onChanged: (value) {
                        setState(() => query = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search customer or purpose',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => query = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AppointmentStatus?>(
                      key: ValueKey(selectedStatus),
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<AppointmentStatus?>(
                          value: null,
                          child: Text('All Appointments'),
                        ),
                        ...AppointmentStatus.values.map(
                          (status) => DropdownMenuItem<AppointmentStatus?>(
                            value: status,
                            child: Text(status.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedStatus = value);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.status == AppointmentBlocStatus.failure &&
                        state.appointments.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: () => context
                              .read<AppointmentBloc>()
                              .add(const LoadAppointmentsEvent()),
                          child: Text('Retry: ${state.message}'),
                        ),
                      )
                    : items.isEmpty
                        ? const Center(
                            child: Text('No appointments found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final appointment = items[index];

                              return AppointmentCard(
                                appointment: appointment,
                                onTap: () => context.push(
                                  AppRoutes.appointmentDetails,
                                  extra: appointment,
                                ),
                                onEdit: () => context.push(
                                  AppRoutes.editAppointment,
                                  extra: appointment,
                                ),
                                onDelete: () => _delete(appointment.id),
                                onStatusChanged: (status) {
                                  context.read<AppointmentBloc>().add(
                                    SaveAppointmentEvent(
                                      appointment.copyWith(status: status),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
