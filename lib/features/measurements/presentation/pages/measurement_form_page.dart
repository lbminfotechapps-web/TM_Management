
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../domain/entities/measurement_entity.dart';
import '../bloc/measurement_bloc.dart';

class MeasurementFormPage extends StatefulWidget {
  final MeasurementEntity? measurement;

  const MeasurementFormPage({
    super.key,
    this.measurement,
  });

  @override
  State<MeasurementFormPage> createState() =>
      _MeasurementFormPageState();
}

class _MeasurementFormPageState
    extends State<MeasurementFormPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};

  static const _primary = Color(0xFF392417);
  static const _brown = Color(0xFF79512E);
  static const _gold = Color(0xFFBD8A47);
  static const _muted = Color(0xFF8B8178);
  static const _border = Color(0xFFEDE6DE);
  static const _fieldBg = Color(0xFFFCFAF8);

  static const List<String> _garmentTypes = [
    'Blouse',
    'Shirt',
    'Suit',
    'Kurta',
    'Trouser',
    'Lehenga',
    'Dress',
  ];

  static const List<String> _measurementLabels = [
    'Chest',
    'Waist',
    'Hip',
    'Shoulder',
    'Sleeve',
    'Length',
  ];

  String? _customerId;
  late String _garmentType;

  bool get _isEdit => widget.measurement != null;

  @override
  void initState() {
    super.initState();

    final measurement = widget.measurement;

    _customerId = measurement?.customerId;
    _garmentType = measurement?.garmentType ?? 'Blouse';

    if (!_garmentTypes.contains(_garmentType)) {
      _garmentType = _garmentTypes.first;
    }

    final initialValues = <String, double?>{
      'Chest': measurement?.chest,
      'Waist': measurement?.waist,
      'Hip': measurement?.hip,
      'Shoulder': measurement?.shoulder,
      'Sleeve': measurement?.sleeve,
      'Length': measurement?.length,
    };

    for (final label in _measurementLabels) {
      _controllers[label] = TextEditingController(
        text: initialValues[label]?.toString() ?? '',
      );
    }

    _controllers['Notes'] = TextEditingController(
      text: measurement?.notes ?? '',
    );

    context.read<CustomerBloc>().add(
      const LoadCustomersEvent(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double _value(String label) {
    return double.tryParse(
          _controllers[label]!.text.trim(),
        ) ??
        0;
  }

  void _save(List<CustomerEntity> customers) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final matching = customers.where(
      (customer) => customer.id == _customerId,
    );

    if (matching.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = matching.first;

    final measurement = MeasurementEntity(
      id: widget.measurement?.id ??
          'M${DateTime.now().microsecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      garmentType: _garmentType,
      chest: _value('Chest'),
      waist: _value('Waist'),
      hip: _value('Hip'),
      shoulder: _value('Shoulder'),
      sleeve: _value('Sleeve'),
      length: _value('Length'),
      notes: _controllers['Notes']!.text.trim(),
      createdAt:
          widget.measurement?.createdAt ?? DateTime.now(),
    );

    context.read<MeasurementBloc>().add(
      SaveMeasurementEvent(measurement),
    );
  }

  InputDecoration _decoration({
    required String label,
    IconData? icon,
    String? hint,
    String? suffix,
  }) {
    OutlineInputBorder outline(Color color, double width) {
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
        fontSize: 11,
        color: _muted,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFADA59C),
        fontSize: 11,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              size: 17,
              color: _gold,
            ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 38,
        minHeight: 40,
      ),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        color: _muted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: _fieldBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),
      border: outline(_border, 1),
      enabledBorder: outline(_border, 1),
      focusedBorder: outline(_gold, 1.5),
      errorBorder: outline(Colors.redAccent, 1),
      focusedErrorBorder:
          outline(Colors.redAccent, 1.5),
      errorStyle: const TextStyle(fontSize: 9),
    );
  }

  Widget _measurementField(String label) {
    return TextFormField(
      controller: _controllers[label],
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9.]'),
        ),
      ],
      style: const TextStyle(
        color: _primary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: _decoration(
        label: label,
        hint: '0.0',
        suffix: 'in',
      ),
      validator: (value) {
        final number = double.tryParse(
          value?.trim() ?? '',
        );

        if (number == null ||
            !number.isFinite ||
            number <= 0) {
          return 'Invalid $label';
        }

        return null;
      },
    );
  }

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
        if (value == null || value.isEmpty) {
          return 'Please select customer';
        }
        return null;
      },
    );
  }

  Widget _garmentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _garmentType,
      isExpanded: true,
      decoration: _decoration(
        label: 'Garment Type *',
        icon: Icons.checkroom_outlined,
      ),
      items: _garmentTypes.map((garment) {
        return DropdownMenuItem<String>(
          value: garment,
          child: Text(
            garment,
            style: const TextStyle(
              fontSize: 12,
              color: _primary,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _garmentType = value);
        }
      },
    );
  }

  Widget _customerSection(
    List<CustomerEntity> customers,
  ) {
    return _FormPanel(
      title: 'Customer & Garment',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _customerDropdown(customers),
          const SizedBox(height: 9),
          _garmentDropdown(),
        ],
      ),
    );
  }

  Widget _measurementsSection() {
    return _FormPanel(
      title: 'Body Measurements',
      icon: Icons.straighten_rounded,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8EFE1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'INCHES',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: _brown,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On narrow screens, use two fields.
          // On tablet-width layouts, use three.
          final columns =
              constraints.maxWidth >= 430 ? 3 : 2;

          const gap = 9.0;

          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap) /
                  columns;

          return Wrap(
            spacing: gap,
            runSpacing: 10,
            children: [
              for (final label in _measurementLabels)
                SizedBox(
                  width: itemWidth,
                  child: _measurementField(label),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _notesSection() {
    return _FormPanel(
      title: 'Stitching Instructions',
      icon: Icons.edit_note_rounded,
      child: TextFormField(
        controller: _controllers['Notes'],
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
          hint: 'e.g. Slim fit, boat neck...',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MeasurementBloc, MeasurementState>(
      listenWhen: (previous, current) =>
          previous.status == MeasurementStatus.saving &&
          (current.status == MeasurementStatus.saved ||
              current.status == MeasurementStatus.failure),
      listener: (context, state) {
        if (state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.status == MeasurementStatus.saved) {
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
            _isEdit
                ? 'Edit Measurements'
                : 'Add Measurements',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _primary,
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
                      14, 8, 14, 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // COMPACT PAGE HEADER
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
                                  _isEdit
                                      ? Icons.edit_note_rounded
                                      : Icons.straighten_rounded,
                                  size: 21,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isEdit
                                          ? 'Update Fitting Details'
                                          : 'New Measurement',
                                      style: const TextStyle(
                                        color: _primary,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Customer measurements & stitching notes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          _customerSection(customers),

                          const SizedBox(height: 11),

                          _measurementsSection(),

                          const SizedBox(height: 11),

                          _notesSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // FIXED SAVE BUTTON
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
                child: BlocBuilder<MeasurementBloc,
                    MeasurementState>(
                  builder: (context, state) {
                    final saving =
                        state.status ==
                            MeasurementStatus.saving;

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
                              : _isEdit
                                  ? 'Update Measurements'
                                  : 'Save Measurements',
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

class _FormPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _FormPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF392417),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}
