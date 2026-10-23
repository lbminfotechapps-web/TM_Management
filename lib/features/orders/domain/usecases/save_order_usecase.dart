
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class SaveOrderUseCase {
  final OrderRepository repository;

  SaveOrderUseCase(this.repository);

  Future<OrderEntity> call(OrderEntity order) {
    if (order.customerId.trim().isEmpty) {
      throw Exception('Select customer');
    }
    if (order.garment.trim().isEmpty) {
      throw Exception('Enter garment type');
    }
    if (order.quantity <= 0) {
      throw Exception('Quantity must be greater than zero');
    }
    if (!order.amount.isFinite ||
        !order.advance.isFinite ||
        order.amount <= 0 ||
        order.advance < 0 ||
        order.advance > order.amount) {
      throw Exception('Enter valid payment amounts');
    }

    final orderDay = DateTime(
      order.orderDate.year,
      order.orderDate.month,
      order.orderDate.day,
    );
    final deliveryDay = DateTime(
      order.deliveryDate.year,
      order.deliveryDate.month,
      order.deliveryDate.day,
    );

    if (deliveryDay.isBefore(orderDay)) {
      throw Exception('Delivery date cannot precede order date');
    }

    return repository.saveOrder(order);
  }
}
