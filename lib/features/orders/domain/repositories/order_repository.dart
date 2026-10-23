
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();

  Future<OrderEntity> saveOrder(OrderEntity order);

  Future<void> deleteOrder(String id);
}
