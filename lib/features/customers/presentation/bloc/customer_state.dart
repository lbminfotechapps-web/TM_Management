part of 'customer_bloc.dart';

enum CustomerStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<CustomerEntity> customers;
  final String message;
  final int revision;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.message = '',
    this.revision = 0,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<CustomerEntity>? customers,
    String? message,
    int? revision,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props =>
      [status, customers, message, revision];
}