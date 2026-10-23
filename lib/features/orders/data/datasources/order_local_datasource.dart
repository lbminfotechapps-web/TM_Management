import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> saveOrder(OrderModel order);

  Future<void> deleteOrder(String id);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final List<OrderModel> _orders = [
    OrderModel.fromJson({
      'id': 'ORD001',
      'customer_id': 'C001',
      'customer_name': 'Anita Sharma',
      'garment': 'Designer Blouse',
      'quantity': 2,
      'amount': 2500,
      'advance': 1000,
      'order_date': '2026-10-10T10:00:00',
      'delivery_date': '2026-10-18T10:00:00',
      'status': 'stitching',
      'notes': 'Boat neck with embroidery',
    }),
    OrderModel.fromJson({
      'id': 'ORD002',
      'customer_id': 'C002',
      'customer_name': 'Vikram Mehta',
      'garment': 'Men Suit',
      'quantity': 1,
      'amount': 6500,
      'advance': 3000,
      'order_date': '2026-10-11T10:00:00',
      'delivery_date': '2026-10-20T10:00:00',
      'status': 'cutting',
      'notes': 'Slim fit, dark blue',
    }),
    OrderModel.fromJson({
      'id': 'ORD003',
      'customer_id': 'C003',
      'customer_name': 'Sneha Patel',
      'garment': 'Lehenga',
      'quantity': 1,
      'amount': 8500,
      'advance': 5000,
      'order_date': '2026-10-12T10:00:00',
      'delivery_date': '2026-10-24T10:00:00',
      'status': 'trial',
      'notes': 'Bridal design',
    }),
  ];

  @override
  Future<List<OrderModel>> getOrders() async {
    return List<OrderModel>.unmodifiable(_orders);
  }

  @override
  Future<OrderModel> saveOrder(OrderModel order) async {
    final index = _orders.indexWhere((item) => item.id == order.id);

    if (index >= 0) {
      _orders[index] = order;
    } else {
      _orders.insert(0, order);
    }

    return order;
  }

  @override
  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((item) => item.id == id);
  }
}
