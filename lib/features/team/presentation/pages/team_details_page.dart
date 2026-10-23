
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/team_member_entity.dart';
import '../bloc/team_bloc.dart';

class TeamDetailsPage extends StatelessWidget {
  final TeamMemberEntity member;

  const TeamDetailsPage({
    super.key,
    required this.member,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brown = Color(0xFF79512E);
  static const Color _gold = Color(0xFFD8AE70);
  static const Color _muted = Color(0xFF8D837A);
  static const Color _border = Color(0xFFEDE6DE);

  String _display(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }
    return value.trim();
  }

  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'T';

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return BlocBuilder<TeamBloc, TeamState>(
      builder: (context, state) {
        final matches = state.members.where(
          (item) => item.id == member.id,
        );

        final current =
            matches.isNotEmpty ? matches.first : member;

        void editMember() {
          context.push(
            AppRoutes.editTeamMember,
            extra: current,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Team Member Details',
              style: TextStyle(
                color: _primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Member',
                onPressed: editMember,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 4),
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
                    12, 6, 12, 20,
                  ),
                  children: [
                    // ==============================
                    // EMPLOYEE HEADER + QUICK STATS
                    // ==============================
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_primary, _brown],
                        ),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 49,
                                width: 49,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEACB99),
                                  borderRadius:
                                      BorderRadius.circular(13),
                                ),
                                child: Text(
                                  _initials(current.name),
                                  style: const TextStyle(
                                    color: _primary,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _display(current.name),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      current.role.label,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _gold,
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'ID: ${current.id}',
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 6),

                              _StatusBadge(
                                status: current.status,
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

                          const SizedBox(height: 11),

                          Row(
                            children: [
                              Expanded(
                                child: _HeaderStat(
                                  title: 'Monthly Salary',
                                  value: money.format(
                                    current.monthlySalary,
                                  ),
                                  icon: Icons.payments_outlined,
                                ),
                              ),

                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.white.withValues(
                                  alpha: 0.18,
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12),
                                  child: _HeaderStat(
                                    title: 'Joined On',
                                    value: DateFormat('dd MMM yyyy')
                                        .format(current.joinedOn),
                                    icon: Icons.calendar_month_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 11),

                    // ==============================
                    // COMPACT CONTACT DETAILS
                    // ==============================
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        12, 11, 12, 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.contact_phone_outlined,
                                size: 17,
                                color: _brown,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Contact Details',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          _ContactRow(
                            icon: Icons.phone_outlined,
                            label: 'Mobile',
                            value: _display(current.phone),
                          ),

                          const Divider(
                            height: 1,
                            color: _border,
                          ),

                          _ContactRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _display(current.email),
                          ),

                          const Divider(
                            height: 1,
                            color: _border,
                          ),

                          _ContactRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: _display(current.address),
                          ),
                        ],
                      ),
                    ),

                    // ==============================
                    // OPTIONAL NOTES
                    // ==============================
                    if (current.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 11),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
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
                                  color: _brown,
                                  size: 17,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Additional Notes',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              current.notes.trim(),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11.5,
                                height: 1.4,
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

          // ==============================
          // BOTTOM EDIT ACTION
          // ==============================
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                12, 8, 12, 10,
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
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: editMember,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                      label: const Text(
                        'Edit Member',
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
                          borderRadius:
                              BorderRadius.circular(11),
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
// STATUS BADGE
// ==========================================

class _StatusBadge extends StatelessWidget {
  final TeamMemberStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final active = status == TeamMemberStatus.active;

    final color = active
        ? const Color(0xFF247847)
        : const Color(0xFFA34343);

    final background = active
        ? const Color(0xFFE4F6EA)
        : const Color(0xFFFFE8E8);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ==========================================
// HEADER STAT
// ==========================================

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HeaderStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFEACB99),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFEACB99),
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// COMPACT CONTACT ROW
// ==========================================

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EFE1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 15,
              color: const Color(0xFF79512E),
            ),
          ),

          const SizedBox(width: 9),

          SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8D837A),
                  fontSize: 10.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF392417),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
