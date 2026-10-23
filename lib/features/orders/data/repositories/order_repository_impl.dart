
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

import '../datasources/order_local_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<List<OrderEntity>> getOrders() async {
    final models = await localDataSource.getOrders();
    return List<OrderEntity>.from(models);
  }

  @override
  Future<OrderEntity> saveOrder(OrderEntity order) {
    return localDataSource.saveOrder(
      OrderModel.fromEntity(order),
    );
  }

  @override
  Future<void> deleteOrder(String id) {
    return localDataSource.deleteOrder(id);
  }
}
