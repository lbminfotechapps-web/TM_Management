import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/customer_card.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  String searchText = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(
      const LoadCustomersEvent(),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Customer?'),
          content: const Text(
            'This customer will be removed from the demo list.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    context.read<CustomerBloc>().add(
      DeleteCustomerEvent(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlan =
        context.watch<SubscriptionBloc>().state.activePlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer List',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<CustomerBloc>().add(
                const LoadCustomersEvent(),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (activePlan == null) return;

          context.push(AppRoutes.addCustomer);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listenWhen: (previous, current) =>
            previous.revision != current.revision &&
            (current.status == CustomerStatus.deleted ||
                current.status == CustomerStatus.failure),
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        },
        builder: (context, state) {
          if (state.status == CustomerStatus.loading &&
              state.customers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            );
          }

          final keyword = searchText.trim().toLowerCase();

          final filtered = state.customers.where((customer) {
            return customer.name.toLowerCase().contains(keyword) ||
                customer.phone.contains(keyword) ||
                customer.address.toLowerCase().contains(keyword);
          }).toList();

          final limit = activePlan?.customerLimit ?? -1;
          final isUnlimited = limit == -1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, 10, 16, 14,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF392417),
                            Color(0xFF78522F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Color(0xFFF2CD96),
                            size: 32,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.customers.length} Customers',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isUnlimited
                                      ? 'Unlimited customer plan'
                                      : 'Plan limit: $limit customers',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFF2CD96),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) {
                        setState(() => searchText = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search name, mobile or address',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() => searchText = '');
                                  FocusScope.of(context).unfocus();
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.status == CustomerStatus.failure &&
                        state.customers.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<CustomerBloc>().add(
                              const LoadCustomersEvent(),
                            );
                          },
                          child: Text(
                            'Error: ${state.message}\nRetry',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('No customers found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final customer = filtered[index];

                              return CustomerCard(
                                customer: customer,
                                onTap: () => context.push(
                                  AppRoutes.customerDetails,
                                  extra: customer,
                                ),
                                onEdit: () => context.push(
                                  AppRoutes.editCustomer,
                                  extra: customer,
                                ),
                                onDelete: () =>
                                    _confirmDelete(customer.id),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}