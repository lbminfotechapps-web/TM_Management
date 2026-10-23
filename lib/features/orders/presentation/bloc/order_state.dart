
part of 'order_bloc.dart';


enum OrderBlocStatus {
  initial,
  loading,
  success,
  saving,
  saved,
  deleting,
  deleted,
  failure,
}

class OrderState extends Equatable {
  final OrderBlocStatus status;
  final List<OrderEntity> orders;
  final String message;
  final int revision;

  const OrderState({
    this.status = OrderBlocStatus.initial,
    this.orders = const [],
    this.message = '',
    this.revision = 0,
  });

  OrderState copyWith({
    OrderBlocStatus? status,
    List<OrderEntity>? orders,
    String? message,
    int? revision,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      message: message ?? this.message,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        message,
        revision,
      ];
}
