
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

import '../bloc/measurement_bloc.dart';
import '../widgets/measurement_card.dart';

class MeasurementPage extends StatefulWidget {
  const MeasurementPage({super.key});

  @override
  State<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  final _searchController = TextEditingController();
  String search = '';

  @override
  void initState() {
    super.initState();
    context.read<MeasurementBloc>().add(
      const LoadMeasurementsEvent(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Measurements?'),
        content: const Text(
          'This measurement record will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    context.read<MeasurementBloc>().add(
      DeleteMeasurementEvent(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Measurement List',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<MeasurementBloc>().add(
                const LoadMeasurementsEvent(),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Measurement'),
        onPressed: () =>
            context.push(AppRoutes.addMeasurement),
      ),
      body: BlocConsumer<MeasurementBloc, MeasurementState>(
        listenWhen: (previous, current) =>
            previous.revision != current.revision &&
            (current.status == MeasurementStatus.deleted ||
                current.status == MeasurementStatus.failure),
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message)),
              );
          }
        },
        builder: (context, state) {
          if (state.status == MeasurementStatus.loading &&
              state.measurements.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            );
          }

          final keyword = search.trim().toLowerCase();

          final filtered = state.measurements.where((m) {
            return m.customerName.toLowerCase().contains(keyword) ||
                m.garmentType.toLowerCase().contains(keyword) ||
                m.id.toLowerCase().contains(keyword);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                            Icons.straighten,
                            color: Color(0xFFF2CD96),
                            size: 32,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.measurements.length} Measurement Records',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Customer-wise garment measurements',
                                  style: TextStyle(
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
                    const SizedBox(height: 13),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => search = value),
                      decoration: InputDecoration(
                        hintText: 'Search customer or garment',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: search.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => search = '');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.status == MeasurementStatus.failure &&
                        state.measurements.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<MeasurementBloc>().add(
                              const LoadMeasurementsEvent(),
                            );
                          },
                          child: Text('Retry: ${state.message}'),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('No measurements found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];

                              return MeasurementCard(
                                measurement: item,
                                onTap: () => context.push(
                                  AppRoutes.measurementDetails,
                                  extra: item,
                                ),
                                onEdit: () => context.push(
                                  AppRoutes.editMeasurement,
                                  extra: item,
                                ),
                                onDelete: () =>
                                    _confirmDelete(item.id),
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
