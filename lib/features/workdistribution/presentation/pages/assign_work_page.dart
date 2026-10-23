
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AssignWorkPage extends StatefulWidget {
  const AssignWorkPage({super.key});

  @override
  State<AssignWorkPage> createState() => _AssignWorkPageState();
}

enum WorkPriority { low, medium, high }

class _AssignWorkPageState extends State<AssignWorkPage> {
  static const _brown = Color(0xFF392619);
  static const _gold = Color(0xFFC28E3D);
  static const _canvas = Color(0xFFFAF7F2);
  static const _border = Color(0xFFEFE7DB);
  static const _muted = Color(0xFF827B74);
  static const _green = Color(0xFF16A36A);
  static const _red = Color(0xFFE05252);

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  // Temporary data. Replace with BLoC/API data.
  final List<WorkMember> _members = const [
    WorkMember('1', 'Ramesh Kumar', 'Master Tailor'),
    WorkMember('2', 'Sita Devi', 'Tailor'),
    WorkMember('3', 'Imran Khan', 'Cutter'),
    WorkMember('4', 'Pooja Sharma', 'Finishing'),
    WorkMember('5', 'Amit Patel', 'Tailor'),
  ];

  final List<String> _workTypes = const [
    'Cutting',
    'Stitching',
    'Finishing',
    'Ironing',
    'Alteration',
    'Quality Check',
  ];

  final List<WorkOrder> _orders = const [
    WorkOrder(
      '1',
      'ORD-001',
      'Priya Sharma',
      ['Men’s Shirt', 'Blouse'],
    ),
    WorkOrder(
      '2',
      'ORD-002',
      'Rahul Patil',
      ['Men’s Suit', 'Trouser'],
    ),
    WorkOrder(
      '3',
      'ORD-003',
      'Sneha Joshi',
      ['Wedding Lehenga', 'Blouse'],
    ),
  ];

  String? _selectedMemberId;
  String? _selectedWorkType;
  String? _selectedOrderId;
  String? _selectedItem;

  DateTime? _completionDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  WorkPriority _priority = WorkPriority.medium;
  bool _submitting = false;

  WorkOrder? get _selectedOrder {
    for (final order in _orders) {
      if (order.id == _selectedOrderId) return order;
    }
    return null;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 3),
      helpText: 'EXPECTED COMPLETION DATE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _brown,
              onPrimary: Colors.white,
              onSurface: _brown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || date == null) return;
    setState(() => _completionDate = date);
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = start
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));

    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _brown,
              onPrimary: Colors.white,
              onSurface: _brown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || time == null) return;

    setState(() {
      if (start) {
        _startTime = time;
      } else {
        _endTime = time;
      }
    });
  }

  int _minutes(TimeOfDay time) =>
      time.hour * 60 + time.minute;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _red,
      ),
    );
  }

  Future<void> _assignWork() async {
    if (!_formKey.currentState!.validate()) return;

    if (_completionDate == null) {
      _showError('Please select completion date');
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showError('Please select start and end time');
      return;
    }

    if (_minutes(_endTime!) <= _minutes(_startTime!)) {
      _showError('End time must be after start time');
      return;
    }

    final assignment = <String, dynamic>{
      'member_id': _selectedMemberId,
      'work_type': _selectedWorkType,
      'order_id': _selectedOrderId,
      'item': _selectedItem,
      'quantity': int.parse(_quantityController.text.trim()),
      'completion_date':
          DateFormat('yyyy-MM-dd').format(_completionDate!),
      'start_time':
          '${_startTime!.hour.toString().padLeft(2, '0')}:'
          '${_startTime!.minute.toString().padLeft(2, '0')}',
      'end_time':
          '${_endTime!.hour.toString().padLeft(2, '0')}:'
          '${_endTime!.minute.toString().padLeft(2, '0')}',
      'priority': _priority.name,
      'notes': _notesController.text.trim(),
    };

    setState(() => _submitting = true);

    // Demo only. Replace with your repository/BLoC submit event.
    debugPrint('ASSIGN WORK PAYLOAD: $assignment');

    if (!mounted) return;
    setState(() => _submitting = false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: _green),
            SizedBox(width: 9),
            Text('Assignment Ready'),
          ],
        ),
        content: const Text(
          'The assignment has been validated and its '
          'payload prepared. Connect your API to save it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _brown,
            size: 19,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Assign Work',
          style: TextStyle(
            color: _brown,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 25),
                children: [
                 // _buildHeading(),
                  const SizedBox(height: 13),
                  _buildAssignmentForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeading() {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 44,
  //         height: 44,
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFF1E4CF),
  //           borderRadius: BorderRadius.circular(13),
  //         ),
  //         child: const Icon(
  //           Icons.add_business,
  //           color: _gold,
  //           size: 23,
  //         ),
  //       ),
  //       const SizedBox(width: 11),

  //       const Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'New Assignment',
  //               style: TextStyle(
  //                 fontSize: 17,
  //                 fontWeight: FontWeight.w900,
  //                 color: _brown,
  //               ),
  //             ),
  //             SizedBox(height: 2),
  //             Text(
  //               'Assign tasks to your team members',
  //               style: TextStyle(
  //                 fontSize: 11,
  //                 color: _muted,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
        
  //     ],
  //   );
  // }

  Widget _buildAssignmentForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Team & Work Details',
            Icons.groups_2_outlined,
          ),
          const SizedBox(height: 13),

          _fieldLabel('Select Team Member', required: true),
          const SizedBox(height: 5),
          _dropdown<String>(
            value: _selectedMemberId,
            hint: 'Choose team member',
            items: _members.map((member) {
              return DropdownMenuItem<String>(
                value: member.id,
                child: Text(
                  '${member.name} (${member.role})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedMemberId = value);
            },
            validator: (value) =>
                value == null ? 'Select team member' : null,
          ),
          const SizedBox(height: 12),

          // Work Type + Order
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Work Type', required: true),
                    const SizedBox(height: 5),
                    _dropdown<String>(
                      value: _selectedWorkType,
                      hint: 'Select type',
                      items: _workTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedWorkType = value);
                      },
                      validator: (value) =>
                          value == null ? 'Select type' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Select Order', required: true),
                    const SizedBox(height: 5),
                    _dropdown<String>(
                      value: _selectedOrderId,
                      hint: 'Select order',
                      items: _orders.map((order) {
                        return DropdownMenuItem(
                          value: order.id,
                          child: Text(
                            order.number,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrderId = value;
                          _selectedItem = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select order' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_selectedOrder != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 13,
                  color: _muted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Customer: ${_selectedOrder!.customer}',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Item + Quantity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Item', required: true),
                    const SizedBox(height: 5),
                    _dropdown<String>(
                      value: _selectedItem,
                      hint: 'Select item',
                      items: (_selectedOrder?.items ?? [])
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _selectedOrder == null
                          ? null
                          : (value) {
                              setState(() => _selectedItem = value);
                            },
                      validator: (value) =>
                          value == null ? 'Select item' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Quantity', required: true),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        color: _brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDecoration(
                        'Enter qty',
                      ),
                      validator: (value) {
                        final qty =
                            int.tryParse(value?.trim() ?? '');
                        if (qty == null || qty <= 0) {
                          return 'Invalid qty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 15),

          _sectionHeader(
            'Schedule',
            Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 12),

          _fieldLabel(
            'Expected Completion Date',
            required: true,
          ),
          const SizedBox(height: 5),
          _pickerField(
            label: _completionDate == null
                ? 'Select completion date'
                : DateFormat('dd MMM yyyy')
                    .format(_completionDate!),
            icon: Icons.event_outlined,
            onTap: _pickDate,
            selected: _completionDate != null,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Start Time', required: true),
                    const SizedBox(height: 5),
                    _pickerField(
                      label: _startTime == null
                          ? 'Start time'
                          : _startTime!.format(context),
                      icon: Icons.access_time_rounded,
                      onTap: () => _pickTime(start: true),
                      selected: _startTime != null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('End Time', required: true),
                    const SizedBox(height: 5),
                    _pickerField(
                      label: _endTime == null
                          ? 'End time'
                          : _endTime!.format(context),
                      icon: Icons.access_time_rounded,
                      onTap: () => _pickTime(start: false),
                      selected: _endTime != null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 15),

          _sectionHeader(
            'Priority & Notes',
            Icons.flag_outlined,
          ),
          const SizedBox(height: 12),

          _fieldLabel('Priority'),
          const SizedBox(height: 7),
          Row(
            children: [
              _priorityOption(
                WorkPriority.low,
                'Low',
                _green,
                const Color(0xFFEAF8F0),
              ),
              const SizedBox(width: 8),
              _priorityOption(
                WorkPriority.medium,
                'Medium',
                _gold,
                const Color(0xFFFAF0DF),
              ),
              const SizedBox(width: 8),
              _priorityOption(
                WorkPriority.high,
                'High',
                _red,
                const Color(0xFFFFEEEE),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _fieldLabel('Notes (Optional)'),
          const SizedBox(height: 5),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 500,
            style: const TextStyle(
              color: _brown,
              fontSize: 12,
            ),
            decoration: _inputDecoration(
              'Add any special instructions...',
            ).copyWith(
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 47,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _assignWork,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _gold.withValues(
                  alpha: 0.55,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 19,
                    ),
              label: Text(
                _submitting ? 'Assigning...' : 'Assign Work',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================
  // REUSABLE WIDGETS
  // ===========================================

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF6E9D5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _gold, size: 17),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _brown,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(
    String text, {
    bool required = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF69645F),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: _red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9D978E),
        fontSize: 11,
      ),
      filled: true,
      fillColor: const Color(0xFFFCFAF7),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: _gold,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _red),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _muted,
        size: 19,
      ),
      style: const TextStyle(
        color: _brown,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
      dropdownColor: Colors.white,
      decoration: _inputDecoration(hint),
      hint: Text(
        hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _pickerField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        constraints: const BoxConstraints(minHeight: 45),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF7),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, color: _gold, size: 17),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? _brown : _muted,
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityOption(
    WorkPriority priority,
    String title,
    Color color,
    Color bg,
  ) {
    final selected = _priority == priority;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = priority),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 41,
          decoration: BoxDecoration(
            color: selected ? bg : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected ? color : _border,
              width: selected ? 1.3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 15,
                color: selected ? color : _muted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected ? color : _muted,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================
// TEMPORARY DATA MODELS
// ===========================================

class WorkMember {
  final String id;
  final String name;
  final String role;

  const WorkMember(this.id, this.name, this.role);
}

class WorkOrder {
  final String id;
  final String number;
  final String customer;
  final List<String> items;

  const WorkOrder(
    this.id,
    this.number,
    this.customer,
    this.items,
  );
}
