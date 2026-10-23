
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

import '../../domain/entities/measurement_entity.dart';
import '../bloc/measurement_bloc.dart';

class MeasurementDetailsPage extends StatelessWidget {
  final MeasurementEntity measurement;

  const MeasurementDetailsPage({
    super.key,
    required this.measurement,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _tileBg = Color(0xFFFAF7F3);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        final matching = state.measurements.where(
          (item) => item.id == measurement.id,
        );

        final current = matching.isNotEmpty
            ? matching.first
            : measurement;

        final date = DateFormat(
          'dd MMM yyyy',
        ).format(current.createdAt);

        final values = <(String, double)>[
          ('Chest', current.chest),
          ('Waist', current.waist),
          ('Hip', current.hip),
          ('Shoulder', current.shoulder),
          ('Sleeve', current.sleeve),
          ('Length', current.length),
        ];

        void editMeasurement() {
          context.push(
            AppRoutes.editMeasurement,
            extra: current,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          // ==========================================
          // APP BAR
          // ==========================================
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Measurement Details',
              style: TextStyle(
                color: _primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Measurements',
                onPressed: editMeasurement,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),

          // ==========================================
          // BODY
          // ==========================================
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
                    // COMPACT CUSTOMER HEADER
                    // ==================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _primary,
                            _brownLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEED4A7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.straighten_rounded,
                                  color: _primary,
                                  size: 23,
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
                                      current.garmentType,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFF2CD96),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 5),

                              Material(
                                color: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(9),
                                child: InkWell(
                                  onTap: editMeasurement,
                                  borderRadius: BorderRadius.circular(9),
                                  child: const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            height: 1,
                            color: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'ID: ${current.id}',
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
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFFF2D5AD),
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================
                    // MEASUREMENT GRID
                    // ==================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.straighten_rounded,
                                color: _brownLight,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Body Measurements',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8EFE1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'INCHES',
                                  style: TextStyle(
                                    color: _brownLight,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns =
                                  constraints.maxWidth >= 430 ? 3 : 2;

                              const gap = 8.0;

                              final itemWidth =
                                  (constraints.maxWidth -
                                          (columns - 1) * gap) /
                                      columns;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final item in values)
                                    SizedBox(
                                      width: itemWidth,
                                      child: _MeasurementTile(
                                        label: item.$1,
                                        value: item.$2,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ==================================
                    // NOTES
                    // ==================================
                    if (current.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 13),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.sticky_note_2_outlined,
                                  color: _brownLight,
                                  size: 18,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Stitching Notes',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              current.notes.trim(),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ==================================
          // FIXED BOTTOM EDIT BUTTON
          // ==================================
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
                      onPressed: editMeasurement,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Edit Measurements',
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
// COMPACT MEASUREMENT TILE
// ==========================================

class _MeasurementTile extends StatelessWidget {
  final String label;
  final double value;

  const _MeasurementTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8B8178),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value.toStringAsFixed(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF392417),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'in',
                style: TextStyle(
                  color: Color(0xFF8B8178),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
