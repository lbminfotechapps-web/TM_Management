import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';

class CustomerFormPage extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerFormPage({
    super.key,
    this.customer,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  static const Color _primary = Color(0xFF392417);
  static const Color _brownLight = Color(0xFF79512E);
  static const Color _gold = Color(0xFFBD8A47);
  static const Color _muted = Color(0xFF8B8178);
  static const Color _border = Color(0xFFEDE6DE);

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.customer?.name ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );

    _emailController = TextEditingController(
      text: widget.customer?.email ?? '',
    );

    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ==========================================
  // SAVE CUSTOMER
  // ==========================================

  void _saveCustomer() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final activePlan = context.read<SubscriptionBloc>().state.activePlan;

    if (activePlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An active subscription is required',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customer = CustomerEntity(
      id: widget.customer?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    context.read<CustomerBloc>().add(
          SaveCustomerEvent(
            customer,
            customerLimit: activePlan.customerLimit,
          ),
        );
  }

  // ==========================================
  // REUSABLE COMPACT FIELD
  // ==========================================

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (requiredField) ...[
                const SizedBox(width: 3),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              color: _primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFAAA29A),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  bottom: maxLines > 1 ? 30 : 0,
                ),
                child: Icon(
                  icon,
                  color: _gold,
                  size: 18,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              filled: true,
              fillColor: const Color(0xFFFCFAF8),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _gold,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.4,
                ),
              ),
              errorStyle: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (previous, current) =>
          previous.status == CustomerStatus.saving &&
          (current.status == CustomerStatus.saved ||
              current.status == CustomerStatus.failure),
      listener: (context, state) {
        if (state.status == CustomerStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else if (state.status == CustomerStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,

        // ====================================
        // APP BAR
        // ====================================

        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Text(
            _isEdit ? 'Edit Customer' : 'Add Customer',
            style: const TextStyle(
              color: _primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),

        // ====================================
        // FORM BODY
        // ====================================

        body: SafeArea(
          bottom: false,
        
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  15,
                  8,
                  15,
                  20,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          14,
                          14,
                          2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: _brownLight,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Basic Information',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // FULL NAME
                            _buildField(
                              label: 'Full Name',
                              hint: 'Enter customer full name',
                              controller: _nameController,
                              icon: Icons.person_outline_rounded,
                              requiredField: true,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter customer name';
                                }
                                return null;
                              },
                            ),

                            // MOBILE NUMBER
                            _buildField(
                              label: 'Mobile Number',
                              hint: 'Enter 10-digit mobile number',
                              controller: _phoneController,
                              icon: Icons.phone_outlined,
                              requiredField: true,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (!RegExp(r'^[0-9]{10}$')
                                    .hasMatch(value?.trim() ?? '')) {
                                  return 'Enter valid 10-digit number';
                                }
                                return null;
                              },
                            ),

                            // EMAIL ADDRESS
                            _buildField(
                              label: 'Email Address',
                              hint: 'customer@example.com',
                              controller: _emailController,
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final email = value?.trim() ?? '';

                                if (email.isNotEmpty &&
                                    !RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(email)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            // ADDRESS
                            _buildField(
                              label: 'Address',
                              hint: 'Enter customer address',
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.newline,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // OPTIONAL HELPER TEXT
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: _muted,
                              size: 13,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Fields marked with * are required',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                ),
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
        
        ),

        // ====================================
        // FIXED BOTTOM SAVE BUTTON
        // ====================================

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              15,
              10,
              15,
              12,
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
                  maxWidth: 600,
                ),
                child: BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    final saving = state.status == CustomerStatus.saving;

                    return AppButton(
                      title: saving
                          ? 'Saving...'
                          : _isEdit
                              ? 'Update Customer'
                              : 'Save Customer',
                      loading: saving,
                      onTap: saving ? null : _saveCustomer,
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
