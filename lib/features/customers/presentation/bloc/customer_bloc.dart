import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorpro_clean/features/customers/domain/usecases/customer_usecases.dart';

import '../../domain/entities/customer_entity.dart';

import '../../domain/usecases/save_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final SaveCustomerUseCase saveCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.saveCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(const CustomerState()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SaveCustomerEvent>(_onSaveCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      status: CustomerStatus.loading,
      message: '',
    ));

    try {
      final customers = await getCustomersUseCase();

      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: customers,
        message: '',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        message: e.toString(),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onSaveCustomer(
    SaveCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      status: CustomerStatus.saving,
      message: '',
    ));

    try {
      final currentCustomers = await getCustomersUseCase();

      final isExisting = currentCustomers.any(
        (customer) => customer.id == event.customer.id,
      );

      // Static demo subscription customer limit.
      // -1 means unlimited.
      final limit = event.customerLimit;

      if (!isExisting &&
          limit != null &&
          limit >= 0 &&
          currentCustomers.length >= limit) {
        throw Exception(
          'Customer limit reached. Upgrade your subscription.',
        );
      }

      await saveCustomerUseCase(event.customer);

      final customers = await getCustomersUseCase();

      emit(state.copyWith(
        status: CustomerStatus.saved,
        customers: customers,
        message: 'Customer saved successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(
      status: CustomerStatus.deleting,
      message: '',
    ));

    try {
      await deleteCustomerUseCase(event.customerId);

      final customers = await getCustomersUseCase();

      emit(state.copyWith(
        status: CustomerStatus.deleted,
        customers: customers,
        message: 'Customer deleted successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerStatus.failure,
        message: e.toString(),
        revision: state.revision + 1,
      ));
    }
  }
}