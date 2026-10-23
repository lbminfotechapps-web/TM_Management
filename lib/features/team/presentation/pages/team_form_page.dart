
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/team_member_entity.dart';
import '../bloc/team_bloc.dart';

class TeamFormPage extends StatefulWidget {
  final TeamMemberEntity? member;

  const TeamFormPage({
    super.key,
    this.member,
  });

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _salary;
  late final TextEditingController _notes;

  late TeamRole _role;
  late TeamMemberStatus _status;
  late DateTime _joinedOn;

  static const Color _primary = Color(0xFF392417);
  static const Color _brown = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _fieldBg = Color(0xFFFCFAF8);

  bool get _editing => widget.member != null;

  @override
  void initState() {
    super.initState();

    final member = widget.member;

    _name = TextEditingController(
      text: member?.name ?? '',
    );

    _phone = TextEditingController(
      text: member?.phone ?? '',
    );

    _email = TextEditingController(
      text: member?.email ?? '',
    );

    _address = TextEditingController(
      text: member?.address ?? '',
    );

    _salary = TextEditingController(
      text: member?.monthlySalary.toStringAsFixed(0) ?? '',
    );

    _notes = TextEditingController(
      text: member?.notes ?? '',
    );

    _role = member?.role ?? TeamRole.tailor;

    _status = member?.status ?? TeamMemberStatus.active;

    _joinedOn = member?.joinedOn ?? DateTime.now();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _salary.dispose();
    _notes.dispose();

    super.dispose();
  }

  // ==========================================
  // SELECT JOINING DATE
  // ==========================================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _joinedOn,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() {
      _joinedOn = date;
    });
  }

  // ==========================================
  // SAVE TEAM MEMBER
  // ==========================================

  void _save() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final member = TeamMemberEntity(
      id: widget.member?.id ??
          'TM${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      role: _role,
      status: _status,
      monthlySalary:
          double.tryParse(_salary.text.trim()) ?? 0,
      joinedOn: _joinedOn,
      notes: _notes.text.trim(),
    );

    context.read<TeamBloc>().add(
      SaveTeamMemberEvent(member),
    );
  }

  // ==========================================
  // COMPACT INPUT DECORATION
  // ==========================================

  InputDecoration _decoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    OutlineInputBorder outline(
      Color color,
      double width,
    ) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,

      labelStyle: const TextStyle(
        color: _muted,
        fontSize: 11,
      ),

      hintStyle: const TextStyle(
        color: Color(0xFFAAA29A),
        fontSize: 11,
      ),

      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: _gold,
              size: 17,
            ),

      prefixIconConstraints: const BoxConstraints(
        minWidth: 37,
        minHeight: 40,
      ),

      isDense: true,
      filled: true,
      fillColor: _fieldBg,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),

      border: outline(_border, 1),
      enabledBorder: outline(_border, 1),
      focusedBorder: outline(_gold, 1.5),
      errorBorder: outline(Colors.redAccent, 1),
      focusedErrorBorder:
          outline(Colors.redAccent, 1.5),

      errorStyle: const TextStyle(
        fontSize: 9,
      ),
    );
  }

  // ==========================================
  // REUSABLE TEXT FIELD
  // ==========================================

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final multiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      keyboardType: multiline
          ? TextInputType.multiline
          : keyboardType,
      textInputAction: multiline
          ? TextInputAction.newline
          : TextInputAction.next,
      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        color: _primary,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: _decoration(
        label: label,
        icon: icon,
        hint: hint,
      ),
    );
  }

  // ==========================================
  // PERSONAL INFORMATION
  // ==========================================

  Widget _personalSection() {
    return _TeamFormPanel(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _field(
            label: 'Full Name *',
            controller: _name,
            icon: Icons.person_outline_rounded,
            hint: 'Enter team member name',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter full name';
              }

              return null;
            },
          ),

          const SizedBox(height: 9),

          _field(
            label: 'Mobile Number *',
            controller: _phone,
            icon: Icons.phone_outlined,
            hint: '10-digit mobile number',
            keyboardType: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (!RegExp(r'^\d{10}$')
                  .hasMatch(value?.trim() ?? '')) {
                return 'Enter 10-digit mobile number';
              }

              return null;
            },
          ),

          const SizedBox(height: 9),

          _field(
            label: 'Email (Optional)',
            controller: _email,
            icon: Icons.mail_outline_rounded,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }

              return RegExp(
                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
              ).hasMatch(value.trim())
                  ? null
                  : 'Enter valid email';
            },
          ),

          const SizedBox(height: 9),

          _field(
            label: 'Address (Optional)',
            controller: _address,
            icon: Icons.location_on_outlined,
            hint: 'Enter address',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROLE DROPDOWN
  // ==========================================

  Widget _roleDropdown() {
    return DropdownButtonFormField<TeamRole>(
      initialValue: _role,
      isExpanded: true,
      decoration: _decoration(
        label: 'Team Role *',
        icon: Icons.work_outline_rounded,
      ),
      items: TeamRole.values.map((role) {
        return DropdownMenuItem<TeamRole>(
          value: role,
          child: Text(
            role.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _primary,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
      onChanged: (role) {
        if (role != null) {
          setState(() => _role = role);
        }
      },
    );
  }

  // ==========================================
  // STATUS DROPDOWN
  // ==========================================

  Widget _statusDropdown() {
    return DropdownButtonFormField<TeamMemberStatus>(
      initialValue: _status,
      isExpanded: true,
      decoration: _decoration(
        label: 'Member Status',
        icon: Icons.verified_user_outlined,
      ),
      items: TeamMemberStatus.values.map((status) {
        return DropdownMenuItem<TeamMemberStatus>(
          value: status,
          child: Text(
            status.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _primary,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
      onChanged: (status) {
        if (status != null) {
          setState(() => _status = status);
        }
      },
    );
  }

  // ==========================================
  // JOINING DATE
  // ==========================================

  Widget _joiningDate() {
    return Material(
      color: _fieldBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 49,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: _gold,
                size: 17,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Joining Date',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(_joinedOn),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPLOYMENT DETAILS
  // ==========================================

  Widget _employmentSection() {
    return _TeamFormPanel(
      title: 'Employment Details',
      icon: Icons.work_outline_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;

          if (compact) {
            return Column(
              children: [
                _roleDropdown(),
                const SizedBox(height: 9),
                _field(
                  label: 'Monthly Salary (₹)',
                  controller: _salary,
                  icon: Icons.currency_rupee,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateSalary,
                ),
                const SizedBox(height: 9),
                _joiningDate(),
                const SizedBox(height: 9),
                _statusDropdown(),
              ],
            );
          }

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _roleDropdown(),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _field(
                      label: 'Monthly Salary',
                      controller: _salary,
                      icon: Icons.currency_rupee,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateSalary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _joiningDate(),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _statusDropdown(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String? _validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final salary = double.tryParse(value.trim());

    if (salary == null ||
        !salary.isFinite ||
        salary < 0) {
      return 'Enter valid salary';
    }

    return null;
  }

  // ==========================================
  // NOTES SECTION
  // ==========================================

  Widget _notesSection() {
    return _TeamFormPanel(
      title: 'Additional Notes',
      icon: Icons.sticky_note_2_outlined,
      child: _field(
        label: 'Notes (Optional)',
        controller: _notes,
        icon: Icons.edit_note_outlined,
        hint: 'Add additional information...',
        maxLines: 2,
      ),
    );
  }

  // ==========================================
  // PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamBloc, TeamState>(
      listenWhen: (previous, current) =>
          previous.status == TeamStatus.saving &&
          (current.status == TeamStatus.saved ||
              current.status == TeamStatus.failure),

      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (state.status == TeamStatus.saved) {
          context.pop();
        }
      },

      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _editing ? 'Edit Team Member' : 'Add Team Member',
            style: const TextStyle(
              color: _primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  14, 8, 14, 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // COMPACT HEADER
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              _editing
                                  ? Icons.manage_accounts_outlined
                                  : Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _editing
                                      ? 'Update Staff Profile'
                                      : 'New Team Member',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _primary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Personal & employment details',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _personalSection(),

                      const SizedBox(height: 11),

                      _employmentSection(),

                      const SizedBox(height: 11),

                      _notesSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // FIXED BOTTOM SAVE BUTTON
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
                child: BlocBuilder<TeamBloc, TeamState>(
                  builder: (context, state) {
                    final saving =
                        state.status == TeamStatus.saving;

                    return SizedBox(
                      width: double.infinity,
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: saving ? null : _save,
                        icon: saving
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                size: 18,
                              ),
                        label: Text(
                          saving
                              ? 'Saving...'
                              : _editing
                                  ? 'Update Member'
                                  : 'Save Member',
                          style: const TextStyle(
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
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// REUSABLE FORM PANEL
// ==========================================

class _TeamFormPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _TeamFormPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEDE6DE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}
