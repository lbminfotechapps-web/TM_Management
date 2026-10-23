
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';

class OrderFormPage extends StatefulWidget {
  final OrderEntity? order;

  const OrderFormPage({
    super.key,
    this.order,
  });

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _garmentController;
  late final TextEditingController _quantityController;
  late final TextEditingController _amountController;
  late final TextEditingController _advanceController;
  late final TextEditingController _notesController;

  String? _customerId;

  late DateTime _orderDate;
  late DateTime _deliveryDate;
  late OrderStatus _status;

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);
  static const Color _fieldBg = Color(0xFFFCFAF8);

  bool get _editing => widget.order != null;

  double get _totalAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  double get _advanceAmount =>
      double.tryParse(_advanceController.text.trim()) ?? 0;

  double get _balance {
    final total = _totalAmount;
    final advance = _advanceAmount;

    if (!total.isFinite || !advance.isFinite) return 0;

    return (total - advance)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  final NumberFormat _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    final order = widget.order;

    _customerId = order?.customerId;
    _orderDate = order?.orderDate ?? DateTime.now();

    _deliveryDate = order?.deliveryDate ??
        DateTime.now().add(const Duration(days: 7));

    _status = order?.status ?? OrderStatus.received;

    _garmentController = TextEditingController(
      text: order?.garment ?? '',
    );

    _quantityController = TextEditingController(
      text: order?.quantity.toString() ?? '1',
    );

    _amountController = TextEditingController(
      text: order?.amount.toString() ?? '',
    );

    _advanceController = TextEditingController(
      text: order?.advance.toString() ?? '0',
    );

    _notesController = TextEditingController(
      text: order?.notes ?? '',
    );

    _amountController.addListener(_updateBalance);
    _advanceController.addListener(_updateBalance);

    context.read<CustomerBloc>().add(
      const LoadCustomersEvent(),
    );
  }

  void _updateBalance() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateBalance);
    _advanceController.removeListener(_updateBalance);

    _garmentController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ==========================================
  // PICK DELIVERY DATE
  // ==========================================

  Future<void> _pickDeliveryDate() async {
    final firstDate = DateTime(
      _orderDate.year,
      _orderDate.month,
      _orderDate.day,
    );

    final initialDate = _deliveryDate.isBefore(firstDate)
        ? firstDate
        : _deliveryDate;

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (!mounted || selected == null) return;

    setState(() {
      _deliveryDate = selected;
    });
  }

  // ==========================================
  // SAVE ORDER
  // ==========================================

  void _saveOrder(List<CustomerEntity> customers) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedCustomers = customers.where(
      (customer) => customer.id == _customerId,
    );

    if (selectedCustomers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = selectedCustomers.first;

    final order = OrderEntity(
      id: widget.order?.id ??
          'ORD${DateTime.now().microsecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      garment: _garmentController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      amount: double.parse(_amountController.text.trim()),
      advance: double.parse(_advanceController.text.trim()),
      orderDate: _orderDate,
      deliveryDate: _deliveryDate,
      status: _status,
      notes: _notesController.text.trim(),
    );

    context.read<OrderBloc>().add(
      SaveOrderEvent(order),
    );
  }

  // ==========================================
  // INPUT DECORATION
  // ==========================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    OutlineInputBorder outline(Color color, double width) {
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
        fontSize: 11.5,
        color: _muted,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFACA49C),
        fontSize: 11,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: _gold,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 40,
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
      focusedErrorBorder: outline(
        Colors.redAccent,
        1.5,
      ),
      errorStyle: const TextStyle(
        fontSize: 10,
      ),
    );
  }

  // ==========================================
  // REUSABLE FIELD - KEYBOARD FIX
  // ==========================================

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,

      // FIX: Use multiline keyboard for notes.
      keyboardType: isMultiline
          ? TextInputType.multiline
          : keyboardType,

      textInputAction: isMultiline
          ? TextInputAction.newline
          : textInputAction,

      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,

      style: const TextStyle(
        fontSize: 13,
        color: _primary,
        fontWeight: FontWeight.w600,
      ),

      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hint: hint,
      ),
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
        '${customers.map((c) => c.id).join(',')}',
      ),
      initialValue: selectedId,
      isExpanded: true,
      decoration: _inputDecoration(
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
              fontSize: 12,
              color: _primary,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _customerId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select customer';
        }
        return null;
      },
    );
  }

  // ==========================================
  // PAYMENT SECTION
  // ==========================================

  Widget _paymentSection() {
    return _FormSection(
      title: 'Payment Details',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  label: 'Total Amount *',
                  controller: _amountController,
                  icon: Icons.currency_rupee,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  formatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]'),
                    ),
                  ],
                  validator: (value) {
                    final total = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (total == null ||
                        !total.isFinite ||
                        total <= 0) {
                      return 'Invalid total';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _field(
                  label: 'Advance *',
                  controller: _advanceController,
                  icon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  formatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]'),
                    ),
                  ],
                  validator: (value) {
                    final advance = double.tryParse(
                      value?.trim() ?? '',
                    );

                    final total = double.tryParse(
                      _amountController.text.trim(),
                    );

                    if (advance == null ||
                        total == null ||
                        !advance.isFinite ||
                        !total.isFinite ||
                        advance < 0 ||
                        advance > total) {
                      return 'Invalid advance';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // LIVE BALANCE
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8EFE1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _brownLight,
                  size: 17,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Remaining Balance',
                    style: TextStyle(
                      color: _brownLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _money.format(_balance),
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CUSTOMER & GARMENT SECTION
  // ==========================================

  Widget _customerGarmentSection(
    List<CustomerEntity> customers,
  ) {
    return _FormSection(
      title: 'Customer & Garment',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _customerDropdown(customers),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _field(
                  label: 'Garment Type *',
                  hint: 'e.g. Shirt',
                  controller: _garmentController,
                  icon: Icons.checkroom_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter garment';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                flex: 2,
                child: _field(
                  label: 'Quantity *',
                  controller: _quantityController,
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    final quantity = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (quantity == null ||
                        quantity < 1) {
                      return 'Invalid qty';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DELIVERY & STATUS SECTION
  // ==========================================

  Widget _deliverySection() {
    return _FormSection(
      title: 'Delivery & Status',
      icon: Icons.event_note_outlined,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DELIVERY DATE
              Expanded(
                child: InkWell(
                  onTap: _pickDeliveryDate,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: _gold,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Date',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMM yyyy')
                                    .format(_deliveryDate),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              // ORDER STATUS
              Expanded(
                child: DropdownButtonFormField<OrderStatus>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    label: 'Order Status',
                    icon: Icons.pending_actions_rounded,
                  ),
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Text(
                        status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // FIXED MULTILINE NOTES FIELD
          _field(
            label: 'Order Notes',
            hint: 'Special requirements (optional)',
            controller: _notesController,
            icon: Icons.notes_outlined,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAGE UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.status == OrderBlocStatus.saving &&
          (current.status == OrderBlocStatus.saved ||
              current.status == OrderBlocStatus.failure),
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (state.status == OrderBlocStatus.saved) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,

        // APP BAR
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _editing ? 'Edit Order' : 'New Order',
            style: const TextStyle(
              color: _primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // FORM BODY
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
                                      ? Icons.edit_note_rounded
                                      : Icons.add_shopping_cart_rounded,
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
                                          ? 'Update Order Details'
                                          : 'Create New Order',
                                      style: const TextStyle(
                                        color: _primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Customer, garment, payment & delivery',
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

                          const SizedBox(height: 13),

                          _customerGarmentSection(customers),

                          const SizedBox(height: 12),

                          _paymentSection(),

                          const SizedBox(height: 12),

                          _deliverySection(),
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
                child: BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    final saving =
                        state.status == OrderBlocStatus.saving;

                    return SizedBox(
                      height: 47,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () => _saveOrder(
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
                              : _editing
                                  ? 'Update Order'
                                  : 'Save Order',
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
// REUSABLE COMPACT FORM SECTION
// ==========================================

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
