
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/measurement_entity.dart';

class MeasurementCard extends StatelessWidget {
  final MeasurementEntity measurement;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MeasurementCard({
    super.key,
    required this.measurement,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  // ==========================================
  // COLORS
  // ==========================================

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _stripBg = Color(0xFFF8F5F0);

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final m = measurement;

    final date = DateFormat(
      'dd MMM yyyy',
    ).format(m.createdAt);

    // Add additional measurement fields here
    // whenever you extend MeasurementEntity.
    final metrics = <_MeasurementValue>[
      _MeasurementValue('CH', 'Chest', m.chest),
      _MeasurementValue('WA', 'Waist', m.waist),
      _MeasurementValue('HP', 'Hip', m.hip),
      _MeasurementValue('SH', 'Shoulder', m.shoulder),
      _MeasurementValue('SL', 'Sleeve', m.sleeve),
      _MeasurementValue('LN', 'Length', m.length),
    ];

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
              11,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================
                // CUSTOMER INFORMATION HEADER
                // ======================================

                Row(
                  children: [
                    Container(
                      width: 37,
                      height: 37,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.straighten_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.customerName.trim().isEmpty
                                ? 'Unknown Customer'
                                : m.customerName,
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
                                  m.garmentType.trim().isEmpty
                                      ? 'Garment'
                                      : m.garmentType,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _gold,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              const Text(
                                '•',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                date,
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

                    // ==================================
                    // ACTION MENU
                    // ==================================

                    _buildActionMenu(),
                  ],
                ),

                const SizedBox(height: 10),

                // ======================================
                // HORIZONTAL MEASUREMENT STRIP
                // ======================================

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _stripBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 59,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,

                      physics:
                          const BouncingScrollPhysics(),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),

                      itemCount: metrics.length,

                      separatorBuilder: (_, __) {
                        return Container(
                          width: 1,
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          color: _border,
                        );
                      },

                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 58,
                          child: _MetricItem(
                            metric: metrics[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ======================================
                // OPTIONAL NOTES
                // ======================================

                if (m.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 13,
                        color: _gold,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          m.notes.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            height: 1.3,
                          ),
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

  // ==========================================
  // ACTION MENU
  // ==========================================

  Widget _buildActionMenu() {
    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<String>(
        tooltip: 'Measurement actions',
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
            height: 43,
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
            height: 43,
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: _brownLight,
                ),
                SizedBox(width: 10),
                Text('Edit Measurements'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'delete',
            height: 43,
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Delete Measurements',
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

// ============================================
// MEASUREMENT VALUE MODEL
// ============================================

class _MeasurementValue {
  final String shortLabel;
  final String fullLabel;
  final double value;

  const _MeasurementValue(
    this.shortLabel,
    this.fullLabel,
    this.value,
  );
}

// ============================================
// INDIVIDUAL MEASUREMENT ITEM
// ============================================

class _MetricItem extends StatelessWidget {
  final _MeasurementValue metric;

  const _MetricItem({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${metric.fullLabel}: '
          '${metric.value.toStringAsFixed(1)} inches',

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.shortLabel,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF8B8178),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 4),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              metric.value.toStringAsFixed(1),
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF392417),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
