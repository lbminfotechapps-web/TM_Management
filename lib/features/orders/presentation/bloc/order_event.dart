
part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrderEvent {
  const LoadOrdersEvent();
}

class SaveOrderEvent extends OrderEvent {
  final OrderEntity order;

  const SaveOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}

class DeleteOrderEvent extends OrderEvent {
  final String orderId;

  const DeleteOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
