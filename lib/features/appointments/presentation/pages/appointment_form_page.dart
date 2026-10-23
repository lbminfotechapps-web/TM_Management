
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';

class AppointmentFormPage extends StatefulWidget {
  final AppointmentEntity? appointment;

  const AppointmentFormPage({
    super.key,
    this.appointment,
  });

  @override
  State<AppointmentFormPage> createState() =>
      _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _purposeController;
  late final TextEditingController _notesController;

  String? _customerId;
  late DateTime _dateTime;
  late AppointmentStatus _status;

  static const Color _primary = Color(0xFF392417);
  static const Color _brown = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _fieldBg = Color(0xFFFCFAF8);

  bool get _editing => widget.appointment != null;

  @override
  void initState() {
    super.initState();

    final item = widget.appointment;

    _customerId = item?.customerId;
    _dateTime = item?.dateTime ??
        DateTime.now().add(const Duration(days: 1));
    _status = item?.status ?? AppointmentStatus.scheduled;

    _purposeController = TextEditingController(
      text: item?.purpose ?? '',
    );

    _notesController = TextEditingController(
      text: item?.notes ?? '',
    );

    context.read<CustomerBloc>().add(
      const LoadCustomersEvent(),
    );
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ==========================================
  // DATE PICKER
  // ==========================================

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  // ==========================================
  // TIME PICKER
  // ==========================================

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );

    if (!mounted || time == null) return;

    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ==========================================
  // SAVE APPOINTMENT
  // ==========================================

  void _save(List<CustomerEntity> customers) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final matches = customers.where(
      (customer) => customer.id == _customerId,
    );

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = matches.first;

    final item = AppointmentEntity(
      id: widget.appointment?.id ??
          'APT${DateTime.now().microsecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      purpose: _purposeController.text.trim(),
      dateTime: _dateTime,
      status: _status,
      notes: _notesController.text.trim(),
      createdAt:
          widget.appointment?.createdAt ?? DateTime.now(),
    );

    context.read<AppointmentBloc>().add(
      SaveAppointmentEvent(item),
    );
  }

  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration _decoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
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
        fontSize: 11.5,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFADA59C),
        fontSize: 11,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: _gold,
              size: 18,
            ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      isDense: true,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),
      border: border(_border, 1),
      enabledBorder: border(_border, 1),
      focusedBorder: border(_gold, 1.5),
      errorBorder: border(Colors.redAccent, 1),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
      errorStyle: const TextStyle(fontSize: 10),
    );
  }

  // ==========================================
  // CUSTOMER DROPDOWN
  // ==========================================

  Widget _customerDropdown(
    List<CustomerEntity> customers,
  ) {
    final selectedId = customers.any(
      (customer) => customer.id == _customerId,
    )
        ? _customerId
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(
        'customer-${selectedId ?? ''}-'
        '${customers.map((e) => e.id).join(',')}',
      ),
      initialValue: selectedId,
      isExpanded: true,
      decoration: _decoration(
        label: 'Select Customer *',
        icon: Icons.person_outline_rounded,
      ),
      items: customers.map((customer) {
        return DropdownMenuItem<String>(
          value: customer.id,
          child: Text(
            '${customer.name} (${customer.phone})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _primary,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _customerId = value);
      },
      validator: (value) {
        return value == null
            ? 'Please select customer'
            : null;
      },
    );
  }

  // ==========================================
  // PURPOSE FIELD
  // ==========================================

  Widget _purposeField() {
    return TextFormField(
      controller: _purposeController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        color: _primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: _decoration(
        label: 'Appointment Purpose *',
        hint: 'e.g. Shirt trial, blouse fitting',
        icon: Icons.checkroom_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter appointment purpose';
        }
        return null;
      },
    );
  }

  // ==========================================
  // DATE & TIME SELECTOR
  // ==========================================

  Widget _scheduleSection() {
    return _FormPanel(
      title: 'Schedule',
      icon: Icons.calendar_month_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateTimeBox(
                  title: 'Appointment Date',
                  value: DateFormat('dd MMM yyyy')
                      .format(_dateTime),
                  icon: Icons.calendar_today_outlined,
                  onTap: _selectDate,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _DateTimeBox(
                  title: 'Appointment Time',
                  value: DateFormat('hh:mm a')
                      .format(_dateTime),
                  icon: Icons.access_time_rounded,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<AppointmentStatus>(
            initialValue: _status,
            isExpanded: true,
            decoration: _decoration(
              label: 'Appointment Status',
              icon: Icons.pending_actions_outlined,
            ),
            items: AppointmentStatus.values.map((status) {
              return DropdownMenuItem<AppointmentStatus>(
                value: status,
                child: Text(
                  status.label,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NOTES FIELD (MULTILINE KEYBOARD FIX)
  // ==========================================

  Widget _notesField() {
    return TextFormField(
      controller: _notesController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: 2,
      maxLines: 3,
      style: const TextStyle(
        color: _primary,
        fontSize: 12,
      ),
      decoration: _decoration(
        label: 'Additional Notes',
        hint: 'Special instructions (optional)',
        icon: Icons.notes_outlined,
      ),
    );
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listenWhen: (previous, current) =>
          previous.status == AppointmentBlocStatus.saving &&
          (current.status == AppointmentBlocStatus.saved ||
              current.status == AppointmentBlocStatus.failure),
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (state.status == AppointmentBlocStatus.saved) {
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
            _editing
                ? 'Edit Appointment'
                : 'New Appointment',
            style: const TextStyle(
              color: _primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, customerState) {
              final customers = customerState.customers;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      14, 8, 14, 22,
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
                                  borderRadius:
                                      BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  _editing
                                      ? Icons.edit_calendar_outlined
                                      : Icons.event_available_outlined,
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
                                          ? 'Update Appointment'
                                          : 'Schedule Appointment',
                                      style: const TextStyle(
                                        color: _primary,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Customer visit, fitting or trial',
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

                          _FormPanel(
                            title: 'Appointment Information',
                            icon: Icons.person_outline_rounded,
                            child: Column(
                              children: [
                                _customerDropdown(customers),
                                const SizedBox(height: 10),
                                _purposeField(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 11),

                          _scheduleSection(),

                          const SizedBox(height: 11),

                          _FormPanel(
                            title: 'Special Instructions',
                            icon: Icons.edit_note_outlined,
                            child: _notesField(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // =====================================
        // FIXED SAVE BUTTON
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
                child: BlocBuilder<AppointmentBloc,
                    AppointmentState>(
                  builder: (context, state) {
                    final saving =
                        state.status ==
                            AppointmentBlocStatus.saving;

                    return SizedBox(
                      width: double.infinity,
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () => _save(
                                  context
                                      .read<CustomerBloc>()
                                      .state
                                      .customers,
                                ),
                        icon: saving
                            ? const SizedBox(
                                height: 17,
                                width: 17,
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
                                  ? 'Update Appointment'
                                  : 'Save Appointment',
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
// COMPACT FORM PANEL
// ==========================================

class _FormPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FormPanel({
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
                color: const Color(0xFF79512E),
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF392417),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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

// ==========================================
// COMPACT DATE / TIME BOX
// ==========================================

class _DateTimeBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFAF8),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFFEDE6DE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFBD8A47),
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B8178),
                        fontSize: 9,
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
        ),
      ),
    );
  }
}
