
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';

class CustomerDetailsPage extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerDetailsPage({
    super.key,
    required this.customer,
  });

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _lightBg = Color(0xFFF8EFE1);

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
        .take(2);

    if (words.isEmpty) return '?';

    return words.map((word) => word[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        // Get updated customer after edit.
        final matches = state.customers.where(
          (item) => item.id == customer.id,
        );

        final currentCustomer = matches.isNotEmpty
            ? matches.first
            : customer;

        final registeredDate = DateFormat(
          'dd MMM yyyy',
        ).format(currentCustomer.createdAt);

        void editCustomer() {
          context.push(
            AppRoutes.editCustomer,
            extra: currentCustomer,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          // ======================================
          // APP BAR
          // ======================================
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Customer Details',
              style: TextStyle(
                color: _primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit Customer',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _primary,
                  size: 21,
                ),
                onPressed: editCustomer,
              ),
              const SizedBox(width: 7),
            ],
          ),

          // ======================================
          // BODY
          // ======================================
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
                    15, 8, 15, 22,
                  ),
                  children: [
                    // ==================================
                    // COMPACT CUSTOMER PROFILE
                    // ==================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primary,
                            _brownLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEED4A7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: 0.30,
                                ),
                              ),
                            ),
                            child: Text(
                              _initials(currentCustomer.name),
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _display(currentCustomer.name),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text(
                                  'Customer Profile',
                                  style: TextStyle(
                                    color: Color(0xFFF2D5AD),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(7),
                                  ),
                                  child: const Text(
                                    'REGISTERED CUSTOMER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 17),

                    // ==================================
                    // CONTACT INFORMATION
                    // ==================================
                    const _SectionHeading(
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                    ),

                    const SizedBox(height: 9),

                    _DetailsCard(
                      children: [
                        _ContactInfoRow(
                          icon: Icons.call_outlined,
                          label: 'Mobile Number',
                          value: _display(currentCustomer.phone),
                        ),

                        const Divider(
                          height: 1,
                          color: _border,
                        ),

                        _ContactInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: _display(currentCustomer.email),
                        ),

                        const Divider(
                          height: 1,
                          color: _border,
                        ),

                        _ContactInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: _display(currentCustomer.address),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    // ==================================
                    // ACCOUNT INFORMATION
                    // ==================================
                    const _SectionHeading(
                      title: 'Account Information',
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 9),

                    _DetailsCard(
                      children: [
                        _CompactInfoRow(
                          icon: Icons.tag_rounded,
                          label: 'Customer ID',
                          value: _display(currentCustomer.id),
                        ),

                        const Divider(
                          height: 1,
                          color: _border,
                        ),

                        _CompactInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Registered On',
                          value: registeredDate,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // ======================================
          // FIXED EDIT BUTTON
          // ======================================
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                15, 10, 15, 12,
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
                      onPressed: editCustomer,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Edit Customer Details',
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

// ==============================================
// SECTION HEADING
// ==============================================

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
          size: 18,
          color: const Color(0xFF79512E),
        ),
        const SizedBox(width: 8),
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

// ==============================================
// COMMON DETAILS CARD
// ==============================================

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEDE6DE),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ==============================================
// CONTACT INFORMATION ROW
// ==============================================

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactInfoRow({
    required this.icon,
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
        children: [
          Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EFE1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 17,
              color: const Color(0xFF79512E),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8B8178),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF392417),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

// ==============================================
// COMPACT INFORMATION ROW
// ==============================================

class _CompactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFFBD8A47),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B8178),
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(
                color: Color(0xFF392417),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
