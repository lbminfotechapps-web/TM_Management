part of 'customer_bloc.dart';

sealed class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  const LoadCustomersEvent();
}

class SaveCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  final int? customerLimit;

  const SaveCustomerEvent(
    this.customer, {
    this.customerLimit,
  });

  @override
  List<Object?> get props => [customer, customerLimit];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}