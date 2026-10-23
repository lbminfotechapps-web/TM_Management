
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../widgets/order_card.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _searchController = TextEditingController();

  String search = '';
  OrderStatus? filterStatus;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadOrdersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteOrder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Order?'),
        content: const Text('This order will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    context.read<OrderBloc>().add(DeleteOrderEvent(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Order List',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(
                const LoadOrdersEvent(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        onPressed: () => context.push(AppRoutes.addOrder),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listenWhen: (previous, current) {
          return previous.revision != current.revision &&
              (current.status == OrderBlocStatus.deleted ||
                  current.status == OrderBlocStatus.failure ||
                  current.status == OrderBlocStatus.saved);
        },
        listener: (context, state) {
          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message)),
              );
          }
        },
        builder: (context, state) {
          if (state.status == OrderBlocStatus.loading &&
              state.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final filtered = state.orders.where((order) {
            final text = search.toLowerCase().trim();

            final matchesText =
                order.id.toLowerCase().contains(text) ||
                order.garment.toLowerCase().contains(text) ||
                order.customerName.toLowerCase().contains(text);

            final matchesStatus =
                filterStatus == null || order.status == filterStatus;

            return matchesText && matchesStatus;
          }).toList();

          final pending = state.orders.where((o) {
            return o.status != OrderStatus.delivered &&
                o.status != OrderStatus.cancelled;
          }).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF392417),
                            Color(0xFF79512E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 31,
                            color: Color(0xFFF2CD96),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.orders.length} Total Orders',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$pending orders in progress',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => search = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search order, garment, customer',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: search.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => search = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<OrderStatus?>(
                      key: ValueKey(filterStatus),
                      initialValue: filterStatus,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Order Status',
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<OrderStatus?>(
                          value: null,
                          child: Text('All Orders'),
                        ),
                        ...OrderStatus.values.map(
                          (status) => DropdownMenuItem<OrderStatus?>(
                            value: status,
                            child: Text(status.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => filterStatus = value);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.status == OrderBlocStatus.failure &&
                        state.orders.isEmpty
                    ? Center(
                        child: TextButton(
                          onPressed: () {
                            context.read<OrderBloc>().add(
                              const LoadOrdersEvent(),
                            );
                          },
                          child: Text('Retry: ${state.message}'),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('No orders found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final order = filtered[index];

                              return OrderCard(
                                order: order,
                                onTap: () => context.push(
                                  AppRoutes.orderDetails,
                                  extra: order,
                                ),
                                onEdit: () => context.push(
                                  AppRoutes.editOrder,
                                  extra: order,
                                ),
                                onDelete: () => _deleteOrder(order.id),
                                onStatusChanged: (status) {
                                  context.read<OrderBloc>().add(
                                    SaveOrderEvent(
                                      order.copyWith(status: status),
                                    ),
                                  );
                                },
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
