
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailorpro_clean/features/workdistribution/data/models/team_work_model.dart';

class AddUpdateWorkPage extends StatefulWidget {
  final TeamWorkModel member;
  final WorkTask? task;

  const AddUpdateWorkPage({
    super.key,
    required this.member,
    this.task,
  });

  @override
  State<AddUpdateWorkPage> createState() => _AddUpdateWorkPageState();
}

class _AddUpdateWorkPageState extends State<AddUpdateWorkPage> {
  static const primary = Color(0xFF159C69);
  static const gold = Color(0xFFBA8A2B);
  static const dark = Color(0xFF192535);
  static const bg = Color(0xFFF7F9FC);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _orderController;
  late final TextEditingController _customerController;
  late final TextEditingController _itemController;
  late final TextEditingController _assignedController;
  late final TextEditingController _completedController;
  late final TextEditingController _notesController;

  WorkStatus _status = WorkStatus.pending;

  TimeOfDay? _startTime;
  TimeOfDay? _expectedTime;
  TimeOfDay? _actualTime;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _orderController = TextEditingController(
      text: task?.orderId.isNotEmpty == true
          ? task!.orderId
          : task?.id ?? '',
    );

    _customerController = TextEditingController(
      text: task?.customerName ?? '',
    );

    _itemController = TextEditingController(
      text: task?.itemName.isNotEmpty == true
          ? task!.itemName
          : task?.title ?? '',
    );

    _assignedController = TextEditingController(
      text: task == null
          ? ''
          : task.assignedQuantity > 0
              ? task.assignedQuantity.toString()
              : '',
    );

    _completedController = TextEditingController(
      text: task?.completedQuantity.toString() ?? '0',
    );

    _notesController = TextEditingController(
      text: task?.notes ?? '',
    );

    _status = task?.status ?? WorkStatus.pending;

    _startTime = _parseTime(task?.startTime ?? '');
    _expectedTime = _parseTime(task?.expectedCompletion ?? '');
    _actualTime = _parseTime(task?.actualCompletion ?? '');
  }

  TimeOfDay? _parseTime(String value) {
    if (value.trim().isEmpty) return null;

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!.toUpperCase();

    if (hour < 1 || hour > 12 || minute > 59) return null;

    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay? value) {
    if (value == null) return '';

    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  Future<void> _selectTime(int type) async {
    final current = type == 0
        ? _startTime
        : type == 1
            ? _expectedTime
            : _actualTime;

    final result = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      if (type == 0) {
        _startTime = result;
      } else if (type == 1) {
        _expectedTime = result;
      } else {
        _actualTime = result;
      }
    });
  }

  @override
  void dispose() {
    _orderController.dispose();
    _customerController.dispose();
    _itemController.dispose();
    _assignedController.dispose();
    _completedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveWork() {
    if (!_formKey.currentState!.validate()) return;

    final assigned = int.parse(_assignedController.text.trim());
    final completed = int.parse(_completedController.text.trim());

    if (completed > assigned) {
      _message('Completed quantity cannot exceed assigned quantity');
      return;
    }

    if (_startTime == null || _expectedTime == null) {
      _message('Please select start and expected completion times');
      return;
    }

    if (_status == WorkStatus.completed && completed != assigned) {
      _message('Complete all assigned items before marking Completed');
      return;
    }

    if (_status == WorkStatus.pending && completed > 0) {
      _message('Change status to In Progress or Completed');
      return;
    }

    final orderId = _orderController.text.trim();
    final item = _itemController.text.trim();
    final start = _formatTime(_startTime);
    final expected = _formatTime(_expectedTime);

    final task = WorkTask(
      id: widget.task?.id ?? orderId,
      title: item,
      description: _notesController.text.trim(),
      status: _status,
      time: '$start - $expected',
      orderId: orderId,
      customerName: _customerController.text.trim(),
      itemName: item,
      assignedQuantity: assigned,
      completedQuantity: completed,
      startTime: start,
      expectedCompletion: expected,
      actualCompletion: _formatTime(_actualTime),
      notes: _notesController.text.trim(),
    );

    Navigator.pop(context, task);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE05252),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? 'Update Work' : 'Add New Work',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: dark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                children: [
                  _memberInfo(),
                  const SizedBox(height: 12),
                  _formSection(),
                ],
              ),
            ),
            _bottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _memberInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _decoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE3F6EC),
            child: Text(
              widget.member.name.isNotEmpty
                  ? widget.member.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.member.role,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7EE),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              isEditing ? 'Edit Work' : 'New Work',
              style: const TextStyle(
                color: primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
          const SizedBox(height: 13),

          _inputField(
            label: 'Order ID',
            hint: 'e.g. ORD-003',
            controller: _orderController,
            required: true,
          ),

          _inputField(
            label: 'Customer Name',
            hint: 'Enter customer name',
            controller: _customerController,
          ),

          const SizedBox(height: 5),

          Divider(color: Colors.grey.shade200),

          const SizedBox(height: 9),

          const Text(
            'Work Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
          const SizedBox(height: 13),

          _inputField(
            label: 'Item',
            hint: 'e.g. Blouse, Shirt, Pant',
            controller: _itemController,
            required: true,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _inputField(
                  label: 'Assigned Quantity',
                  hint: '0',
                  controller: _assignedController,
                  number: true,
                  required: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inputField(
                  label: 'Completed Quantity',
                  hint: '0',
                  controller: _completedController,
                  number: true,
                  required: true,
                ),
              ),
            ],
          ),

          _label('Status', required: true),

          DropdownButtonFormField<WorkStatus>(
            value: _status,
            isExpanded: true,
            decoration: _inputDecoration('Select status'),
            items: const [
              DropdownMenuItem(
                value: WorkStatus.pending,
                child: Text('Pending'),
              ),
              DropdownMenuItem(
                value: WorkStatus.inProgress,
                child: Text('In Progress'),
              ),
              DropdownMenuItem(
                value: WorkStatus.completed,
                child: Text('Completed'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _timeField(
                  title: 'Start Time',
                  value: _startTime,
                  onTap: () => _selectTime(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeField(
                  title: 'Expected Completion',
                  value: _expectedTime,
                  onTap: () => _selectTime(1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _timeField(
            title: 'Actual Completion (Optional)',
            value: _actualTime,
            onTap: () => _selectTime(2),
            clearable: true,
            onClear: () => setState(() => _actualTime = null),
          ),

          const SizedBox(height: 13),

          _inputField(
            label: 'Notes (Optional)',
            hint: 'Enter notes...',
            controller: _notesController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    bool number = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, required: required),
          TextFormField(
            controller: controller,
            keyboardType: number
                ? TextInputType.number
                : maxLines > 1
                    ? TextInputType.multiline
                    : TextInputType.text,
            inputFormatters: number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
            decoration: _inputDecoration(hint),
            validator: (value) {
              final v = value?.trim() ?? '';

              if (required && v.isEmpty) {
                return 'Required';
              }

              if (number && v.isNotEmpty) {
                final parsed = int.tryParse(v);
                if (parsed == null) return 'Invalid number';
                if (label == 'Assigned Quantity' && parsed <= 0) {
                  return 'Must be > 0';
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String title, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: dark,
              ),
            ),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFE05252),
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _timeField({
    required String title,
    required TimeOfDay? value,
    required VoidCallback onTap,
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE3E8EE),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 17,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value == null
                        ? 'Select time'
                        : _formatTime(value),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? Colors.grey.shade500
                          : dark,
                    ),
                  ),
                ),
                if (clearable && value != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade400,
      ),
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE3E8EE),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE3E8EE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primary,
          width: 1.3,
        ),
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveWork,
            icon: const Icon(Icons.save_outlined, size: 19),
            label: Text(
              isEditing ? 'Update Work' : 'Save Work',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFECF0F3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
